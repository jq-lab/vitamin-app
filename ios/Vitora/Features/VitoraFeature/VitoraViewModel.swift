import Foundation

@MainActor
final class VitoraViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var isVoiceRecording: Bool = CommandLine.arguments.contains("-vitoraUITestInitialVoiceRecording") || CommandLine.arguments.contains("-vitoraUITestStrongVoice")
    @Published private(set) var voiceSignal: VoiceMoodSignal = VitoraViewModel.initialVoiceSignal
    @Published private(set) var capability = AppCapabilityState()
    @Published private(set) var selectedContext = CommandLine.arguments.contains("-vitoraUITestInitialContextCycle") ? "周期" : "睡眠"
    @Published private(set) var messages: [VitoraMessage] = [
        .init(author: .vitora, text: "HRV 偏低但深睡充足，身体在努力恢复中。今天先把高强度任务往后放一点。"),
    ]
    @Published private(set) var richResponses: [VitoraRichResponse] = []

    let directQuestions = [
        "为什么今天容易低谷？",
        "今天怎么安排更轻一点？",
        "复盘睡眠",
        "调整今日建议",
    ]

    let chatManagerTopics = ["周期", "睡眠", "营养"]

    private static var initialVoiceSignal: VoiceMoodSignal {
        if CommandLine.arguments.contains("-vitoraUITestStrongVoice") {
            return .strongPreview
        }

        if CommandLine.arguments.contains("-vitoraUITestInitialVoiceRecording") {
            return .listeningPreview
        }

        return .idle
    }

    var capabilityFeedbacks: [AppCapabilityFeedback] {
        capability.userFeedbacks
    }

    func updateCapability(_ capability: AppCapabilityState) {
        guard self.capability != capability else {
            return
        }
        self.capability = capability
    }

    func chooseQuestion(_ question: String) {
        inputText = question
        send()
    }

    func chooseContext(_ context: String) {
        selectedContext = context
    }

    func toggleVoice() {
        isVoiceRecording.toggle()
        voiceSignal = isVoiceRecording ? VoiceMoodSignal.listeningPreview : VoiceMoodSignal.idle
        if isVoiceRecording {
            messages.append(.init(author: .system, text: "语音记录 00:12 · 松开后 Vitora 会先转写并理解。"))
        }
    }

    @discardableResult
    func send() -> Bool {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || isVoiceRecording else {
            return false
        }

        if !trimmed.isEmpty {
            messages.append(.init(author: .user, text: trimmed))
        } else if isVoiceRecording {
            messages.append(.init(author: .user, text: "语音记录 00:12"))
        }

        isVoiceRecording = false
        voiceSignal = VoiceMoodSignal.idle
        inputText = ""

        guard capability.canUseAI else {
            messages.append(.init(author: .vitora, text: "Vitora 暂时无法生成新回复，你仍可以保存记录。"))
            messages.append(.init(author: .system, text: "你刚刚说的内容已经保留在本地输入流里，稍后可以再让 Vitora 理解。"))
            return true
        }

        messages.append(.init(author: .vitora, text: "我会把这件事先理解成影响今天状态的上下文，而不是任务或打卡。"))
        richResponses.insert(
            .init(
                title: "更新后的判断",
                body: "14:00 低谷窗口可能提前到 13:45，建议把补充能量提前到 13:15 前。",
                actions: ["确认保存", "修改", "不用更新"]
            ),
            at: 0
        )
        return true
    }
}

struct VitoraMessage: Identifiable, Equatable {
    enum Author {
        case vitora
        case user
        case system
    }

    let id = UUID()
    let author: Author
    let text: String
}

struct VitoraRichResponse: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let body: String
    let actions: [String]
}
