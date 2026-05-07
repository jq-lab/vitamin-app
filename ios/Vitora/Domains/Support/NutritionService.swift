import Foundation

struct NutritionService: NutritionServicing {
    var now: () -> Date = Date.init

    func upsert(entry: NutritionEntry, into entries: [NutritionEntry]) -> [NutritionEntry] {
        var next = entry
        next.updatedAt = now()

        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else {
            return (entries + [next]).sorted { $0.createdAt < $1.createdAt }
        }

        var updated = entries
        updated[index] = next
        return updated.sorted { $0.createdAt < $1.createdAt }
    }

    func remove(id: UUID, from entries: [NutritionEntry]) -> [NutritionEntry] {
        entries.filter { $0.id != id }
    }

    func quickEntry(name: String, contextSummary: String) -> NutritionEntry {
        let timestamp = now()
        return NutritionEntry(
            name: name,
            contextSummary: contextSummary,
            createdAt: timestamp,
            updatedAt: timestamp
        )
    }
}
