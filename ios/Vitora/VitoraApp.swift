import SwiftUI

@main
struct VitoraApp: App {
    @StateObject private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            AppRouter(environment: environment)
        }
    }
}
