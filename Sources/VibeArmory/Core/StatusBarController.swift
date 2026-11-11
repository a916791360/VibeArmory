import AppKit

@MainActor
public class StatusBarController: NSObject {
    public static let shared = StatusBarController()

    private var statusItem: NSStatusItem?

    public override init() {
        super.init()
    }

    public func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else { return }

        // Configure system image icon
        let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        if let image = NSImage(systemSymbolName: "bolt.terminal.fill", accessibilityDescription: "VibeArmory")?.withSymbolConfiguration(config) {
            image.isTemplate = true
            button.image = image
        } else if let fallback = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "VibeArmory") {
            fallback.isTemplate = true
            button.image = fallback
        }

        button.target = self
        button.action = #selector(statusItemClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent

        if event?.type == .rightMouseUp || (event?.modifierFlags.contains(.control) == true) {
            showContextMenu()
        } else {
            FloatingPanelController.shared.toggle()
        }
    }

    public func showContextMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.delegate = self

        let iconConfig = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)

        let hotKeyDisplay = HotKeyManager.shared.currentKeyDisplayString
        let toggleItem = NSMenuItem(title: "唤起军火库 (\(hotKeyDisplay))", action: #selector(toggleHUD), keyEquivalent: "")
        toggleItem.target = self
        if let img = NSImage(systemSymbolName: "bolt.fill", accessibilityDescription: "唤起")?.withSymbolConfiguration(iconConfig) {
            img.isTemplate = true
            toggleItem.image = img
        }
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let addItem = NSMenuItem(title: "新增自定义武器...", action: #selector(openAddPrompt), keyEquivalent: "")
        addItem.target = self
        if let img = NSImage(systemSymbolName: "plus.circle", accessibilityDescription: "新增")?.withSymbolConfiguration(iconConfig) {
            img.isTemplate = true
            addItem.image = img
        }
        menu.addItem(addItem)

        let settingsItem = NSMenuItem(title: "偏好设置...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        if let img = NSImage(systemSymbolName: "gearshape", accessibilityDescription: "设置")?.withSymbolConfiguration(iconConfig) {
            img.isTemplate = true
            settingsItem.image = img
        }
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "退出 VibeArmory", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        if let img = NSImage(systemSymbolName: "power", accessibilityDescription: "退出")?.withSymbolConfiguration(iconConfig) {
            img.isTemplate = true
            quitItem.image = img
        }
        menu.addItem(quitItem)

        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
    }

    @objc private func toggleHUD() {
        FloatingPanelController.shared.toggle()
    }

    @objc private func openAddPrompt() {
        NotificationCenter.default.post(name: .vibeArmoryOpenSettingsRequested, object: "add")
        FloatingPanelController.shared.show()
    }

    @objc private func openSettings() {
        NotificationCenter.default.post(name: .vibeArmoryOpenSettingsRequested, object: "settings")
        FloatingPanelController.shared.show()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}

extension StatusBarController: NSMenuDelegate {
    public func menuDidClose(_ menu: NSMenu) {
        statusItem?.menu = nil
    }
}
