import Foundation
import SwiftUI

public enum PromptCategory: String, Codable, CaseIterable, Identifiable {
    case all = "全部"
    case research = "动手前调研"
    case refactor = "越改越乱"
    case debug = "报错死循环"
    case defense = "别瞎动乱改"
    case review = "上线前挑刺"
    case visual = "界面太塑料"
    case concept = "看不懂底层"
    case custom = "自定义"

    public var id: String { rawValue }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw {
        case "动手前调研", "research": self = .research
        case "越改越乱", "架构重构", "refactor": self = .refactor
        case "报错死循环", "排错会诊", "debug": self = .debug
        case "别瞎动乱改", "规范门禁", "guardrail", "defense": self = .defense
        case "上线前挑刺", "review": self = .review
        case "界面太塑料", "视觉规范", "visual": self = .visual
        case "看不懂底层", "认知拆解", "cognition", "concept": self = .concept
        case "自定义", "custom": self = .custom
        default: self = .custom
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var icon: String {
        switch self {
        case .all: return "sparkles"
        case .research: return "binoculars.fill"
        case .refactor: return "hammer.fill"
        case .debug: return "ant.fill"
        case .defense: return "hand.raised.fill"
        case .review: return "checkmark.shield.fill"
        case .visual: return "paintpalette.fill"
        case .concept: return "lightbulb.fill"
        case .custom: return "star.fill"
        }
    }

    public var badgeColor: String {
        switch self {
        case .all: return "purple"
        case .research: return "cyan"
        case .refactor: return "blue"
        case .debug: return "red"
        case .defense: return "orange"
        case .review: return "indigo"
        case .visual: return "pink"
        case .concept: return "teal"
        case .custom: return "yellow"
        }
    }

    public var color: Color {
        switch self {
        case .all: return .purple
        case .research: return .cyan
        case .refactor: return .blue
        case .debug: return .red
        case .defense: return .orange
        case .review: return .indigo
        case .visual: return .pink
        case .concept: return .teal
        case .custom: return .yellow
        }
    }
}
