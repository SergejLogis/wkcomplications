import SwiftUI

@main
struct WKComplicationsWatch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            WatchAppView()
                .onAppear {
                    WatchManager.start()
                }
        }
    }
}
