import Foundation

public enum PromptCategory: String, Codable, CaseIterable, Identifiable {
    case all = "全部"
    case architecture = "架构重构"
    case debug = "排错会诊"
    case rules = "规范门禁"
    case visual = "视觉规范"
    case alignment = "需求对齐"
    case learning = "认知拆解"
    case custom = "自定义"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .all: return "sparkles"
        case .architecture: return "square.stack.3d.up.fill"
        case .debug: return "stethoscope"
        case .rules: return "shield.lefthalf.filled"
        case .visual: return "paintpalette.fill"
        case .alignment: return "compass.drawing"
        case .learning: return "brain.head.profile"
        case .custom: return "star.fill"
        }
    }

    public var badgeColor: String {
        switch self {
        case .all: return "purple"
        case .architecture: return "blue"
        case .debug: return "green"
        case .rules: return "orange"
        case .visual: return "pink"
        case .alignment: return "indigo"
        case .learning: return "teal"
        case .custom: return "yellow"
        }
    }
}
