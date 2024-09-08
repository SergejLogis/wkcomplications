import SwiftUI
import WatchConnectivity

struct MainAppView: View {

    @State var value = WatchManager.shared.currentValue

    let manager = WatchManager.shared

    var body: some View {
        VStack {
            Stepper("Current value: **\(value)**", value: $value) { isEditing in
                if isEditing == false {
                    manager.setCurrentValue(value)
                }
            }

            HStack {
                Text("Last updated at: **\(manager.formattedLastUpdateTime)**")
                    .font(.system(size: 10))
                Spacer()
            }

            VStack {
                Button("Send App Context Update to Watch") {
                    manager.sendAppContextUpdateMessageToWatch(value: value)
                }

                Button("Send value to Watch") {
                    manager.sendUpdateMessageToWatch(value: value)
                }

                Button("Send Complication value to Watch") {
                    manager.sendComplicationsUpdateMessageToWatch(value: value)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 50)
        }
        .padding()
    }
}

#Preview {
    MainAppView()
}
