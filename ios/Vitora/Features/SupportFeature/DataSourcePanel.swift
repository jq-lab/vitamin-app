import SwiftUI

struct DataSourcePanel: View {
    let summary: DataSourceSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            supportInfoBlock(
                title: summary.title,
                body: summary.detail,
                systemImage: "heart.text.square"
            )

            supportInfoBlock(
                title: summary.isLowDataMode ? "当前为低数据模式" : "当前为丰富数据模式",
                body: summary.keepsAppUsable ? "无论授权状态如何，Vitora 都必须保持可用，并允许你用轻补充校准今日判断。" : "数据来源状态异常时，Vitora 会保持最小可用路径。",
                systemImage: "waveform.path.ecg"
            )

            ComplianceLabel(.lowData)
                .padding(.horizontal, 4)

            supportInfoBlock(
                title: "可管理的数据来源",
                body: "HealthKit、手动补充、Vitora 理解确认。日志和错误上报不能包含健康数值或记录原文。",
                systemImage: "lock"
            )
        }
    }
}
