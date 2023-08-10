import WatchConnectivity
import WidgetKit

class WatchManager: NSObject, ObservableObject {

    private enum Key {
        static let currentValue = "currentValue"
        static let lastUpdateDate = "lastUpdateDate"
    }
    
    private(set) var currentValue: Int {
        get {
            storage.integer(forKey: Key.currentValue)
        }
        set {
            storage.setValue(newValue, forKey: Key.currentValue)
            notifyObjectDidChange()
        }
    }
    
    private(set) var lastUpdateDate: Date? {
        get {
            storage.value(forKey: Key.lastUpdateDate) as? Date
        }
        set {
            storage.setValue(newValue, forKey: Key.lastUpdateDate)
            notifyObjectDidChange()
        }
    }

    var formattedLastUpdateTime: String {
        lastUpdateDate?.formatted(.dateTime.hour().minute().second().secondFraction(.fractional(3))) ?? "NEVER"
    }

    private let storage = UserDefaults(suiteName: "group.com.sergej.WKComplications")!
    
    private var session: WCSession {
        WCSession.default
    }
    
    private override init() {
        super.init()

        session.delegate = self
        session.activate()
        
        logger.info("WatchManager initialized")
    }

    func setCurrentValue(_ value: Int) {
        currentValue = value
        lastUpdateDate = .now
    }

    private func notifyObjectDidChange() {
        let sendNotification = {
            self.objectWillChange.send()
        }

        if Thread.current.isMainThread {
            sendNotification()
        } else {
            DispatchQueue.main.async(execute: sendNotification)
        }
    }

    // MARK: - Static

    static let shared = WatchManager()

    static func start() {
        _ = shared
    }
}

// MARK: - iOS

#if os(iOS)
extension WatchManager {
    
    func sendUpdateMessageToWatch(value: Int) {
        guard session.isReachable else {
            return logger.error("Watch not reachable!")
        }
        
        logger.info("Sending value to Watch: \(value)")

        let message = watchMessage(value: value)
        session.sendMessage(message, replyHandler: { response in
            logger.info("Received response from Watch: \(response)")
        }, errorHandler: { error in
            logger.error("Error sending message to Watch: \(error.localizedDescription)")

            logger.warning("Sending data to Watch via Guaranteed Delivery channel")
            self.session.transferUserInfo(message)
        })
    }
    
    func sendComplicationsUpdateMessageToWatch(value: Int) {
        guard session.isPaired else {
            return logger.error("Watch not paired!")
        }
        
        if session.isComplicationEnabled == false {
            logger.warning("Complications are disabled on Watch")
        }
        
        logger.info("Sending Complications value to Watch: \(value)")

        let message = watchMessage(value: value)
        session.transferCurrentComplicationUserInfo(message)
    }
    
    private func watchMessage(value: Int) -> [String: Any] {
        ["value": value]
    }
}
#endif

// MARK: - watchOS

#if os(watchOS)
extension WatchManager {

    private func handleMessage(_ message: [String : Any], replyHandler: (([String : Any]) -> Void)? = nil) {
        if let value = message["value"] as? Int {
            setCurrentValue(value)
            logger.info("Received updated value from iPhone: \"\(value)\"")

            Haptics.success()

            updateWidgetKiComplications()
        } else {
            Haptics.failure()

            logger.error("Invalid message received from iPhone: \(message)")
        }
    }

    private func updateWidgetKiComplications() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            guard case .success(let widgets) = result else {
                return logger.warning("No widgets are installed on Watch!")
            }

            let widgetsString = widgets.map { $0.kind + ".\($0.family)" }.joined(separator: ", ")
            logger.info("Reloading WidgetKit complications [\(widgetsString)]. Current value: \(self.currentValue)")

            widgets.map(\.kind).forEach { kind in
                WidgetCenter.shared.reloadTimelines(ofKind: kind)
            }
        }
    }
}
#endif

// MARK: - WCSessionDelegate

extension WatchManager: WCSessionDelegate {

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any],
        replyHandler: @escaping ([String : Any]) -> Void
    ) {
        #if os(watchOS)
        handleMessage(message, replyHandler: replyHandler)
        #else
        assertionFailure("Watch to iPhone communication not implemented!")
        #endif
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        #if os(watchOS)
        handleMessage(userInfo)
        #else
        assertionFailure("Watch to iPhone communication not implemented!")
        #endif
    }
    
    // MARK: - Session Lifecycle
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            logger.info("Watch session ACTIVATED")
        case .notActivated:
            logger.error("Watch session WASN'T activated")
        case .inactive:
            logger.warning("Watch session is INACTIVE")
        @unknown default:
            break
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        logger.warning("Watch session reachability did change: \(session.isReachable ? "✅REACHABLE" : "❌NOT REACHABLE")")
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        logger.info("Watch session did become ACTIVATE")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        logger.warning("Watch session did DEACTIVATE")
    }
    #endif
}
