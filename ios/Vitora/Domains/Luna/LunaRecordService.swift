import Foundation

struct LunaRecordService: LunaRecordServicing {
    private let now: () -> Date

    init(now: @escaping () -> Date = Date.init) {
        self.now = now
    }

    func draft(text: String, quickType: LunaRecordQuickType) -> LunaRecord {
        LunaRecord(
            text: normalized(text),
            quickType: quickType,
            state: .draft,
            createdAt: now()
        )
    }

    func parse(record: LunaRecord, capability: AppCapabilityState = .init()) -> LunaRecordParsePreview {
        let detectedType = detectType(text: record.text, fallback: record.quickType)
        let aiAvailable = capability.canUseAI
        let cleanText = normalized(record.text)
        let summary = makeSummary(text: cleanText, type: detectedType, aiAvailable: aiAvailable)

        return LunaRecordParsePreview(
            recordID: record.id,
            detectedType: detectedType,
            summary: summary,
            tags: tags(for: detectedType, aiAvailable: aiAvailable),
            sourceText: cleanText,
            confidence: aiAvailable ? 0.78 : 0.36,
            aiWasAvailable: aiAvailable,
            canSaveAsFallback: true,
            complianceLabelID: aiAvailable ? "CL-LUNA" : "CL-AI-UNAVAILABLE",
            updatedAt: now()
        )
    }

    func confirm(record: LunaRecord, summary: String) -> ParsedUnderstanding {
        ParsedUnderstanding(
            recordID: record.id,
            summary: normalized(summary),
            tags: tags(for: record.quickType, aiAvailable: true),
            isUserConfirmed: true,
            updatedAt: now()
        )
    }

    func save(record: LunaRecord, preview: LunaRecordParsePreview, editedSummary: String? = nil) -> LunaRecordSaveResult {
        let summary = normalized(editedSummary ?? preview.summary)
        let understanding = ParsedUnderstanding(
            recordID: record.id,
            summary: summary,
            tags: preview.tags,
            isUserConfirmed: true,
            updatedAt: now()
        )

        var saved = record
        saved.state = .saved
        saved.confirmedUnderstandingID = understanding.id

        return LunaRecordSaveResult(
            record: saved,
            understanding: understanding,
            nutritionEntry: preview.detectedType == .nutrition ? makeNutritionEntry(from: summary) : nil
        )
    }

    func cancel(record: LunaRecord) -> LunaRecord {
        var canceled = record
        canceled.state = .canceled
        return canceled
    }

    func makeNutritionEntry(from summary: String) -> NutritionEntry {
        NutritionEntry(
            name: summary.isEmpty ? "营养补给" : summary,
            contextSummary: "用户主动记录的营养补给背景",
            createdAt: now(),
            updatedAt: now()
        )
    }

    private func detectType(text: String, fallback: LunaRecordQuickType) -> LunaRecordQuickType {
        let value = text.lowercased()
        if value.contains("营养") || value.contains("补剂") || value.contains("维生素") || value.contains("镁") {
            return .nutrition
        }
        if value.contains("经期") || value.contains("月经") || value.contains("黄体") || value.contains("排卵") {
            return .cycle
        }
        if value.contains("睡") || value.contains("醒") || value.contains("梦") {
            return .sleep
        }
        if value.contains("累") || value.contains("困") || value.contains("能量") || value.contains("疲") {
            return .energy
        }
        if value.contains("开心") || value.contains("焦虑") || value.contains("烦") || value.contains("低落") {
            return .mood
        }
        return fallback
    }

    private func makeSummary(text: String, type: LunaRecordQuickType, aiAvailable: Bool) -> String {
        let prefix: String
        switch type {
        case .energy:
            prefix = "能量记录"
        case .cycle:
            prefix = "周期记录"
        case .sleep:
            prefix = "睡眠记录"
        case .mood:
            prefix = "感受记录"
        case .nutrition:
            prefix = "营养补给记录"
        case .freeText:
            prefix = "自由记录"
        }

        let body = text.isEmpty ? "用户想先留一条轻记录" : text
        if aiAvailable {
            return "\(prefix)：\(body)"
        }
        return "\(prefix)：\(body)（AI 暂不可用，先按原文保存）"
    }

    private func tags(for type: LunaRecordQuickType, aiAvailable: Bool) -> [String] {
        var result: [String]
        switch type {
        case .energy:
            result = ["能量"]
        case .cycle:
            result = ["周期"]
        case .sleep:
            result = ["睡眠"]
        case .mood:
            result = ["感受"]
        case .nutrition:
            result = ["营养补给"]
        case .freeText:
            result = ["自由备注"]
        }

        if !aiAvailable {
            result.append("AI 不可用")
        }
        return result
    }

    private func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
