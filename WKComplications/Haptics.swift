import WatchKit

enum Haptics {

    static func success() {
        feedback(.success)
    }

    static func failure() {
        feedback(.failure)
    }

    private static func feedback(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
}
