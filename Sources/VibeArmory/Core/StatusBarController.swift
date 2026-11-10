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

        menu.addItem(NSMenuItem(title: "唤起军火库 (⌥P)", action: #selector(toggleHUD), keyEquivalent: "p"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "新增自定义提示词...", action: #selector(openAddPrompt), keyEquivalent: "n"))
        menu.addItem(NSMenuItem(title: "一键恢复官方预置", action: #selector(resetPresets), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "关于 VibeArmory", action: #selector(openAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出 VibeArmory", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil // Restore toggle behavior after click
    }

    @objc private func toggleHUD() {
        FloatingPanelController.shared.toggle()
    }

    @objc private func openAddPrompt() {
        NotificationCenter.default.post(name: .vibeArmoryOpenSettingsRequested, object: "add")
        FloatingPanelController.shared.show()
    }

    @objc private func resetPresets() {
        PromptStore.shared.resetToPresets()
        let alert = NSAlert()
        alert.messageText = "已恢复官方预置"
        alert.informativeText = "5 大零输入王炸提示词已重置为最新官方版本。"
        alert.alertStyle = .informational
        alert.runModal()
    }

    @objc private func openAbout() {
        let alert = NSAlert()
        alert.messageText = "VibeArmory · Vibe 军火库"
        alert.informativeText = "专为 Vibe Coding 与 Agent 打造的纯原生认知协同外挂。\n版本: v1.0.0 (MVP)\n作者: a916791360"
        alert.alertStyle = .informational
        alert.runModal()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
