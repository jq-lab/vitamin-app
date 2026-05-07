import Foundation

struct SupportService: SupportServicing {
    func visibleItems() -> [SupportItem] {
        SupportItem.p0Items
    }

    func panelState(selectedRoute: SupportRoute? = nil) -> SupportPanelState {
        SupportPanelState(visibleItems: visibleItems(), selectedRoute: selectedRoute)
    }

    func dataSourceSummary(for authorization: DataSourceAuthorization) -> DataSourceSummary {
        let title: String
        let detail: String

        switch authorization.state {
        case .authorized:
            title = "HealthKit 已连接"
            detail = "Vitora 会优先使用授权后的睡眠、HRV、心率和周期摘要。"
        case .skipped:
            title = "已跳过 HealthKit"
            detail = "App 继续以低数据和手动补充模式运行。"
        case .denied:
            title = "HealthKit 未授权"
            detail = "你可以稍后在系统设置里重新授权，当前使用不会被阻塞。"
        case .revoked:
            title = "HealthKit 已撤销"
            detail = "Vitora 会停止读取新数据，并使用已有本地摘要和手动补充。"
        case .notAsked:
            title = "HealthKit 尚未设置"
            detail = "HealthKit 是可选增强；跳过后仍然可以使用 Vitora。"
        }

        return DataSourceSummary(
            authorization: authorization,
            title: title,
            detail: detail,
            keepsAppUsable: authorization.keepsAppUsable,
            isLowDataMode: authorization.isLowData
        )
    }
}
