import SwiftUI

struct DataExportPanel: View {
    @State private var request: DataExportRequest
    @State private var package: DataExportPackage?

    private let service = DataExportService()
    private let exportItems = [
        ExportItem(id: UUID(), modelID: .dm001, dataClass: .dc01),
        ExportItem(id: UUID(), modelID: .dm010, dataClass: .dc03),
        ExportItem(id: UUID(), modelID: .dm017, dataClass: .dc04),
    ]

    init() {
        _request = State(initialValue: service.requestExport())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            supportInfoBlock(
                title: "数据导出",
                body: "Vitora 会先准备本地数据摘要。导出流程不在日志里写入健康数值、记录原文、prompt 或完整 AI 输出。",
                systemImage: "square.and.arrow.up"
            )

            ComplianceLabel(.dataControl)
                .padding(.horizontal, 4)

            stateBlock
        }
    }

    @ViewBuilder
    private var stateBlock: some View {
        switch request.state {
        case .viewing:
            actionButton(title: "准备导出", systemImage: "doc.badge.arrow.up", identifier: "support.export.start") {
                request = service.beginConfirmation(request)
            }
        case .confirming:
            supportInfoBlock(
                title: "确认导出",
                body: "导出只包含本地可导出的摘要和控制记录。继续前请确认这是你主动发起的操作。",
                systemImage: "exclamationmark.shield"
            )
            actionButton(title: "确认并准备", systemImage: "checkmark", identifier: "support.export.confirm") {
                package = service.prepare(request, exportItems: exportItems)
                request = package?.request ?? request
            }
        case .ready:
            supportInfoBlock(
                title: "导出准备好了",
                body: "已准备 \(package?.itemCount ?? exportItems.count) 类数据摘要。包含敏感类别：\((package?.containsSensitiveClasses ?? true) ? "是" : "否")。",
                systemImage: "checkmark.circle"
            )
            actionButton(title: "完成", systemImage: "checkmark", identifier: "support.export.complete") {
                request = service.complete(request)
            }
        case .completed:
            supportInfoBlock(
                title: "导出已完成",
                body: "你可以回到设置继续管理数据。Vitora 不会把导出内容写入日志。",
                systemImage: "checkmark.seal"
            )
        case .preparing:
            supportInfoBlock(title: "正在准备导出", body: "请稍等，Vitora 正在整理本地摘要。", systemImage: "hourglass")
        case .error:
            supportInfoBlock(title: "导出暂时失败", body: "请稍后重试。", systemImage: "exclamationmark.triangle")
        case .canceled:
            supportInfoBlock(title: "导出已取消", body: "没有生成新的导出内容。", systemImage: "xmark.circle")
        }
    }
}
