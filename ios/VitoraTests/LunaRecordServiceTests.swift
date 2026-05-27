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

final class VitoraQuickRecordParserTests: XCTestCase {
    func testHeadacheAndB6SentenceParsesTwoItems() {
        let preview = VitoraQuickRecordParser().parse(rawInput: "今天有点头痛吃了 B6")

        XCTAssertEqual(preview.items.count, 2)
        XCTAssertNil(preview.vitoraFeedback)

        let headache = preview.items.first { $0.subtype == "headache" }
        XCTAssertEqual(headache?.category, .symptom)
        XCTAssertEqual(headache?.severity, "轻")
        XCTAssertEqual(headache?.needsConfirmation, false)

        let b6 = preview.items.first { $0.subtype == "B6" }
        XCTAssertEqual(b6?.category, .nutrition)
        XCTAssertEqual(b6?.doseMG, 10)
        XCTAssertEqual(b6?.needsConfirmation, false)
    }

    func testBareHeadacheDefaultsToMediumAndNeedsConfirmation() {
        let preview = VitoraQuickRecordParser().parse(rawInput: "头痛")

        XCTAssertEqual(preview.items.count, 1)
        XCTAssertEqual(preview.items.first?.subtype, "headache")
        XCTAssertEqual(preview.items.first?.severity, "中")
        XCTAssertEqual(preview.items.first?.needsConfirmation, true)
    }

    func testMagnesiumAndB6ParseAsTwoNutritionItems() {
        let preview = VitoraQuickRecordParser().parse(rawInput: "镁 200mg + B6 10mg")

        XCTAssertEqual(preview.items.count, 2)
        XCTAssertEqual(preview.items.map(\.category), [.nutrition, .nutrition])
        XCTAssertEqual(preview.items.first { $0.subtype == "magnesium" }?.doseMG, 200)
        XCTAssertEqual(preview.items.first { $0.subtype == "B6" }?.doseMG, 10)
    }
}
