import Foundation

struct EnergyRitualService: EnergyRitualServicing {
    func openingState(day: Date, hasCompletedOrSkipped: Bool) -> DailyOpeningState {
        DailyOpeningState(day: day, state: hasCompletedOrSkipped ? .notDue : .due)
    }

    func start(day: Date) -> EnergyRitualResult {
        EnergyRitualResult(day: day, state: .running)
    }

    func finish(day: Date, summary: EnergySummary?) -> EnergyRitualResult {
        EnergyRitualResult(
            day: day,
            state: summary == nil ? .skipped : .completed,
            energySummary: summary,
            completedAt: .now
        )
    }

    func skip(day: Date) -> EnergyRitualResult {
        finish(day: day, summary: nil)
    }
}
