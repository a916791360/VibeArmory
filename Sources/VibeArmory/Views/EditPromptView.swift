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
            VisualEffectView(material: .popover, blendingMode: .behindWindow, state: .active)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                // Header Bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(existingItem == nil ? "新增自定义武器" : "编辑武器")
                            .font(.system(size: 16, weight: .bold))

                        Text("定制属于你的高维思考框架，随时一键装弹")
                            .font(.system(size: 11.5))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        HStack(spacing: 4) {
                            Text("取消")
                            Text("Esc")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.primary.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 3.5, style: .continuous))
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(nsColor: .controlBackgroundColor).opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                // Row 1: Title (65%) + Category (35%)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4.5) {
                        Text("武器标题 (大白话)")
                            .font(.system(size: 11.5, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("例如: 重构状态机与单向数据流", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 4.5) {
                        Text("所属战区")
                            .font(.system(size: 11.5, weight: .medium))
                            .foregroundColor(.secondary)
                        Picker("", selection: $category) {
                            ForEach(PromptCategory.allCases.filter { $0 != .all }) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .frame(width: 140)
                    }
                }

                // Row 2: Symptom Description (Full Width)
                VStack(alignment: .leading, spacing: 4.5) {
                    Text("痛点症状 (触发场景与卡壳描述)")
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(.secondary)
                    TextField("例如: 状态管理混乱、界面不刷新、死循环打补丁、改了A坏了B", text: $symptom)
                        .textFieldStyle(.roundedBorder)
                }

                // Row 3: Prompt Content Editor (Expanded Height)
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("提示词内容 (建议零输入设计)")
                            .font(.system(size: 11.5, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("命令 Agent 自行扫描 Git Diff / 规则 / 架构")
                            .font(.system(size: 10.5))
                            .foregroundColor(.secondary.opacity(0.7))
                    }

                    TextEditor(text: $promptContent)
                        .font(.system(size: 12.5, design: .monospaced))
                        .lineSpacing(4)
                        .padding(8)
                        .background(Color.black.opacity(0.24))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 0.8)
                        )
                }

                // Bottom Action Bar
                HStack {
                    if let item = existingItem, !item.isPreset {
                        Button(role: .destructive) {
                            store.delete(id: item.id)
                            onDismiss()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "trash")
                                    .font(.system(size: 11))
                                Text("删除此武器")
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.red.opacity(0.9))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    Button("取消") {
                        onDismiss()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 12.5))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6.5)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Button("保存并生效") {
                        save()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 12.5, weight: .semibold))
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
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || promptContent.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.top, 2)
            }
            .padding(20)
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
            store.update(updated)
        } else {
            store.add(
                title: title,
                symptom: symptom,
                category: category,
                promptContent: promptContent,
                icon: "command"
            )
        }
        onDismiss()
    }
}
