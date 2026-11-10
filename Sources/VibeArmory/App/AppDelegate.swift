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

        print("VibeArmory started successfully.")
    }

    public func applicationWillTerminate(_ notification: Notification) {
        HotKeyManager.shared.unregisterHotKey()
    }
}
