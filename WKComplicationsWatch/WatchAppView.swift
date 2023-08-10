import SwiftUI

struct WatchAppView: View {

    @ObservedObject var manager: WatchManager = .shared

    var body: some View {
        ZStack {
            Color.clear

            VStack {
                Text("Current value:")
                Text("**\(WatchManager.shared.currentValue)**")
                    .font(.largeTitle)
            }

            ZStack(alignment: .bottom) {
                Color.clear

                VStack {
                    Text("Last updated at:")
                    Text("**\(manager.formattedLastUpdateTime)**")
                }
                .font(.system(size: 10))
            }
        }
        .padding()
    }
}

#Preview {
    WatchAppView()
}
