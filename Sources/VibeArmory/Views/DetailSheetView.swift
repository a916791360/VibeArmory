import SwiftUI

public struct DetailSheetView: View {
    public let item: PromptItem
    public let onCopy: () -> Void
    public let onDismiss: () -> Void

    public var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow, state: .active)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                // Header with back button
                HStack(spacing: 12) {
                    Button(action: onDismiss) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .semibold))
                            Text("返回列表")
                                .font(.system(size: 13))
                        }
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4.5)
                        .background(Color.accentColor.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("按 ⎋ 返回 · 按 ↵ 装弹")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                // Title & Symptom card
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(Color.accentColor.opacity(0.18))
                            .frame(width: 42, height: 42)
                            .overlay(
                                RoundedRectangle(cornerRadius: 11, style: .continuous)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.8)
                            )

                        Image(systemName: item.icon)
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 7) {
                            Text(item.title)
                                .font(.system(size: 16, weight: .bold))

                            Text(item.category.rawValue)
                                .font(.system(size: 10.5, weight: .medium))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Color.primary.opacity(0.06))
                                .clipShape(Capsule())
                        }

                        Text("痛点症状：\(item.symptom)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(13)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.8)
                )

                // Content preview (expands nicely)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("零输入高维指令体系 (全量展开未压缩)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("支持自由框选")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary.opacity(0.7))
                    }

                    ScrollView {
                        Text(item.promptContent)
                            .font(.system(size: 12.5, design: .monospaced))
                            .lineSpacing(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .textSelection(.enabled)
                    }
                    .background(Color.black.opacity(0.22))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 0.8)
                    )
                }

                // Footer actions
                HStack {
                    Text("累计装弹 \(item.usageCount) 次 · 自动关联工作区 Context")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Spacer()

                    Button("返回 (Esc)") {
                        onDismiss()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 6)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Button(action: {
                        onCopy()
                        onDismiss()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10))
                            Text("立即装弹 (Enter)")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .shadow(color: Color.accentColor.opacity(0.35), radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(18)
        }
        .frame(width: 650, height: 490)
    }
}
