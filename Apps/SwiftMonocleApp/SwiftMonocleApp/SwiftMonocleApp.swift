import SwiftUI

@main
struct SwiftMonocleApp: App {
    var body: some Scene {
        WindowGroup {
            ProjectGraphDashboard(model: .swiftMonocleBootstrap)
        }
        .windowResizability(.contentMinSize)
    }
}
