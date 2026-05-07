import Foundation

struct TodayStateService: TodayStateServicing {
    func makeTodayState(day: Date, signals: [HealthSignal], cycle: CycleContext?, intention: DailyIntention?) -> TodayState {
        let normalizedSignals = signals.filter { Calendar.current.isDate($0.day, inSameDayAs: day) || $0.source == .manual }

        guard !normalizedSignals.isEmpty || cycle != nil || intention != nil else {
            return .lowData(day: day)
        }

        let status: TodayStateStatus = normalizedSignals.isEmpty ? .needsRecord : .ready
        let nextAction: TodayNextAction
        if intention?.canOpenEveningReview == true {
            nextAction = .reviewIntention
        } else if normalizedSignals.isEmpty {
            nextAction = .recordWithLuna
        } else {
            nextAction = .openAnalysis
        }

        return TodayState(
            day: day,
            status: status,
            cycleContextSummary: cycle?.summary,
            signals: normalizedSignals,
            nextAction: nextAction,
            dailyIntentionID: intention?.id
        )
    }

    func makeEnergySummary(for state: TodayState) -> EnergySummary {
        guard !state.signals.isEmpty else {
            return EnergySummary(
                day: state.day,
                scorePercent: nil,
                scoreBand: .unknown,
                explanationSummary: "当前可用信息较少，先记录一件事也可以。",
                supportingSignalKinds: []
            )
        }

        let hasSleep = state.signals.contains { $0.kind == .sleepSummary }
        let hasActivity = state.signals.contains { $0.kind == .activeEnergy || $0.kind == .stepCount }
        let score = hasSleep && hasActivity ? 72 : 68

        return EnergySummary(
            day: state.day,
            scorePercent: score,
            scoreBand: score >= 70 ? .high : .steady,
            explanationSummary: "基于当前可用信息的生活方式参考，今天可以保持轻量节奏。",
            supportingSignalKinds: Array(state.signals.map(\.kind).prefix(3))
        )
    }
}
