import Foundation

enum LunaAIError: Error, Equatable {
    case unavailable
    case outputBlocked
}

protocol LunaAIClient {
    func run(job: AIJob, context: AIContextPackage) async -> Result<LunaResponseDraft, LunaAIError>
}

struct UnavailableLunaAIClient: LunaAIClient {
    func run(job: AIJob, context: AIContextPackage) async -> Result<LunaResponseDraft, LunaAIError> {
        .failure(.unavailable)
    }
}

struct StaticLunaAIClient: LunaAIClient {
    var responseText: String

    func run(job: AIJob, context: AIContextPackage) async -> Result<LunaResponseDraft, LunaAIError> {
        .success(LunaResponseDraft(job: job, text: responseText))
    }
}
