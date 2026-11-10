import AppKit
import SwiftUI
import Combine

@MainActor
public class FloatingPanelController: NSObject, NSWindowDelegate {
    public static let shared = FloatingPanelController()

    private var panel: FloatingPanel?
    private var previousApp: NSRunningApplication?
    private var cancellables = Set<AnyCancellable>()

    public var isVisible: Bool {
        panel?.isVisible ?? false
    }

    private override init() {
        super.init()
        setupNotifications()
    }

    public func setup() {
        let hudView = FloatingHUDView()
            .environmentObject(PromptStore.shared)

        let hostingView = NSHostingView(rootView: hudView)

        let initialRect = NSRect(x: 0, y: 0, width: 650, height: 490)
        let panel = FloatingPanel(contentRect: initialRect)
        panel.contentView = hostingView
        panel.delegate = self

        self.panel = panel
    }

    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .vibeArmoryToggleRequested)
            .sink { [weak self] _ in
                self?.toggle()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .vibeArmoryPromptCopied)
            .sink { [weak self] _ in
                // Dismiss after a very short delay so user sees feedback, then refocus previous app
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self?.hide(restoreFocus: true)
                }
            }
            .store(in: &cancellables)
    }

    public func toggle() {
        if isVisible {
            hide(restoreFocus: true)
        } else {
            show()
        }
    }

    public func show() {
        guard let panel = panel else {
            setup()
            show()
            return
        }

        // Save current frontmost application so we can restore focus upon paste
        if let frontApp = NSWorkspace.shared.frontmostApplication,
           frontApp.bundleIdentifier != Bundle.main.bundleIdentifier {
            self.previousApp = frontApp
        }

        // Center on the active screen
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let x = screenRect.midX - (panel.frame.width / 2)
            let y = screenRect.midY - (panel.frame.height / 2) + 60 // slightly higher than center
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.16
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1.0
        }
    }

    public func hide(restoreFocus: Bool = true) {
        guard let panel = panel, panel.isVisible else { return }
        let targetApp = self.previousApp

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.12
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0.0
        }, completionHandler: {
            DispatchQueue.main.async {
                panel.orderOut(nil)
                if restoreFocus {
                    targetApp?.activate(options: [.activateIgnoringOtherApps])
                }
            }
        })
    }

    // Auto hide when clicking outside to another application
    public func windowDidResignKey(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if let frontApp = NSWorkspace.shared.frontmostApplication,
               frontApp.bundleIdentifier != Bundle.main.bundleIdentifier,
               self.panel?.isKeyWindow == false {
                self.hide(restoreFocus: false)
            }
        }
    }
}
