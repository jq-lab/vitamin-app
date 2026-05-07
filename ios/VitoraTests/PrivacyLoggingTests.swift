import XCTest
@testable import Vitora

final class PrivacyLoggingTests: XCTestCase {
    func testLoggerRedactsHealthValuesRawRecordsPromptsAndFullAIOutput() {
        let message = VitoraLogger.sanitizedEvent(
            name: "ai.response",
            metadata: [
                "sleep": "睡眠 7.2h",
                "hrv": "HRV 48ms",
                "heart": "心率 72bpm",
                "energy": "能量 68%",
                "record": "rawRecord: 昨晚醒了两次，今天腹胀",
                "prompt": "prompt: 请分析完整健康上下文",
                "reply": "aiOutput: 这是完整 AI 回复内容",
            ]
        )

        XCTAssertFalse(message.contains("7.2h"))
        XCTAssertFalse(message.contains("48ms"))
        XCTAssertFalse(message.contains("72bpm"))
        XCTAssertFalse(message.contains("68%"))
        XCTAssertFalse(message.contains("昨晚醒了两次"))
        XCTAssertFalse(message.contains("请分析完整健康上下文"))
        XCTAssertFalse(message.contains("完整 AI 回复内容"))
        XCTAssertTrue(message.contains("[health-value]"))
        XCTAssertTrue(message.contains("[private-text]"))
    }

    func testLoggerKeepsNonSensitiveEventShape() {
        let message = VitoraLogger.sanitizedEvent(
            name: "support.open",
            metadata: [
                "route": "dataSources",
                "state": "lowData",
            ]
        )

        XCTAssertTrue(message.contains("support.open"))
        XCTAssertTrue(message.contains("route=dataSources"))
        XCTAssertTrue(message.contains("state=lowData"))
    }
}
