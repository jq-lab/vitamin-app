import Foundation

struct CycleContext: Identifiable, Codable, Equatable {
    var id: UUID
    var anchorDate: Date
    var cycleDay: Int?
    var summary: String
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        anchorDate: Date,
        cycleDay: Int? = nil,
        summary: String = "",
        updatedAt: Date = .now
    ) {
        self.id = id
        self.anchorDate = anchorDate
        self.cycleDay = cycleDay
        self.summary = summary
        self.updatedAt = updatedAt
    }

    func calendarEntry(for date: Date, calendar: Calendar = .current) -> CycleCalendarEntry {
        let daysFromAnchor = calendar.dateComponents([.day], from: anchorDate, to: date).day ?? 0
        return CycleCalendarEntry(
            date: date,
            dayIndex: max(1, daysFromAnchor + 1),
            contextSummary: summary,
            isToday: calendar.isDateInToday(date)
        )
    }
}

struct CycleCalendarEntry: Identifiable, Codable, Equatable {
    var id: String { ISO8601DateFormatter().string(from: date) }
    var date: Date
    var dayIndex: Int
    var contextSummary: String
    var isToday: Bool
}
