import XCTest
@testable import Vitora

final class NutritionServiceTests: XCTestCase {
    func testQuickEntryCreatesNutritionContextWithoutCommercialUpsell() {
        let now = Date(timeIntervalSince1970: 1_770_000_000)
        let service = NutritionService(now: { now })

        let entry = service.quickEntry(name: "下午轻补给", contextSummary: "低谷窗口前的小份蛋白")

        XCTAssertEqual(entry.name, "下午轻补给")
        XCTAssertEqual(entry.contextSummary, "低谷窗口前的小份蛋白")
        XCTAssertEqual(entry.createdAt, now)
        XCTAssertEqual(entry.updatedAt, now)
        XCTAssertFalse(entry.contextSummary.contains("购买"))
        XCTAssertFalse(entry.contextSummary.contains("治疗"))
    }

    func testUpsertAddsAndUpdatesNutritionEntry() throws {
        let firstDate = Date(timeIntervalSince1970: 1_770_000_000)
        let secondDate = Date(timeIntervalSince1970: 1_770_000_300)
        var currentDate = firstDate
        let service = NutritionService(now: { currentDate })
        let entry = service.quickEntry(name: "蛋白补给", contextSummary: "下午低谷前")

        var entries = service.upsert(entry: entry, into: [])

        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].updatedAt, firstDate)

        currentDate = secondDate
        var updated = entries[0]
        updated.contextSummary = "13:30 前可尝试"
        entries = service.upsert(entry: updated, into: entries)

        let saved = try XCTUnwrap(entries.first)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(saved.contextSummary, "13:30 前可尝试")
        XCTAssertEqual(saved.updatedAt, secondDate)
    }

    func testRemoveNutritionEntry() {
        let service = NutritionService(now: { Date(timeIntervalSince1970: 1_770_000_000) })
        let kept = service.quickEntry(name: "镁", contextSummary: "夜间放松前")
        let removed = service.quickEntry(name: "咖啡", contextSummary: "不再参考")

        let entries = service.remove(id: removed.id, from: [kept, removed])

        XCTAssertEqual(entries, [kept])
    }
}
