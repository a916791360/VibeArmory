import Carbon
import Cocoa

public class HotKeyManager {
    public static let shared = HotKeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x5641524D), id: 1) // 'VARM' for VibeArmory
    private let userDefaultsKey = "VibeArmory_SavedHotKey"

    public private(set) var currentOption: HotKeyOption = .optionP

    public var currentKeyDisplayString: String {
        currentOption.displayString
    }

    private init() {
        loadSavedHotKey()
    }

    public func setup() {
        registerHotKey()
    }

    private func loadSavedHotKey() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let saved = try? JSONDecoder().decode(HotKeyOption.self, from: data) {
            self.currentOption = saved
        } else {
            self.currentOption = .optionP
        }
    }

    public func updateHotKey(_ option: HotKeyOption) {
        self.currentOption = option
        if let data = try? JSONEncoder().encode(option) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
        registerHotKey()
        NotificationCenter.default.post(name: .vibeArmoryHotKeyChanged, object: option)
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

        let status = RegisterEventHotKey(
            currentOption.keyCode,
            currentOption.carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status != noErr {
            print("VibeArmory: Failed to register hotkey \(currentOption.displayString). Status: \(status). Falling back to Cmd+Option+P...")
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
