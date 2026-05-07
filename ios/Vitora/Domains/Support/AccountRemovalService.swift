import Foundation

struct AccountRemovalService: AccountRemovalServicing {
    var now: () -> Date = Date.init

    func requestRemoval() -> AccountRemovalRequest {
        AccountRemovalRequest(state: .viewing, requestedAt: now())
    }

    func beginConfirmation(_ request: AccountRemovalRequest) -> AccountRemovalRequest {
        copy(request, state: .confirming)
    }

    func complete(_ request: AccountRemovalRequest, persistence: PersistenceClient) throws -> AccountRemovalResult {
        let gate = try persistence.removeAccountData()
        return AccountRemovalResult(
            request: copy(request, state: .completed, completedAt: now()),
            gateState: gate
        )
    }

    func cancel(_ request: AccountRemovalRequest) -> AccountRemovalRequest {
        copy(request, state: .canceled)
    }

    private func copy(
        _ request: AccountRemovalRequest,
        state: AccountRemovalState,
        completedAt: Date? = nil
    ) -> AccountRemovalRequest {
        AccountRemovalRequest(
            id: request.id,
            state: state,
            requestedAt: request.requestedAt,
            completedAt: completedAt ?? request.completedAt
        )
    }
}
