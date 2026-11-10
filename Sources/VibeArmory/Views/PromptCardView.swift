import SwiftUI

public struct PromptCardView: View {
    public let item: PromptItem
    public let isSelected: Bool
    public let onSelect: () -> Void
    public let onCopy: () -> Void
    public let onDetail: () -> Void
    public let onEdit: () -> Void

    @State private var isHovered = false

    public var body: some View {
        HStack(spacing: 0) {
            // Title & Symptom hierarchy
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(item.title)
                        .font(.system(size: 13.5, weight: .semibold, design: .default))
                        .foregroundColor(.primary)

                    if item.isPreset {
                        Text("官方")
                            .font(.system(size: 9.5, weight: .medium))
                            .padding(.horizontal, 5.5)
                            .padding(.vertical, 1.5)
                            .background(Color.primary.opacity(0.06))
                            .foregroundColor(.secondary)
                            .clipShape(Capsule())
                    }

                    Spacer()

                    // Category Pill
                    Text(item.category.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2.5)
                        .background(badgeColor.opacity(0.12))
                        .foregroundColor(badgeColor)
                        .overlay(
                            Capsule()
                                .stroke(badgeColor.opacity(0.25), lineWidth: 0.5)
                        )
                        .clipShape(Capsule())
                }

                Text(item.symptom)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            // Interactive Action Buttons
            if isHovered || isSelected {
                HStack(spacing: 6) {
                    Button(action: onDetail) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(6)
                            .background(Color.primary.opacity(0.07))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .help("查看完整提示词 (Space)")

                    Button(action: onCopy) {
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 9))
                            Text(isSelected ? "↵ 装弹" : "装弹")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(
                                colors: [Color.accentColor, Color.accentColor.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        .shadow(color: Color.accentColor.opacity(0.4), radius: 5, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .help("复制并关闭 (Enter)")
                }
                .padding(.leading, 12)
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(cardBorderGradient, lineWidth: isSelected ? 1.5 : 0.8)
        )
        .overlay(
            // Specular top highlight on selected card
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.35), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            ),
                            lineWidth: 1
                        )
                }
            }
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.24, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            onSelect()
            onCopy()
        }
    }

    private var cardBackgroundColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.16)
        } else if isHovered {
            return Color(nsColor: .controlBackgroundColor).opacity(0.55)
        } else {
            return Color(nsColor: .controlBackgroundColor).opacity(0.28)
        }
    }

    private var cardBorderGradient: LinearGradient {
        if isSelected {
            return LinearGradient(
                colors: [Color.accentColor.opacity(0.8), Color.accentColor.opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isHovered {
            return LinearGradient(
                colors: [Color.white.opacity(0.25), Color.white.opacity(0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.white.opacity(0.12), Color.white.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var badgeColor: Color {
        item.category.color
    }
}
