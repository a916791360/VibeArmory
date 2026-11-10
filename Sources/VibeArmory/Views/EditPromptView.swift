import SwiftUI

public struct EditPromptView: View {
    @EnvironmentObject private var store: PromptStore

    public let existingItem: PromptItem?
    public let onDismiss: () -> Void

    @State private var title: String = ""
    @State private var symptom: String = ""
    @State private var category: PromptCategory = .custom
    @State private var promptContent: String = ""
    @State private var icon: String = "star.fill"

    public init(existingItem: PromptItem? = nil, onDismiss: @escaping () -> Void) {
        self.existingItem = existingItem
        self.onDismiss = onDismiss
        _title = State(initialValue: existingItem?.title ?? "")
        _symptom = State(initialValue: existingItem?.symptom ?? "")
        _category = State(initialValue: existingItem?.category ?? .custom)
        _promptContent = State(initialValue: existingItem?.promptContent ?? "")
        _icon = State(initialValue: existingItem?.icon ?? "star.fill")
    }

    public var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow, state: .active)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 13) {
                // Header
                HStack {
                    Text(existingItem == nil ? "新增自定义武器" : "编辑武器")
                        .font(.system(size: 16, weight: .bold))

                    Spacer()

                    Button("取消 (Esc)") {
                        onDismiss()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                }

                // Title & Symptom fields
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("武器标题 (大白话)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("例如: 重构状态机与单向流", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("痛点症状 (触发场景)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("例如: 状态混乱、界面不刷新、死循环", text: $symptom)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                // Category & Icon
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("分类")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Picker("", selection: $category) {
                            ForEach(PromptCategory.allCases.filter { $0 != .all }) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                        .labelsHidden()
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("SF 图标名称")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        HStack {
                            Image(systemName: icon)
                                .foregroundColor(.accentColor)
                            TextField("SF Symbol", text: $icon)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }

                // Prompt content
                VStack(alignment: .leading, spacing: 4) {
                    Text("提示词内容 (建议零输入设计，让 Agent 自行提取项目上下文)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    TextEditor(text: $promptContent)
                        .font(.system(size: 12, design: .monospaced))
                        .frame(height: 185)
                        .padding(6)
                        .background(Color.black.opacity(0.22))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 0.8))
                }

                // Bottom Actions
                HStack {
                    if let item = existingItem, !item.isPreset {
                        Button(role: .destructive) {
                            store.delete(id: item.id)
                            onDismiss()
                        } label: {
                            Text("删除该武器")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    Button("取消") {
                        onDismiss()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 6)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Button("保存并生效") {
                        save()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 6)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || promptContent.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding(18)
        }
        .frame(width: 650, height: 490)
    }

    private func save() {
        if let existing = existingItem {
            var updated = existing
            updated.title = title
            updated.symptom = symptom
            updated.category = category
            updated.promptContent = promptContent
            updated.icon = icon
            store.update(updated)
        } else {
            store.add(
                title: title,
                symptom: symptom,
                category: category,
                promptContent: promptContent,
                icon: icon
            )
        }
        onDismiss()
    }
}
