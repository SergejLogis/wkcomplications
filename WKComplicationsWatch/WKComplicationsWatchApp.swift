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
        .backgroundTask(.watchConnectivity) { _ in
            logger.info("Received WatchConnectivity background task")

            Haptics.success()
            WatchManager.shared.updateWidgetKiComplications()
        }
    }
}
