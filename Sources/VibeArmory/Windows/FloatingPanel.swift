import AppKit

public class FloatingPanel: NSPanel {
    public init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )

        self.isFloatingPanel = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.isReleasedWhenClosed = false
        self.hasShadow = true
        self.backgroundColor = .clear
        self.isOpaque = false
    }

    public override var canBecomeKey: Bool {
        return true
    }

    public override var canBecomeMain: Bool {
        return true
    }

    public override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown {
            switch event.keyCode {
            case 125: // Down arrow
                NotificationCenter.default.post(name: .vibeArmoryMoveSelectionDown, object: nil)
                return
            case 126: // Up arrow
                NotificationCenter.default.post(name: .vibeArmoryMoveSelectionUp, object: nil)
                return
            case 36, 76: // Return or Keypad Enter
                NotificationCenter.default.post(name: .vibeArmoryConfirmSelection, object: nil)
                return
            case 53: // Esc
                NotificationCenter.default.post(name: .vibeArmoryDismissOrBack, object: nil)
                return
            case 43 where event.modifierFlags.contains(.command): // Command + , (Preferences)
                NotificationCenter.default.post(name: .vibeArmoryOpenSettingsRequested, object: "settings")
                return
            case 45 where event.modifierFlags.contains(.command): // Command + N (New Custom Weapon)
                NotificationCenter.default.post(name: .vibeArmoryOpenSettingsRequested, object: "add")
                return
            case 34 where event.modifierFlags.contains(.command): // Command + I (Get Info / Detail)
                NotificationCenter.default.post(name: .vibeArmoryOpenSettingsRequested, object: "detail")
                return
            default:
                break
            }
        }
        super.sendEvent(event)
    }

    public override func cancelOperation(_ sender: Any?) {
        NotificationCenter.default.post(name: .vibeArmoryDismissOrBack, object: nil)
    }
}
