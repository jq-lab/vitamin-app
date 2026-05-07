import Foundation

struct LunaOutputGuard {
    private let vitoraGuard: VitoraOutputGuard

    init(restrictedMarkers: [String] = ["CX-001", "CX-002", "CX-003", "CX-004"]) {
        vitoraGuard = VitoraOutputGuard(restrictedMarkers: restrictedMarkers)
    }

    func validate(_ draft: LunaResponseDraft, capability: AppCapabilityState = .init()) -> LunaResponseDraft {
        vitoraGuard.validate(draft, capability: capability)
    }

    func validateRecordUnderstanding(_ draft: LunaResponseDraft, capability: AppCapabilityState = .init()) -> LunaResponseDraft {
        vitoraGuard.validateRecordUnderstanding(draft, capability: capability)
    }
}
