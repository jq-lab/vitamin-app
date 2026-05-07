import Foundation

@MainActor
final class TodayViewModel: ObservableObject {
    struct SignalDisplay: Identifiable, Equatable {
        var id: String { title }
        var title: String
        var value: String
        var note: String
    }

    @Published private(set) var todayState: TodayState
    @Published private(set) var energySummary: EnergySummary
    @Published private(set) var analysis: TodayAnalysis
    @Published private(set) var ritualResult: EnergyRitualResult?
    @Published private(set) var dailyIntention: DailyIntention?
    @Published private(set) var selectedABOption: ABOptionSet.Option?
    @Published private(set) var reminderPreference = ReminderPreference(isEnabled: false, intentionReminderHour: 14, reviewReminderHour: 21)
    @Published private(set) var reminderInstance: ReminderInstance?
    @Published var isRitualPresented = false
    @Published var isAnalysisPresented = false

    private let stateService = TodayStateService()
    private let ritualService = EnergyRitualService()
    private let analysisService = TodayAnalysisService()
    private let intentionService = DailyIntentionService()
    private let notificationScheduler: NotificationScheduling
    private let repositories: RepositoryRegistry

    init(
        isLowData: Bool,
        day: Date = .now,
        notificationScheduler: NotificationScheduling = InMemoryNotificationScheduler(permissionState: .authorized),
        repositories: RepositoryRegistry = .makeDefault()
    ) {
        self.notificationScheduler = notificationScheduler
        self.repositories = repositories

        if isLowData {
            let state = stateService.makeTodayState(day: day, signals: [], cycle: nil, intention: nil)
            let summary = stateService.makeEnergySummary(for: state)
            todayState = state
            energySummary = summary
            analysis = analysisService.makeAnalysis(day: day, state: state, summary: summary)
        } else {
            let signals = TodayViewModel.seededSignals(day: day)
            let cycle = CycleContext(anchorDate: day, cycleDay: 18, summary: "黄体期 Day 18")
            let state = stateService.makeTodayState(day: day, signals: signals, cycle: cycle, intention: nil)
            let summary = stateService.makeEnergySummary(for: state)
            todayState = state
            energySummary = summary
            analysis = analysisService.makeAnalysis(day: day, state: state, summary: summary)
        }
    }

    var isLowData: Bool {
        todayState.status == .lowData || analysis.isLowData
    }

    var cycleContextText: String {
        todayState.cycleContextSummary ?? String(localized: "today.cycle.lowdata")
    }

    var nextActionTitle: String {
        switch todayState.nextAction {
        case .startEnergyRitual:
            String(localized: "today.next.ritual")
        case .openAnalysis:
            String(localized: "today.next.analysis")
        case .recordWithLuna:
            String(localized: "today.next.record")
        case .reviewIntention:
            String(localized: "today.next.review")
        case .stayQuiet:
            String(localized: "today.next.quiet")
        }
    }

    var signalDisplays: [SignalDisplay] {
        if analysis.factors.isEmpty {
            return [
                .init(title: String(localized: "today.signal.source"), value: String(localized: "today.signal.lowdata.value"), note: String(localized: "today.signal.lowdata.note")),
            ]
        }

        return analysis.factors.map {
            SignalDisplay(title: $0.title, value: $0.value, note: $0.note)
        }
    }

    var monitorSignals: [SignalDisplay] {
        if isLowData {
            return [
                .init(title: "睡眠", value: "--", note: "可手动补充"),
                .init(title: "HRV", value: "--", note: "等待数据"),
                .init(title: "心率", value: "--", note: "等待数据"),
                .init(title: "周期", value: "--", note: "信息较少"),
            ]
        }

        return [
            .init(title: "睡眠", value: "7.2h", note: "睡眠心率 轻低"),
            .init(title: "HRV", value: "48ms", note: "较昨日 ↓ 8%"),
            .init(title: "心率", value: "72bpm", note: "+1%"),
            .init(title: "周期", value: "D18", note: "黄体期"),
        ]
    }

    func openRitual() {
        ritualResult = ritualService.start(day: todayState.day)
        isRitualPresented = true
    }

    func revealRitualResult() {
        ritualResult = ritualService.finish(day: todayState.day, summary: energySummary)
    }

    func skipRitual() {
        ritualResult = ritualService.skip(day: todayState.day)
        isRitualPresented = false
    }

    func closeRitual() {
        isRitualPresented = false
    }

    func openAnalysis() {
        analysis = analysisService.makeAnalysis(day: todayState.day, state: todayState, summary: energySummary)
        isAnalysisPresented = true
    }

    func closeAnalysis() {
        isAnalysisPresented = false
    }

    func selectABOption(_ option: ABOptionSet.Option) {
        guard let optionSet = analysis.optionSet else {
            return
        }

        let intention = intentionService.select(option: option, from: optionSet, day: todayState.day)
        dailyIntention = intention
        selectedABOption = option
        saveIntention(intention)
        refreshTodayStateWithIntention(intention)
        rescheduleReminderIfNeeded()
    }

    func rejectABOptions() {
        guard let optionSet = analysis.optionSet else {
            return
        }

        let intention = intentionService.reject(day: todayState.day, optionSetID: optionSet.id)
        dailyIntention = intention
        selectedABOption = nil
        reminderInstance = nil
        saveIntention(intention)
    }

    func saveReminderPreference(_ preference: ReminderPreference) {
        reminderPreference = preference
        do {
            try repositories.reminderPreferences.save(preference)
        } catch {
            assertionFailure("Failed to save reminder preference: \(error)")
        }

        rescheduleReminderIfNeeded()
    }

    private func rescheduleReminderIfNeeded() {
        guard let dailyIntention, dailyIntention.choice == .a || dailyIntention.choice == .b else {
            reminderInstance = nil
            return
        }

        if reminderPreference.isEnabled {
            reminderInstance = notificationScheduler.scheduleIntentionReminder(
                for: dailyIntention,
                preference: reminderPreference,
                day: todayState.day
            )

            if let reminderInstance {
                do {
                    try repositories.reminderInstances.save(reminderInstance)
                } catch {
                    assertionFailure("Failed to save reminder instance: \(error)")
                }
            }
        } else {
            notificationScheduler.cancelAll()
            reminderInstance = nil
        }
    }

    private func saveIntention(_ intention: DailyIntention) {
        do {
            try repositories.dailyIntentions.save(intention)
        } catch {
            assertionFailure("Failed to save daily intention: \(error)")
        }
    }

    private func refreshTodayStateWithIntention(_ intention: DailyIntention) {
        todayState = stateService.makeTodayState(
            day: todayState.day,
            signals: todayState.signals,
            cycle: todayState.cycleContextSummary.map {
                CycleContext(anchorDate: todayState.day, cycleDay: 18, summary: $0)
            },
            intention: intention
        )
    }

    private static func seededSignals(day: Date) -> [HealthSignal] {
        [
            HealthSignal(kind: .sleepSummary, day: day, valueCategory: "stable", source: .healthKit),
            HealthSignal(kind: .heartRateVariability, day: day, valueCategory: "steady", source: .healthKit),
            HealthSignal(kind: .heartRateAverage, day: day, valueCategory: "steady", source: .healthKit),
        ]
    }
}
