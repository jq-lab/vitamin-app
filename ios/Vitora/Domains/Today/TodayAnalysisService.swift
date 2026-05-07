import Foundation

struct TodayAnalysisService: TodayAnalysisServicing {
    func makeAnalysis(day: Date, state: TodayState, summary: EnergySummary) -> TodayAnalysis {
        if state.status == .lowData || summary.scoreBand == .unknown {
            return TodayAnalysis(
                day: day,
                summary: "目前已知信息较少，Today 先保留一个轻入口。",
                factors: [
                    .init(title: "数据来源", value: "较少", note: "可以继续手动记录"),
                    .init(title: "下一步", value: "记录", note: "告诉 Vitora 一件事"),
                ],
                nextStep: "先记录一件今天最明显的感受。",
                optionSet: nil,
                isLowData: true
            )
        }

        let factors = summary.supportingSignalKinds.map { kind in
            TodayAnalysis.SupportFactor(
                title: kind.displayTitle,
                value: kind.defaultDisplayValue,
                note: kind.defaultSupportNote
            )
        }

        return TodayAnalysis(
            day: day,
            summary: summary.explanationSummary,
            factors: factors,
            nextStep: "今天可以轻轻试一个可执行的小行动。",
            optionSet: makeOptionSet(day: day, summary: summary),
            isLowData: false
        )
    }

    func makeOptionSet(day: Date, summary: EnergySummary) -> ABOptionSet {
        ABOptionSet(day: day, options: [
            .init(label: .a, title: "提前加餐 + 短走动", contextSummary: summary.explanationSummary, reminderHint: "中午前后"),
            .init(label: .b, title: "保留一段安静专注", contextSummary: summary.explanationSummary, reminderHint: "下午前段"),
        ])
    }
}

private extension HealthSignal.Kind {
    var displayTitle: String {
        switch self {
        case .sleepSummary:
            "睡眠"
        case .stepCount:
            "步数"
        case .activeEnergy:
            "活动"
        case .heartRateAverage:
            "心率"
        case .restingHeartRate:
            "静息"
        case .heartRateVariability:
            "HRV"
        case .manualSummary:
            "记录"
        }
    }

    var defaultDisplayValue: String {
        switch self {
        case .sleepSummary:
            "7.2h"
        case .stepCount:
            "6k"
        case .activeEnergy:
            "中等"
        case .heartRateAverage:
            "72"
        case .restingHeartRate:
            "平稳"
        case .heartRateVariability:
            "48"
        case .manualSummary:
            "已记录"
        }
    }

    var defaultSupportNote: String {
        switch self {
        case .sleepSummary:
            "恢复感可参考"
        case .stepCount, .activeEnergy:
            "活动节奏可参考"
        case .heartRateAverage, .restingHeartRate, .heartRateVariability:
            "节奏变化可参考"
        case .manualSummary:
            "来自手动记录"
        }
    }
}
