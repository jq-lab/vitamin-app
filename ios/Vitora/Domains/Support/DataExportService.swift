import Foundation

struct DataExportService: DataExportServicing {
    var now: () -> Date = Date.init

    func requestExport() -> DataExportRequest {
        DataExportRequest(state: .viewing, requestedAt: now())
    }

    func beginConfirmation(_ request: DataExportRequest) -> DataExportRequest {
        copy(request, state: .confirming)
    }

    func prepare(_ request: DataExportRequest, exportItems: [ExportItem]) -> DataExportPackage {
        DataExportPackage(
            request: copy(request, state: .ready),
            itemCount: exportItems.count,
            containsSensitiveClasses: exportItems.contains { $0.dataClass.requiresEncryptedStorage }
        )
    }

    func complete(_ request: DataExportRequest) -> DataExportRequest {
        copy(request, state: .completed, completedAt: now())
    }

    func cancel(_ request: DataExportRequest) -> DataExportRequest {
        copy(request, state: .canceled)
    }

    private func copy(
        _ request: DataExportRequest,
        state: DataExportState,
        completedAt: Date? = nil
    ) -> DataExportRequest {
        DataExportRequest(
            id: request.id,
            state: state,
            requestedAt: request.requestedAt,
            completedAt: completedAt ?? request.completedAt
        )
    }
}
