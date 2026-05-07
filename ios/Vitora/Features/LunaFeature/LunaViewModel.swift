import Foundation

@MainActor
final class LunaViewModel: ObservableObject {
    enum RecordMode: String, CaseIterable, Equatable {
        case naturalLanguage
        case quick
    }

    @Published private(set) var homeState: LunaHomeState
    @Published private(set) var recentRecords: [ParsedUnderstanding] = []
    @Published var isRecordSheetPresented = false
    @Published var recordMode: RecordMode = .naturalLanguage
    @Published var selectedQuickType: LunaRecordQuickType = .freeText
    @Published var draftText = ""
    @Published private(set) var draftRecord: LunaRecord?
    @Published private(set) var parsePreview: LunaRecordParsePreview?
    @Published var editableSummary = ""
    @Published private(set) var savedBannerText: String?
    @Published private(set) var isParsing = false
    @Published var isImmersiveChatPresented = false
    @Published var chatInputText = ""
    @Published private(set) var chatMessages: [LunaConversationMessage] = []
    @Published private(set) var isChatResponding = false

    private let homeService: LunaHomeService
    private let recordService: LunaRecordService
    private let chatService: LunaChatService
    private let aiContextBuilder: AIContextBuilder
    private let outputGuard: LunaOutputGuard
    private let repositories: RepositoryRegistry
    private let capability: AppCapabilityState
    private let todayState: TodayState?

    init(
        isLowData: Bool,
        aiUnavailable: Bool = false,
        homeService: LunaHomeService = LunaHomeService(),
        recordService: LunaRecordService = LunaRecordService(),
        chatService: LunaChatService = LunaChatService(),
        aiContextBuilder: AIContextBuilder = AIContextBuilder(),
        outputGuard: LunaOutputGuard = LunaOutputGuard(),
        repositories: RepositoryRegistry = .makeDefault()
    ) {
        self.homeService = homeService
        self.recordService = recordService
        self.chatService = chatService
        self.aiContextBuilder = aiContextBuilder
        self.outputGuard = outputGuard
        self.repositories = repositories
        capability = AppCapabilityState(
            dataSourceState: isLowData ? .denied : .authorized,
            aiAvailability: aiUnavailable ? .unavailable : .available
        )
        todayState = Self.makeSeedToday(isLowData: isLowData)
        homeState = homeService.makeState(today: todayState, intention: nil, review: nil, isLowData: isLowData)
        chatMessages = chatService.openingMessages(homeState: homeState, recentRecord: nil)
    }

    func openRecordSheet(mode: RecordMode = .naturalLanguage) {
        recordMode = mode
        isRecordSheetPresented = true
        savedBannerText = nil
    }

    func enterImmersiveChat() {
        isImmersiveChatPresented = true
        savedBannerText = nil
        if chatMessages.isEmpty {
            chatMessages = chatService.openingMessages(homeState: homeState, recentRecord: recentRecords.first)
        }
    }

    func exitImmersiveChat() {
        isImmersiveChatPresented = false
    }

    func openRecordSheetFromChat() {
        if draftText.isEmpty, let lastUserMessage = chatMessages.last(where: { $0.role == .user }) {
            draftText = lastUserMessage.contentSummary
        }
        openRecordSheet()
    }

    func sendChatMessage() {
        guard let userMessage = chatService.userMessage(text: chatInputText) else {
            return
        }

        chatInputText = ""
        chatMessages = chatService.append(message: userMessage, to: chatMessages)
        persistConversationMessage(userMessage)
        isChatResponding = true

        let context = aiContextBuilder.buildImmersiveChatContext(
            messages: chatMessages,
            todayState: todayState,
            confirmedRecord: recentRecords.first
        )
        let draft = chatService.responseDraft(messages: chatMessages, context: context, capability: capability)
        let guardedDraft = outputGuard.validate(draft, capability: capability)

        if let lunaMessage = chatService.lunaMessage(from: guardedDraft) {
            chatMessages = chatService.append(message: lunaMessage, to: chatMessages)
            persistConversationMessage(lunaMessage)
        }

        isChatResponding = false
    }

