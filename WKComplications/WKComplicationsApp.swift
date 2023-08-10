import SwiftUI

@main
struct WKComplicationsApp: App {
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .onAppear {
                    WatchManager.start()
                }
        }
    }
}
