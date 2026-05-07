import Foundation

@MainActor
final class VitoraViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var isVoiceRecording = false
    @Published private(set) var capability = AppCapabilityState()
    @Published private(set) var selectedContext = "能量"
    @Published private(set) var messages: [VitoraMessage] = [
        .init(author: .vitora, text: "我看到今天 14:00 附近可能低谷。你可以告诉我一件今天发生的变化，我会先给出理解，再由你确认是否保存。"),
    ]
    @Published private(set) var richResponses: [VitoraRichResponse] = [
        .init(
            title: "Vitora 理解为",
            body: "睡眠略低和 HRV 回落可能让下午恢复变慢。今天建议选择低负担、稳定能量的行动。",
            actions: ["确认保存", "修改", "不用更新"]
        ),
    ]

    let directQuestions = [
        "为什么今天容易低谷？",
        "今天怎么安排更轻一点？",
        "复盘睡眠",
        "调整今日建议",
    ]

    let quickContexts = ["周期", "睡眠", "营养", "情绪", "能量", "+"]

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
        if context == "+" {
            inputText = "我想补充一件事："
        }
    }

    func toggleVoice() {
        isVoiceRecording.toggle()
        if isVoiceRecording {
            messages.append(.init(author: .system, text: "语音记录 00:12 · 松开后 Vitora 会先转写并理解。"))
        }
    }

    func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || isVoiceRecording else {
            return
        }

        if !trimmed.isEmpty {
            messages.append(.init(author: .user, text: trimmed))
        }

        isVoiceRecording = false
        inputText = ""

        guard capability.canUseAI else {
            messages.append(.init(author: .vitora, text: "Vitora 暂时无法生成新回复，你仍可以保存记录。"))
            messages.append(.init(author: .system, text: "你刚刚说的内容已经保留在本地输入流里，稍后可以再让 Vitora 理解。"))
            return
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
