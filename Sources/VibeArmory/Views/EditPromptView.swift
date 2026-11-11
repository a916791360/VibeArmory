import SwiftUI

public struct EditPromptView: View {
    @EnvironmentObject private var store: PromptStore

    public let existingItem: PromptItem?
    public let onDismiss: () -> Void

    @State private var title: String = ""
    @State private var symptom: String = ""
    @State private var category: PromptCategory = .custom
    @State private var promptContent: String = ""

    public init(existingItem: PromptItem? = nil, onDismiss: @escaping () -> Void) {
        self.existingItem = existingItem
        self.onDismiss = onDismiss
        _title = State(initialValue: existingItem?.title ?? "")
        _symptom = State(initialValue: existingItem?.symptom ?? "")
        _category = State(initialValue: existingItem?.category ?? .custom)
        _promptContent = State(initialValue: existingItem?.promptContent ?? "")
    }

    public var body: some View {
        ZStack {
            // True Liquid Glass with translucent milky backdrop
            VisualEffectView(material: .popover, blendingMode: .behindWindow, state: .active)
                .ignoresSafeArea()
            Color(nsColor: .controlBackgroundColor).opacity(0.55)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                // Header Bar
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(existingItem == nil ? "新增自定义武器" : "编辑武器")
                            .font(.system(size: 16, weight: .bold))

                        Text("定制属于你的高维思考框架，按痛点症状秒级装弹")
                            .font(.system(size: 11.5))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        HStack(spacing: 4) {
                            Text("取消")
                            Text("Esc")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .padding(.horizontal, 4.5)
                                .padding(.vertical, 1.5)
                                .background(Color.primary.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 3.5, style: .continuous))
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 5)
                        .background(Color(nsColor: .controlBackgroundColor).opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                // Row 1: Title (left) + Category (right) with identical unified glass boxes
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("武器标题 (大白话)")
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            Image(systemName: "pencil.line")
                                .font(.system(size: 11.5))
                                .foregroundColor(.secondary)

                            TextField("例如: 重构状态机与单向数据流", text: $title)
                                .textFieldStyle(.plain)
                                .font(.system(size: 12.5))
                        }
                        .padding(.horizontal, 10)
                        .frame(height: 34)
                        .background(Color(nsColor: .textBackgroundColor).opacity(0.85))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color(nsColor: .separatorColor).opacity(0.35), lineWidth: 0.8)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("所属战区")
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundColor(.secondary)

                        // Unified visual selection box matching title box
                        Menu {
                            ForEach(PromptCategory.allCases.filter { $0 != .all }) { cat in
                                Button(action: { category = cat }) {
                                    HStack {
                                        Text(cat.rawValue)
                                        if category == cat {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 11.5, weight: .medium))
                                    .foregroundColor(category.color)
                                    .frame(width: 14)

                                Text(category.rawValue)
                                    .font(.system(size: 12.5, weight: .medium))
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 10)
                            .frame(height: 34)
                            .background(Color(nsColor: .textBackgroundColor).opacity(0.85))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color(nsColor: .separatorColor).opacity(0.35), lineWidth: 0.8)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .frame(width: 170)
                    }
                }

                // Row 2: Symptom Description (Full Width) with matching unified glass box
                VStack(alignment: .leading, spacing: 5) {
                    Text("痛点症状 (触发场景与卡壳描述)")
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 11.5))
                            .foregroundColor(.secondary)

                        TextField("例如: 状态管理混乱、界面不刷新、死循环打补丁、改了A坏了B", text: $symptom)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12.5))
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 34)
                    .background(Color(nsColor: .textBackgroundColor).opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color(nsColor: .separatorColor).opacity(0.35), lineWidth: 0.8)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                // Row 3: Prompt Content Editor (Expanded Height, Airy Light Glass)
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("提示词内容 (零输入高维指令体系)")
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("建议零输入设计 · 命令 Agent 自行扫描 Git Diff / 规则 / 架构")
                            .font(.system(size: 10.5))
                            .foregroundColor(.secondary.opacity(0.7))
                    }

                    ZStack(alignment: .topLeading) {
                        if promptContent.isEmpty {
                            Text("在这里粘贴或编写你的高维提示词...\n建议以第一性原理直接命令 Agent：\n1. 严禁盲目直接写代码\n2. 深入扫描当前工作区已有的真实代码与架构\n3. 按严重程度分步拆解并给出最小侵入式方案")
                                .font(.system(size: 12.5, design: .monospaced))
                                .foregroundColor(.secondary.opacity(0.55))
                                .lineSpacing(4)
                                .padding(12)
                        }

                        TextEditor(text: $promptContent)
                            .font(.system(size: 12.5, design: .monospaced))
                            .lineSpacing(4)
                            .padding(8)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color(nsColor: .separatorColor).opacity(0.25), lineWidth: 0.8)
                    )
                }

                // Bottom Action Bar
                HStack(alignment: .center) {
                    if let item = existingItem, !item.isPreset {
                        Button(role: .destructive) {
                            store.delete(id: item.id)
                            onDismiss()
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "trash")
                                    .font(.system(size: 11))
                                Text("删除此武器")
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.red.opacity(0.9))
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color.red.opacity(0.25), lineWidth: 0.8)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    Button("取消 (Esc)") {
                        onDismiss()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 12.5))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6.5)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Button(action: save) {
                        HStack(spacing: 5) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                            Text("保存并生效 (Enter)")
                                .font(.system(size: 12.5, weight: .semibold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6.5)
                        .background(
                            LinearGradient(
                                colors: [Color.accentColor, Color.accentColor.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .shadow(color: Color.accentColor.opacity(0.35), radius: 5, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || promptContent.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(title.trimmingCharacters(in: .whitespaces).isEmpty || promptContent.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                }
                .padding(.top, 2)
            }
            .padding(22)
        }
        .frame(width: 730, height: 510)
    }

    private func save() {
        if let existing = existingItem {
            var updated = existing
            updated.title = title
            updated.symptom = symptom
            updated.category = category
            updated.promptContent = promptContent
            store.update(updated)
        } else {
            store.add(
                title: title,
                symptom: symptom,
                category: category,
                promptContent: promptContent,
                icon: "star.fill"
            )
        }
        onDismiss()
    }
}