    func closeRecordSheetKeepingDraft() {
        isRecordSheetPresented = false
    }

    func selectExample(_ text: String) {
        draftText = text
        recordMode = .naturalLanguage
        parsePreview = nil
        editableSummary = ""
    }

    func selectQuickType(_ type: LunaRecordQuickType) {
        selectedQuickType = type
        recordMode = .quick
        if draftText.isEmpty {
            draftText = defaultText(for: type)
        }
        parsePreview = nil
        editableSummary = ""
    }

    func parseDraft() {
        let type = recordMode == .quick ? selectedQuickType : .freeText
        let record = recordService.draft(text: draftText, quickType: type)
        draftRecord = record
        isParsing = true
        let preview = recordService.parse(record: record, capability: capability)
        parsePreview = preview
        editableSummary = preview.summary
        isParsing = false
    }

    func saveRecord() {
        guard let record = draftRecord, let parsePreview else {
            parseDraft()
            guard let record = draftRecord, let parsePreview else { return }
            persist(record: record, preview: parsePreview)
            return
        }

        persist(record: record, preview: parsePreview)
    }

    func cancelRecord() {
        if let draftRecord {
            _ = recordService.cancel(record: draftRecord)
        }
        draftRecord = nil
        parsePreview = nil
        editableSummary = ""
        isRecordSheetPresented = false
    }

    private func persist(record: LunaRecord, preview: LunaRecordParsePreview) {
        let result = recordService.save(record: record, preview: preview, editedSummary: editableSummary)

        do {
            try repositories.lunaRecords.save(result.record)
            try repositories.parsedUnderstandings.save(result.understanding)
            if let nutritionEntry = result.nutritionEntry {
                try repositories.nutritionEntries.save(nutritionEntry)
            }
        } catch {
            assertionFailure("Failed to save Luna record: \(error)")
        }

        recentRecords.insert(result.understanding, at: 0)
        homeState = homeService.makeState(
            today: todayState,
            intention: nil,
            review: nil,
            recentRecord: result.understanding,
            isLowData: capability.isLowDataMode
        )
        let savedMessage = LunaConversationMessage(
            role: .system,
            contentSummary: "已保存记录：\(result.understanding.summary)"
        )
        chatMessages = chatService.append(message: savedMessage, to: chatMessages)
        persistConversationMessage(savedMessage)
        savedBannerText = "Vitora 已保存这条记录"
        isRecordSheetPresented = false
        draftRecord = nil
        parsePreview = nil
        editableSummary = ""
        draftText = ""
        selectedQuickType = .freeText
    }

    private func persistConversationMessage(_ message: LunaConversationMessage) {
        do {
            try repositories.conversationMessages.save(message)
        } catch {
            assertionFailure("Failed to save Luna chat message: \(error)")
        }
    }

    private func defaultText(for type: LunaRecordQuickType) -> String {
        switch type {
        case .energy:
            "下午开始有点累"
        case .cycle:
            "今天有周期相关变化"
        case .sleep:
            "昨晚睡了 7 小时"
        case .mood:
            "今天情绪有点起伏"
        case .nutrition:
            "今天补了镁和维生素 D"
        case .freeText:
            ""
        }
    }

    private static func makeSeedToday(isLowData: Bool) -> TodayState? {
        let day = Date()
        if isLowData {
            return .lowData(day: day)
        }

        return TodayState(
            day: day,
            status: .ready,
            cycleContextSummary: "黄体期 Day 18",
            signals: [
                HealthSignal(kind: .sleepSummary, day: day, valueCategory: "stable", source: .healthKit),
                HealthSignal(kind: .heartRateVariability, day: day, valueCategory: "steady", source: .healthKit),
            ],
            nextAction: .recordWithLuna
        )
    }
}
