import Foundation
import Carbon
import AppKit

public struct HotKeyOption: Identifiable, Hashable, Codable {
    public var id: String { name }
    public let name: String
    public let displayString: String
    public let keyCode: UInt32
    public let carbonModifiers: UInt32

    public static let optionP = HotKeyOption(
        name: "Option + P (默认推荐)",
        displayString: "⌥P",
        keyCode: UInt32(kVK_ANSI_P),
        carbonModifiers: UInt32(optionKey)
    )

    public static let optionSpace = HotKeyOption(
        name: "Option + Space (极速直达)",
        displayString: "⌥␣",
        keyCode: UInt32(kVK_Space),
        carbonModifiers: UInt32(optionKey)
    )

    public static let cmdOptionP = HotKeyOption(
        name: "Command + Option + P (防冲突)",
        displayString: "⌘⌥P",
        keyCode: UInt32(kVK_ANSI_P),
        carbonModifiers: UInt32(cmdKey | optionKey)
    )

    public static let controlSpace = HotKeyOption(
        name: "Control + Space (经典快捷)",
        displayString: "⌃␣",
        keyCode: UInt32(kVK_Space),
        carbonModifiers: UInt32(controlKey)
    )

    public static let controlOptionP = HotKeyOption(
        name: "Control + Option + P",
        displayString: "⌃⌥P",
        keyCode: UInt32(kVK_ANSI_P),
        carbonModifiers: UInt32(controlKey | optionKey)
    )

    public static let allPresets: [HotKeyOption] = [
        .optionP,
        .optionSpace,
        .cmdOptionP,
        .controlSpace,
        .controlOptionP
    ]

    public static func from(event: NSEvent) -> HotKeyOption? {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        var carbonMods: UInt32 = 0

        if flags.contains(.command) { carbonMods |= UInt32(cmdKey) }
        if flags.contains(.option) { carbonMods |= UInt32(optionKey) }
        if flags.contains(.control) { carbonMods |= UInt32(controlKey) }
        if flags.contains(.shift) { carbonMods |= UInt32(shiftKey) }

        // Must have at least one modifier key
        guard carbonMods != 0 else { return nil }

        // Ignore modifier-only events
        let keyCode = UInt32(event.keyCode)
        guard keyCode != 54 && keyCode != 55 && keyCode != 56 && keyCode != 58 && keyCode != 59 && keyCode != 60 && keyCode != 61 && keyCode != 62 else {
            return nil
        }

        var modSymbols = ""
        if flags.contains(.control) { modSymbols += "⌃" }
        if flags.contains(.option) { modSymbols += "⌥" }
        if flags.contains(.shift) { modSymbols += "⇧" }
        if flags.contains(.command) { modSymbols += "⌘" }

        let keyChar = keyString(for: event.keyCode)
        let display = "\(modSymbols)\(keyChar)"

        return HotKeyOption(
            name: "自定义 (\(display))",
            displayString: display,
            keyCode: keyCode,
            carbonModifiers: carbonMods
        )
    }

    public static func keyString(for keyCode: UInt16) -> String {
        switch Int(keyCode) {
        case kVK_Space: return "␣"
        case kVK_Return: return "↵"
        case kVK_Tab: return "⇥"
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        case kVK_ANSI_Slash: return "/"
        case kVK_ANSI_Backslash: return "\\"
        case kVK_ANSI_Period: return "."
        case kVK_ANSI_Comma: return ","
        case kVK_ANSI_Semicolon: return ";"
        default: return "Key\(keyCode)"
        }
    }
}
