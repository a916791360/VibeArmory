import AppKit

public extension Notification.Name {
    static let vibeArmoryPromptCopied = Notification.Name("VibeArmoryPromptCopied")
    static let vibeArmoryToggleRequested = Notification.Name("VibeArmoryToggleRequested")
    static let vibeArmoryOpenSettingsRequested = Notification.Name("VibeArmoryOpenSettingsRequested")
    static let vibeArmoryMoveSelectionDown = Notification.Name("VibeArmoryMoveSelectionDown")
    static let vibeArmoryMoveSelectionUp = Notification.Name("VibeArmoryMoveSelectionUp")
    static let vibeArmoryConfirmSelection = Notification.Name("VibeArmoryConfirmSelection")
    static let vibeArmoryDismissOrBack = Notification.Name("VibeArmoryDismissOrBack")
    static let vibeArmoryHotKeyChanged = Notification.Name("VibeArmoryHotKeyChanged")
}

public class ClipboardManager {
    public static let shared = ClipboardManager()

    private init() {}

    public func copy(prompt: PromptItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(prompt.promptContent, forType: .string)

        // Subtle trackpad tactile feedback (silent & refined)
        NSHapticFeedbackManager.defaultPerformer.perform(
            .generic,
            performanceTime: .now
        )

        let autoDismiss = UserDefaults.standard.object(forKey: "VibeArmory_AutoDismissOnCopy") as? Bool ?? true
        if autoDismiss {
            // Notification for UI Toast / auto-dismiss
            NotificationCenter.default.post(
                name: .vibeArmoryPromptCopied,
                object: prompt
            )
        }
    }
}
