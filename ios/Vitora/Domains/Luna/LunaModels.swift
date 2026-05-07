import Foundation

enum LunaRecordState: String, Codable, Equatable {
    case draft
    case parsing
    case confirming
    case saved
    case parseError
    case canceled
}

enum LunaRecordQuickType: String, CaseIterable, Codable, Equatable {
    case energy
    case cycle
    case sleep
    case mood
    case nutrition
    case freeText
}

struct LunaHomeState: Identifiable, Codable, Equatable {
    var id: UUID
    var prompt: String
    var contextSummary: String
    var contextDetail: String
    var dateContext: String
    var recentRecordSummary: String?
    var reviewPrompt: String?
    var isLowData: Bool

    init(
        id: UUID = UUID(),
        prompt: String,
        contextSummary: String,
        contextDetail: String,
        dateContext: String,
        recentRecordSummary: String? = nil,
        reviewPrompt: String? = nil,
        isLowData: Bool
    ) {
        self.id = id
        self.prompt = prompt
        self.contextSummary = contextSummary
        self.contextDetail = contextDetail
        self.dateContext = dateContext
        self.recentRecordSummary = recentRecordSummary
        self.reviewPrompt = reviewPrompt
        self.isLowData = isLowData
    }
}

struct LunaRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var text: String
    var quickType: LunaRecordQuickType
    var state: LunaRecordState
    var createdAt: Date
    var confirmedUnderstandingID: UUID?

    init(
        id: UUID = UUID(),
        text: String,
        quickType: LunaRecordQuickType,
        state: LunaRecordState = .draft,
        createdAt: Date = .now,
        confirmedUnderstandingID: UUID? = nil
    ) {
        self.id = id
        self.text = text
        self.quickType = quickType
        self.state = state
        self.createdAt = createdAt
        self.confirmedUnderstandingID = confirmedUnderstandingID
    }

    var aiInputSummary: String {
        text.count > 120 ? String(text.prefix(120)) : text
    }
}

struct LunaRecordParsePreview: Identifiable, Codable, Equatable {
    var id: UUID
    var recordID: UUID
    var detectedType: LunaRecordQuickType
    var summary: String
    var tags: [String]
    var sourceText: String
    var confidence: Double
    var aiWasAvailable: Bool
    var canSaveAsFallback: Bool
    var complianceLabelID: String
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        recordID: UUID,
        detectedType: LunaRecordQuickType,
        summary: String,
        tags: [String],
        sourceText: String,
        confidence: Double,
        aiWasAvailable: Bool,
        canSaveAsFallback: Bool,
        complianceLabelID: String = "CL-LUNA",
        updatedAt: Date = .now
    ) {
        self.id = id
        self.recordID = recordID
        self.detectedType = detectedType
        self.summary = summary
        self.tags = tags
        self.sourceText = sourceText
        self.confidence = confidence
        self.aiWasAvailable = aiWasAvailable
        self.canSaveAsFallback = canSaveAsFallback
        self.complianceLabelID = complianceLabelID
        self.updatedAt = updatedAt
    }
}

struct LunaRecordSaveResult: Equatable {
    var record: LunaRecord
    var understanding: ParsedUnderstanding
    var nutritionEntry: NutritionEntry?
}

struct ParsedUnderstanding: Identifiable, Codable, Equatable {
    var id: UUID
    var recordID: UUID
    var summary: String
    var tags: [String]
    var isUserConfirmed: Bool
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        recordID: UUID,
        summary: String,
        tags: [String] = [],
        isUserConfirmed: Bool = false,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.recordID = recordID
        self.summary = summary
        self.tags = tags
        self.isUserConfirmed = isUserConfirmed
        self.updatedAt = updatedAt
    }
}

struct NutritionEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var contextSummary: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        contextSummary: String,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.contextSummary = contextSummary
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct LunaConversationMessage: Identifiable, Codable, Equatable {
    enum Role: String, Codable, Equatable {
        case user
        case luna
        case system
    }

    var id: UUID
    var role: Role
    var contentSummary: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        role: Role,
        contentSummary: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.role = role
        self.contentSummary = contentSummary
        self.createdAt = createdAt
    }
}

enum AIJob: String, CaseIterable, Codable, Equatable {
    case todayExplanation
    case abOptionGeneration
    case lunaRecordUnderstanding
    case immersiveChatResponse
    case eveningReviewSummary
}

struct AIContextPackage: Identifiable, Codable, Equatable {
    var id: UUID
    var job: AIJob
    var userContext: String?
    var todayContext: String?
    var cycleContext: String?
    var recordContext: String?
    var conversationContext: String?
    var intentionContext: String?
    var reviewContext: String?

    init(
        id: UUID = UUID(),
        job: AIJob,
        userContext: String? = nil,
        todayContext: String? = nil,
        cycleContext: String? = nil,
        recordContext: String? = nil,
        conversationContext: String? = nil,
        intentionContext: String? = nil,
        reviewContext: String? = nil
    ) {
        self.id = id
        self.job = job
        self.userContext = userContext
        self.todayContext = todayContext
        self.cycleContext = cycleContext
        self.recordContext = recordContext
        self.conversationContext = conversationContext
        self.intentionContext = intentionContext
        self.reviewContext = reviewContext
    }

    var containsDirectIdentity: Bool {
        [userContext, todayContext, cycleContext, recordContext, conversationContext, intentionContext, reviewContext]
            .compactMap { $0?.lowercased() }
            .contains { value in
                value.contains("@") || value.contains("account:") || value.contains("phone:")
            }
    }
}

struct LunaResponseDraft: Identifiable, Codable, Equatable {
    enum GuardStatus: String, Codable, Equatable {
        case pending
        case approved
        case blocked
        case needsLowDataRecovery
    }

    var id: UUID
    var job: AIJob
    var text: String
    var guardStatus: GuardStatus

    init(
        id: UUID = UUID(),
        job: AIJob,
        text: String,
        guardStatus: GuardStatus = .pending
    ) {
        self.id = id
        self.job = job
        self.text = text
        self.guardStatus = guardStatus
    }
}
