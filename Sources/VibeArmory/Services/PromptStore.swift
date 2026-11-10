import Foundation
import Combine

@MainActor
public class PromptStore: ObservableObject {
    public static let shared = PromptStore()

    @Published public var items: [PromptItem] = []
    @Published public var searchText: String = ""
    @Published public var selectedCategory: PromptCategory = .all

    private let storageURL: URL

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("VibeArmory", isDirectory: true)

        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        self.storageURL = appDir.appendingPathComponent("prompts.json")

        load()
    }

    public var filteredItems: [PromptItem] {
        items.filter { item in
            let matchesCategory = (selectedCategory == .all) || (item.category == selectedCategory)
            if !matchesCategory { return false }

            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return true
            }

            let query = searchText.lowercased()
            return item.title.lowercased().contains(query) ||
                   item.symptom.lowercased().contains(query) ||
                   item.promptContent.lowercased().contains(query)
        }
    }

    public func load() {
        if let data = try? Data(contentsOf: storageURL),
           let decoded = try? JSONDecoder().decode([PromptItem].self, from: data),
           !decoded.isEmpty {
            let customItems = decoded.filter { !$0.isPreset }
            let existingPresetIDs = Set(decoded.filter { $0.isPreset }.map { $0.id })
            let newPresetIDs = Set(PresetPrompts.items.map { $0.id })

            if existingPresetIDs != newPresetIDs {
                // Auto-upgrade official presets while preserving user's custom prompts
                self.items = PresetPrompts.items + customItems
                save()
            } else {
                self.items = decoded
            }
        } else {
            // First time launch: use presets
            self.items = PresetPrompts.items
            save()
        }
    }

    public func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(items)
            try data.write(to: storageURL, options: [.atomic])
        } catch {
            print("VibeArmory: Failed to save prompts: \(error)")
        }
    }

    public func add(
        title: String,
        symptom: String,
        category: PromptCategory,
        promptContent: String,
        icon: String = "star.fill"
    ) {
        let newItem = PromptItem(
            title: title,
            symptom: symptom,
            category: category,
            promptContent: promptContent,
            icon: icon,
            isPreset: false
        )
        items.append(newItem)
        save()
    }

    public func update(_ item: PromptItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            var updated = item
            updated.updatedAt = Date()
            items[index] = updated
            save()
        }
    }

    public func delete(id: UUID) {
        items.removeAll(where: { $0.id == id })
        save()
    }

    public func resetToPresets() {
        // Keeps presets fresh, and preserves any custom added items if user wants, or full reset
        self.items = PresetPrompts.items
        save()
    }

    public func incrementUsage(id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].usageCount += 1
            save()
        }
    }
}
