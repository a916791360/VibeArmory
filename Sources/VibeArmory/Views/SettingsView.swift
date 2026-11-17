import SwiftUI
import Carbon
import AppKit

public struct SettingsView: View {
    public let onDismiss: () -> Void

    @State private var selectedOption: HotKeyOption = HotKeyManager.shared.currentOption
    @State private var isRecording = false
    @State private var eventMonitor: Any?
    @State private var recordHint = "点击录制自定义快捷键"
    @State private var autoDismissOnCopy: Bool = UserDefaults.standard.object(forKey: "VibeArmory_AutoDismissOnCopy") as? Bool ?? true
    @State private var feedbackText: String?

    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow, state: .active)
                .ignoresSafeArea()
            Color(nsColor: .windowBackgroundColor).opacity(0.85)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                // Header
                HStack(alignment: .center) {
                    HStack(spacing: 9) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.18))
                                .frame(width: 30, height: 30)
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.accentColor)
                        }

                        VStack(alignment: .leading, spacing: 1.5) {
                            Text("偏好设置")
                                .font(.system(size: 15.5, weight: .bold))
                            Text("全局唤醒热键与工作流协同行为配置")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    Button(action: {
                        stopRecording()
                        onDismiss()
                    }) {
                        HStack(spacing: 4) {
                            Text("完成")
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
                        .background(Color(nsColor: .controlBackgroundColor).opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Card 1: Hotkey Settings
                        hotkeySection

                        // Card 2: Workflow Preferences
                        workflowSection

                        // Card 3: Weapons Maintenance & About
                        maintenanceSection
                    }
                    .padding(.bottom, 6)
                }
            }
            .padding(18)
        }
        .frame(width: 730, height: 510)
        .onDisappear {
            stopRecording()
        }
    }

    // MARK: - Sections

    private var hotkeySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("全局唤醒快捷键")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Text("随时呼出军火库，一键装弹")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                // Row 1: Current Keycap + Preset Selector
                HStack(spacing: 14) {
                    // Current keycap badge
                    HStack(spacing: 6) {
                        Text(selectedOption.displayString)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: [Color.accentColor, Color.accentColor.opacity(0.85)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .shadow(color: Color.accentColor.opacity(0.35), radius: 5, x: 0, y: 2)

                        VStack(alignment: .leading, spacing: 1) {
                            Text("当前激活热键")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.primary)
                            Text(selectedOption.name)
                                .font(.system(size: 10.5))
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    // Quick Preset Dropdown
                    Menu {
                        ForEach(HotKeyOption.allPresets) { preset in
                            Button(action: {
                                stopRecording()
                                applyHotKey(preset)
                            }) {
                                HStack {
                                    Text(preset.name)
                                    if selectedOption == preset {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 11))
                            Text("切换预置推荐")
                                .font(.system(size: 12))
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(nsColor: .controlBackgroundColor).opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .menuStyle(.borderlessButton)
                }

                Divider()
                    .background(Color(nsColor: .separatorColor).opacity(0.25))

                // Row 2: Custom Key Recorder
                HStack(spacing: 12) {
                    Button(action: {
                        if isRecording {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(isRecording ? Color.red : Color.accentColor)
                                .frame(width: 8, height: 8)

                            Text(isRecording ? "正在监听... 按任意组合键完成 (Esc 取消)" : "录制自定义快捷键...")
                                .font(.system(size: 12, weight: isRecording ? .semibold : .medium))
                        }
                        .foregroundColor(isRecording ? .red : .primary)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 5)
                        .background(
                            isRecording
                                ? Color.red.opacity(0.12)
                                : Color(nsColor: .controlBackgroundColor).opacity(0.4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(
                                    isRecording ? Color.red.opacity(0.4) : Color.primary.opacity(0.08),
                                    lineWidth: 0.8
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    if let feedback = feedbackText {
                        Text(feedback)
                            .font(.system(size: 11))
                            .foregroundColor(.accentColor)
                            .transition(.opacity)
                    }
                }
            }
            .padding(11)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.48))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 0.8)
            )
        }
    }

    private var workflowSection: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("协同工作流行为")
                .font(.system(size: 13, weight: .bold))

            VStack(spacing: 10) {
                // Auto dismiss on copy
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("装弹后瞬间隐退并归还光标焦点")
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundColor(.primary)
                        Text("按回车复制武器后，弹窗立即隐藏，IDE / 聊天窗口直接处于激活状态，可直接 ⌘V 上屏")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: $autoDismissOnCopy)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .onChange(of: autoDismissOnCopy) { val in
                            UserDefaults.standard.set(val, forKey: "VibeArmory_AutoDismissOnCopy")
                        }
                }
            }
            .padding(11)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.48))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 0.8)
            )
        }
    }

    private var maintenanceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("关于 VibeArmory")
                .font(.system(size: 13, weight: .bold))

            // About App Row
            HStack(alignment: .center, spacing: 14) {
                if let logoImg = loadLogoImage() {
                    Image(nsImage: logoImg)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 1.5)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        Image(systemName: "bolt.terminal.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text("VibeArmory · Vibe 军火库")
                            .font(.system(size: 14, weight: .bold))

                        Text("v0.1.5")
                            .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.12))
                            .foregroundColor(.accentColor)
                            .clipShape(Capsule())
                    }

                    Text("专为 Vibe Coding 与 Agent 打造的纯原生认知协同外挂 · 液态玻璃架构")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Link(destination: URL(string: "https://github.com/a916791360/VibeArmory")!) {
                    HStack(spacing: 4) {
                        Text("GitHub 源码")
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5.5)
                    .background(Color.accentColor.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(Color.accentColor.opacity(0.2), lineWidth: 0.8)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.48))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 0.8)
            )
        }
    }

    // MARK: - Recording Logic

    private func startRecording() {
        isRecording = true
        recordHint = "请在键盘上按下新的组合键 (按 Esc 取消)..."

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // Esc cancels recording
                self.stopRecording()
                return nil
            }

            if let option = HotKeyOption.from(event: event) {
                self.applyHotKey(option)
                self.stopRecording()
                return nil
            }
            return event
        }
    }

    private func stopRecording() {
        isRecording = false
        recordHint = "点击录制自定义快捷键"
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private func applyHotKey(_ option: HotKeyOption) {
        selectedOption = option
        HotKeyManager.shared.updateHotKey(option)
        feedbackText = "已成功绑定热键: \(option.displayString)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            feedbackText = nil
        }
    }

    private func loadLogoImage() -> NSImage? {
        if let appIcon = NSImage(named: "AppIcon") {
            return appIcon
        }

        let possiblePaths = [
            Bundle.main.bundlePath + "/Contents/Resources/AppLogo.png",
            Bundle.main.bundlePath + "/Contents/Resources/AppIcon.icns",
            FileManager.default.currentDirectoryPath + "/Sources/VibeArmory/Resources/AppLogo.png",
            FileManager.default.currentDirectoryPath + "/dist/VibeArmory.app/Contents/Resources/AppLogo.png",
            FileManager.default.currentDirectoryPath + "/design-demos/AppLogo.png"
        ]

        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path),
               let img = NSImage(contentsOfFile: path) {
                return img
            }
        }
        return nil
    }
}
