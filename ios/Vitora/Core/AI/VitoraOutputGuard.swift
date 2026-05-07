import Foundation

struct VitoraOutputGuard {
    private let restrictedMarkers: [String]
    private let restrictedPhrases: [String]

    init(
        restrictedMarkers: [String] = [
            "CX-001",
            "CX-002",
            "CX-003",
            "CX-004",
            "CX-005",
            "CX-006",
            "CX-007",
            "CX-008",
        ],
        restrictedPhrases: [String] = [
            "保证效果",
            "必须完成",
            "完成率",
            "连续天数",
            "治疗方案",
            "诊断为",
            "必须授权 HealthKit",
            "我完全知道",
        ]
    ) {
        self.restrictedMarkers = restrictedMarkers
        self.restrictedPhrases = restrictedPhrases
    }

    func validate(_ draft: LunaResponseDraft, capability: AppCapabilityState = .init()) -> LunaResponseDraft {
        guard capability.canUseAI else {
            var blocked = draft
            blocked.guardStatus = .needsLowDataRecovery
            return blocked
        }

        var next = draft
        next.guardStatus = containsRestrictedExpression(draft.text) ? .blocked : .approved
        return next
    }

    func validateRecordUnderstanding(_ draft: LunaResponseDraft, capability: AppCapabilityState = .init()) -> LunaResponseDraft {
        var guarded = validate(draft, capability: capability)
        if guarded.guardStatus == .approved && draft.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            guarded.guardStatus = .blocked
        }
        return guarded
    }

    private func containsRestrictedExpression(_ text: String) -> Bool {
        restrictedMarkers.contains { marker in
            text.localizedCaseInsensitiveContains(marker)
        } || restrictedPhrases.contains { phrase in
            text.localizedCaseInsensitiveContains(phrase)
        }
    }
}
