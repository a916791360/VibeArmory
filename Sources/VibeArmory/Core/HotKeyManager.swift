import Carbon
import Cocoa

public class HotKeyManager {
    public static let shared = HotKeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x5641524D), id: 1) // 'VARM' for VibeArmory

    private init() {}

    public func setup() {
        registerHotKey()
    }

    public func registerHotKey() {
        unregisterHotKey()

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let handlerBlock: EventHandlerUPP = { _, inEvent, _ in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .vibeArmoryToggleRequested, object: nil)
            }
            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            handlerBlock,
            1,
            &eventType,
            nil,
            &eventHandler
        )

        // Register Option + P (keyCode 35 is 'P')
        // optionKey in Carbon is (1 << 11) = 2048
        let status = RegisterEventHotKey(
            UInt32(kVK_ANSI_P),
            UInt32(optionKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status != noErr {
            print("VibeArmory: Failed to register Option+P hotkey. Status: \(status). Trying Cmd+Option+P...")
            // Fallback to Cmd + Option + P
            _ = RegisterEventHotKey(
                UInt32(kVK_ANSI_P),
                UInt32(cmdKey | optionKey),
                hotKeyID,
                GetApplicationEventTarget(),
                0,
                &hotKeyRef
            )
        }
    }

    public func unregisterHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }

    deinit {
        unregisterHotKey()
    }
}
