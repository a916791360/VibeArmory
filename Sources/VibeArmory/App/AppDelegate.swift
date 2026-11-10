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

        print("VibeArmory started successfully.")
    }

    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        FloatingPanelController.shared.toggle()
        return true
    }

    public func applicationWillTerminate(_ notification: Notification) {
        HotKeyManager.shared.unregisterHotKey()
    }
}
