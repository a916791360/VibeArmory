import AppKit

@MainActor
public class AppDelegate: NSObject, NSApplicationDelegate {
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Prevent app from quitting when all windows close
        NSApp.setActivationPolicy(.accessory)

        // Setup UI & Hotkey
        StatusBarController.shared.setup()
        FloatingPanelController.shared.setup()
        HotKeyManager.shared.setup()

        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.antigravity.vibearmory.toggle"),
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                FloatingPanelController.shared.toggle()
            }
        }

        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.antigravity.vibearmory.action"),
            object: nil,
            queue: .main
        ) { notif in
            let action = notif.object as? String
            Task { @MainActor in
                if action == "add" || action == "settings" || action == "detail" {
                    NotificationCenter.default.post(name: .vibeArmoryOpenSettingsRequested, object: action)
                    FloatingPanelController.shared.show()
                } else if action == "menu" {
                    StatusBarController.shared.showContextMenu()
                } else {
                    FloatingPanelController.shared.toggle()
                }
            }
        }

        print("VibeArmory started successfully.")
    }

    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        FloatingPanelController.shared.toggle()
        return true
    }

    public func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            guard url.scheme?.lowercased() == "vibearmory" else { continue }
            let host = (url.host ?? url.path).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            Task { @MainActor in
                if host == "settings" || host == "add" || host == "detail" {
                    NotificationCenter.default.post(name: .vibeArmoryOpenSettingsRequested, object: host)
                    FloatingPanelController.shared.show()
                } else if host == "show" {
                    FloatingPanelController.shared.show()
                } else if host == "menu" {
                    StatusBarController.shared.showContextMenu()
                } else {
                    FloatingPanelController.shared.toggle()
                }
            }
        }
    }

    public func applicationWillTerminate(_ notification: Notification) {
        HotKeyManager.shared.unregisterHotKey()
    }
}
