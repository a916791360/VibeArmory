import Foundation

public struct PromptItem: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var title: String
    public var symptom: String
    public var category: PromptCategory
    public var promptContent: String
    public var icon: String
    public var isPreset: Bool
    public var usageCount: Int
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        symptom: String,
        category: PromptCategory,
        promptContent: String,
        icon: String = "command",
        isPreset: Bool = false,
        usageCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.symptom = symptom
        self.category = category
        self.promptContent = promptContent
        self.icon = icon
        self.isPreset = isPreset
        self.usageCount = usageCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
