import SwiftUI

public struct FloatingHUDView: View {
    @EnvironmentObject private var store: PromptStore

    @State private var selectedIndex: Int = 0
    @State private var showingDetailItem: PromptItem?
    @State private var showingEditItem: PromptItem?
    @State private var isAddingNew = false
    @State private var toastMessage: String?

    public var body: some View {
        ZStack {
            // Layer 1: Hardware-accelerated True Apple Native Liquid Glass
            VisualEffectView(
                material: .popover,
                blendingMode: .behindWindow,
                state: .active
            )
            .ignoresSafeArea()

            // Layer 2: Main HUD Content
            VStack(spacing: 0) {
                // Top Search & Title Bar
                headerView
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                // Category Filter Pills
                categoryPills
                    .padding(.horizontal, 18)
                    .padding(.bottom, 10)

                // Subtle Apple hairline divider
                Divider()
                    .background(Color(nsColor: .separatorColor).opacity(0.4))

                // Prompt Cards List
                cardsList

                Divider()
                    .background(Color(nsColor: .separatorColor).opacity(0.4))

                // Footer Bar
                footerView
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
            }

            // Layer 3: Inline Detail Overlay (Pure Liquid Glass)
            if let detailItem = showingDetailItem {
                DetailSheetView(
                    item: detailItem,
                    onCopy: { copyItem(detailItem) },
                    onDismiss: {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                            showingDetailItem = nil
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
                .zIndex(5)
            }

            // Layer 4: Inline New / Edit Overlay
            if isAddingNew {
                EditPromptView(existingItem: nil) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                        isAddingNew = false
                    }
                }
                .environmentObject(store)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
                .zIndex(5)
            } else if let editItem = showingEditItem {
                EditPromptView(existingItem: editItem) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                        showingEditItem = nil
                    }
                }
                .environmentObject(store)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
                .zIndex(5)
            }

