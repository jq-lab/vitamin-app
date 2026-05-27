import SwiftUI

// SideDialView removed — replaced by ScrollableChipDial in EggCompoundView

/// 维度类型 — 切换影响蛋表情 + 分数 + dial 高亮
enum DimensionType: String, CaseIterable, Identifiable {
    case today = "今日"
    case sleep = "睡眠"
    case cycle = "经期"
    case nutrition = "营养"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .today: return "sun.max.fill"
        case .sleep: return "moon.fill"
        case .cycle: return "drop.fill"
        case .nutrition: return "leaf.fill"
        }
    }

    var accent: Color {
        switch self {
        case .today: return Color(red: 205 / 255, green: 127 / 255, blue: 22 / 255)
        case .sleep: return Color(red: 70 / 255, green: 134 / 255, blue: 220 / 255)
        case .cycle: return Color(red: 104 / 255, green: 157 / 255, blue: 74 / 255)
        case .nutrition: return Color(red: 165 / 255, green: 132 / 255, blue: 82 / 255)
        }
    }

    var scoreNumber: String {
        switch self {
        case .today: return "68"
        case .sleep: return "7.2"
        case .cycle: return "D18"
        case .nutrition: return "75"
        }
    }

    var scoreUnit: String {
        switch self {
        case .today: return "/100"
        case .sleep: return "h"
        case .cycle: return ""
        case .nutrition: return "/100"
        }
    }

    var eggExpression: PixelEggExpression {
        switch self {
        case .today: return .sleepyBlush
        case .sleep: return .halfOpen
        case .cycle: return .closedSparkle
        case .nutrition: return .wideBright
        }
    }

    var crystalHighlightTopic: EnergyCrystalTopic {
        switch self {
        case .today: return .energy
        case .sleep: return .sleep
        case .cycle: return .periodMood
        case .nutrition: return .nutrition
        }
    }

    var insightTopic: TodayInsightTopic {
        switch self {
        case .today: return .energy
        case .sleep: return .sleep
        case .cycle: return .period
        case .nutrition: return .nutrition
        }
    }

    var vitoraMessage: String {
        switch self {
        case .today: return "HRV 偏低但深睡充足，身体在努力恢复中。今天先把高强度任务往后放一点。"
        case .sleep: return "昨夜深睡 1.4h，恢复略浅。今天午后适合轻安排。"
        case .cycle: return "黄体期 Day 18，身体倾向保留余量。预计 8 天后进入下一周期。"
        case .nutrition: return "补水 5/8 杯，镁和 B6 今天未记录。记录已在使用的补给即可。"
        }
    }
}
