import XCTest
@testable import Vitora

final class LunaRecordServiceTests: XCTestCase {
    func testNaturalLanguageRecordParsesConfirmsAndSaves() {
        let fixedNow = Date(timeIntervalSince1970: 1_770_001_200)
        let service = LunaRecordService(now: { fixedNow })

        let draft = service.draft(text: "下午 3 点开始有点累", quickType: .freeText)
        let preview = service.parse(record: draft)
        let saved = service.save(record: draft, preview: preview, editedSummary: "能量记录：下午三点后有点累")

        XCTAssertEqual(draft.state, .draft)
        XCTAssertEqual(preview.detectedType, .energy)
        XCTAssertTrue(preview.aiWasAvailable)
        XCTAssertEqual(saved.record.state, .saved)
        XCTAssertEqual(saved.record.confirmedUnderstandingID, saved.understanding.id)
        XCTAssertTrue(saved.understanding.isUserConfirmed)
        XCTAssertEqual(saved.understanding.summary, "能量记录：下午三点后有点累")
        XCTAssertNil(saved.nutritionEntry)
    }

    func testNutritionQuickRecordCreatesNutritionEntry() {
        let service = LunaRecordService(now: { Date(timeIntervalSince1970: 1_770_001_200) })

        let draft = service.draft(text: "今天补了镁和维生素 D", quickType: .nutrition)
        let preview = service.parse(record: draft)
        let saved = service.save(record: draft, preview: preview)

        XCTAssertEqual(preview.detectedType, .nutrition)
        XCTAssertEqual(saved.nutritionEntry?.name, preview.summary)
        XCTAssertTrue(saved.understanding.tags.contains("营养补给"))
    }

    func testCancelKeepsRecordOutOfSavedState() {
        let service = LunaRecordService()
        let draft = service.draft(text: "先不保存", quickType: .mood)

        let canceled = service.cancel(record: draft)

        XCTAssertEqual(canceled.state, .canceled)
        XCTAssertNil(canceled.confirmedUnderstandingID)
    }
}