            // Layer 5: Toast Overlay
            if let msg = toastMessage {
                ToastView(message: msg)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
                    .padding(.top, 16)
            }
        }
        .frame(width: 650, height: 490)
        // Apple Liquid Glass Specular Double-Rim Optics
        .overlay(
            // Primary Glass Chamfer Highlight (1.2px)
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.48),
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.04),
                            Color.white.opacity(0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .overlay(
            // Top Glare Ambient Reflection (simulating overhead studio light)
            VStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.65), Color.white.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.5
                    )
                    .frame(height: 28)
                    .mask(
                        LinearGradient(
                            colors: [Color.black, Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Spacer()
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onReceive(NotificationCenter.default.publisher(for: .vibeArmoryMoveSelectionDown)) { _ in
            handleMoveDown()
        }
        .onReceive(NotificationCenter.default.publisher(for: .vibeArmoryMoveSelectionUp)) { _ in
            handleMoveUp()
        }
        .onReceive(NotificationCenter.default.publisher(for: .vibeArmoryConfirmSelection)) { _ in
            handleConfirm()
        }
        .onReceive(NotificationCenter.default.publisher(for: .vibeArmoryDismissOrBack)) { _ in
            handleDismissOrBack()
        }
        .onReceive(NotificationCenter.default.publisher(for: .vibeArmoryOpenSettingsRequested)) { notif in
            if (notif.object as? String) == "add" {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    isAddingNew = true
                }
            }
        }
        .onChange(of: store.searchText) { _ in
            selectedIndex = 0
        }
        .onChange(of: store.selectedCategory) { _ in
            selectedIndex = 0
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack(spacing: 12) {
            // 3D Apple Liquid Glass Brand Logo
            HStack(spacing: 8) {
                if let logoImg = loadLogoImage() {
                    Image(nsImage: logoImg)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 27, height: 27)
                        .shadow(color: Color.black.opacity(0.28), radius: 3, x: 0, y: 1.5)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.accentColor.opacity(0.2))
                            .frame(width: 24, height: 24)

                        Image(systemName: "bolt.terminal.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.accentColor)
                    }
                }

                Text("VibeArmory")
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(.primary)
            }

            // Apple Spotlight-style Integrated Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(.secondary)

                TextField("搜索痛点症状 (例如: 样式、死循环、重构)...", text: $store.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))

                if !store.searchText.isEmpty {
                    Button(action: { store.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Text("⌥P")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.06))
                    .foregroundColor(.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 6.5)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.4))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            // Action Buttons
            HStack(spacing: 5) {
                Button(action: {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                        isAddingNew = true
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12.5, weight: .medium))
                        .padding(6)
                        .background(Color(nsColor: .controlBackgroundColor).opacity(0.4))
                        .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("新增自定义武器")

                Button(action: {
                    store.resetToPresets()
                    showToast("已重置为官方预置武器库")
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 11.5, weight: .medium))
                        .padding(6)
                        .background(Color(nsColor: .controlBackgroundColor).opacity(0.4))
                        .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("一键重置为官方预置")
            }
        }
    }

    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6.5) {
                ForEach(PromptCategory.allCases) { cat in
                    let isSelected = (store.selectedCategory == cat)
                    Button(action: {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                            store.selectedCategory = cat
                            selectedIndex = 0
                        }
                    }) {
                        HStack(spacing: 4.5) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 9.5))
                            Text(cat.rawValue)
                                .font(.system(size: 11.5, weight: isSelected ? .semibold : .regular))
                        }
                        .padding(.horizontal, 10.5)
                        .padding(.vertical, 4.5)
                        .background(
                            Group {
                                if isSelected {
                                    Color.accentColor
                                } else {
                                    Color(nsColor: .controlBackgroundColor).opacity(0.35)
                                }
                            }
                        )
                        .foregroundColor(isSelected ? .white : .primary)
                        .overlay(
                            Capsule()
                                .stroke(
                                    isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.08),
                                    lineWidth: 0.8
                                )
                        )
                        .clipShape(Capsule())
                        .shadow(color: isSelected ? Color.accentColor.opacity(0.35) : Color.clear, radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var cardsList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 5) {
                    let items = store.filteredItems
                    if items.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "tray")
                                .font(.system(size: 32, weight: .light))
                                .foregroundColor(.secondary)
                            Text("未找到匹配的痛点武器")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 220)
                    } else {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            PromptCardView(
                                item: item,
                                isSelected: index == selectedIndex,
                                onSelect: {
                                    selectedIndex = index
                                },
                                onCopy: {
                                    copyItem(item)
                                },
                                onDetail: {
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                                        showingDetailItem = item
                                    }
                                },
                                onEdit: {
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                                        showingEditItem = item
                                    }
                                }
                            )
                            .id(item.id)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
            }
            .onChange(of: selectedIndex) { newIndex in
                let items = store.filteredItems
                if newIndex >= 0 && newIndex < items.count {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        proxy.scrollTo(items[newIndex].id, anchor: .center)
                    }
                }
            }
        }
    }

    private var footerView: some View {
        HStack {
            HStack(spacing: 14) {
                // Keycap badge for arrows
                HStack(spacing: 5) {
                    Text("↑↓")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1.5)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    Text("切换")
                }

                // Keycap badge for Return
                HStack(spacing: 5) {
                    Text("↵")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1.5)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    Text("装弹")
                }

                // Keycap badge for Esc
                HStack(spacing: 5) {
                    Text("Esc")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1.5)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    Text("隐退")
                }
            }
            .font(.system(size: 11))
            .foregroundColor(.secondary)

            Spacer()

            Text("\(store.filteredItems.count) 款武器就绪 · 零输入真原生")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Keyboard Handling

    private func handleMoveDown() {
        guard showingDetailItem == nil && showingEditItem == nil && !isAddingNew else { return }
        let total = store.filteredItems.count
        if total > 0 {
            selectedIndex = min(selectedIndex + 1, total - 1)
        }
    }

    private func handleMoveUp() {
        guard showingDetailItem == nil && showingEditItem == nil && !isAddingNew else { return }
        if store.filteredItems.count > 0 {
            selectedIndex = max(selectedIndex - 1, 0)
        }
    }

    private func handleConfirm() {
        if let detail = showingDetailItem {
            copyItem(detail)
            showingDetailItem = nil
            return
        }
        guard showingEditItem == nil && !isAddingNew else { return }
        let items = store.filteredItems
        if selectedIndex >= 0 && selectedIndex < items.count {
            copyItem(items[selectedIndex])
        }
    }

    private func handleDismissOrBack() {
        if showingDetailItem != nil {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                showingDetailItem = nil
            }
        } else if showingEditItem != nil {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                showingEditItem = nil
            }
        } else if isAddingNew {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                isAddingNew = false
            }
        } else {
            FloatingPanelController.shared.hide(restoreFocus: true)
        }
    }

    private func loadLogoImage() -> NSImage? {
        if let bundlePath = Bundle.main.path(forResource: "AppLogo", ofType: "png"),
           let img = NSImage(contentsOfFile: bundlePath) {
            return img
        }
        let execURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/AppLogo.png")
        if let img = NSImage(contentsOf: execURL) {
            return img
        }
        let projectPath = "Sources/VibeArmory/Resources/AppLogo.png"
        if FileManager.default.fileExists(atPath: projectPath),
           let img = NSImage(contentsOfFile: projectPath) {
            return img
        }
        return nil
    }

    // MARK: - Actions

    private func copyItem(_ item: PromptItem) {
        ClipboardManager.shared.copy(prompt: item)
        store.incrementUsage(id: item.id)
        showToast("已装弹至剪贴板 · 切回 Agent 直接 ⌘V")
    }

    private func showToast(_ msg: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            toastMessage = msg
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                toastMessage = nil
            }
        }
    }
}
