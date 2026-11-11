import SwiftUI

public struct FloatingHUDView: View {
    @EnvironmentObject private var store: PromptStore

    @State private var selectedIndex: Int = 0
    @State private var showingDetailItem: PromptItem?
    @State private var showingEditItem: PromptItem?
    @State private var isAddingNew = false
    @State private var showingSettings = false
    @State private var toastMessage: String?
    @State private var currentHotKeyDisplay = HotKeyManager.shared.currentKeyDisplayString

    public var body: some View {
        ZStack {
            // Layer 1: Hardware-accelerated True Apple Native Liquid Glass
            VisualEffectView(
                material: .popover,
                blendingMode: .behindWindow,
                state: .active
            )
            .ignoresSafeArea()

            // Layer 2: Main Two-Column Layout (macOS Native Sidebar + Content)
            HStack(spacing: 0) {
                // Column 1: Left Sidebar Navigation
                sidebarView

                // Vertical Hairline Specular Glass Separator
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                Color(nsColor: .separatorColor).opacity(0.35),
                                Color.white.opacity(0.06)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1)
                    .ignoresSafeArea()

                // Column 2: Right Main HUD Content
                mainContentView
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

            // Layer 4.5: Inline Preferences & Hotkey Settings Overlay
            if showingSettings {
                SettingsView {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                        showingSettings = false
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
                .zIndex(6)
            }

            // Layer 5: Toast Overlay
            if let msg = toastMessage {
                ToastView(message: msg)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
                    .padding(.top, 16)
            }
        }
        .frame(width: 730, height: 510)
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
            let action = notif.object as? String
            if action == "settings" {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    showingSettings = true
                }
            } else if action == "add" {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    isAddingNew = true
                }
            } else if action == "detail" {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    if !store.filteredItems.isEmpty {
                        let idx = max(0, min(selectedIndex, store.filteredItems.count - 1))
                        showingDetailItem = store.filteredItems[idx]
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .vibeArmoryHotKeyChanged)) { _ in
            currentHotKeyDisplay = HotKeyManager.shared.currentKeyDisplayString
        }
        .onChange(of: store.searchText) { _ in
            selectedIndex = 0
        }
        .onChange(of: store.selectedCategory) { _ in
            selectedIndex = 0
        }
    }

    // MARK: - Column 1: Left Sidebar

    private var sidebarView: some View {
        VStack(spacing: 0) {
            // App Brand Header
            HStack(spacing: 8) {
                if let logoImg = loadLogoImage() {
                    Image(nsImage: logoImg)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 1.5)
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
                    .font(.system(size: 13.5, weight: .bold, design: .default))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Category Section Title
            HStack {
                Text("战区分类")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.75))
                Spacer()
                Text("\(store.items.count) 款就绪")
                    .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 6)

            // Category Vertical List
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 3) {
                    ForEach(PromptCategory.allCases) { cat in
                        let isSelected = (store.selectedCategory == cat)
                        let count = store.count(for: cat)

                        Button(action: {
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.85)) {
                                store.selectedCategory = cat
                                selectedIndex = 0
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: cat.icon)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(isSelected ? .white : cat.color)
                                    .frame(width: 15)

                                Text(cat.rawValue)
                                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                                    .foregroundColor(isSelected ? .white : .primary)
                                    .lineLimit(1)

                                Spacer()

                                // Badge count
                                Text("\(count)")
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .padding(.horizontal, 5.5)
                                    .padding(.vertical, 1.5)
                                    .background(
                                        isSelected
                                            ? Color.white.opacity(0.25)
                                            : Color.primary.opacity(0.06)
                                    )
                                    .foregroundColor(isSelected ? .white : .secondary)
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Group {
                                    if isSelected {
                                        LinearGradient(
                                            colors: [Color.accentColor, Color.accentColor.opacity(0.85)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    } else {
                                        Color.clear
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 6)
            }

            Spacer(minLength: 0)

            Divider()
                .background(Color(nsColor: .separatorColor).opacity(0.35))

            // Sidebar Bottom: Add Custom Weapon Action
            Button(action: {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    isAddingNew = true
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 11.5))
                        .foregroundColor(.accentColor)

                    Text("新增自定义武器")
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(.primary)

                    Spacer()
                }
                .padding(.horizontal, 14)
                .frame(height: 38)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(width: 195)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.22))
    }

    // MARK: - Column 2: Right Main Content

    private var mainContentView: some View {
        VStack(spacing: 0) {
            // Search Header Bar
            searchHeaderView
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, 12)

            Divider()
                .background(Color(nsColor: .separatorColor).opacity(0.35))

            // Cards List
            cardsList

            Divider()
                .background(Color(nsColor: .separatorColor).opacity(0.35))

            // Footer Bar
            footerView
                .padding(.horizontal, 16)
                .frame(height: 38)
        }
        .frame(maxWidth: .infinity)
    }

    private var searchHeaderView: some View {
        HStack(spacing: 8) {
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

                Text(currentHotKeyDisplay)
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

            // Action Button: Settings
            Button(action: {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    showingSettings = true
                }
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 11.5, weight: .medium))
                    .padding(6.5)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.4))
                    .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("偏好设置 (⌘,)")
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
                            Text("未在该战区找到匹配武器")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 240)
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
                                },
                                onDelete: {
                                    deleteCustomItem(item)
                                }
                            )
                            .id(item.id)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
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
        guard showingDetailItem == nil && showingEditItem == nil && !isAddingNew && !showingSettings else { return }
        let total = store.filteredItems.count
        if total > 0 {
            selectedIndex = min(selectedIndex + 1, total - 1)
        }
    }

    private func handleMoveUp() {
        guard showingDetailItem == nil && showingEditItem == nil && !isAddingNew && !showingSettings else { return }
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

        let items = store.filteredItems
        if selectedIndex >= 0 && selectedIndex < items.count {
            copyItem(items[selectedIndex])
        }
    }

    private func handleDismissOrBack() {
        if showingSettings {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                showingSettings = false
            }
        } else if showingDetailItem != nil {
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
            NotificationCenter.default.post(name: .vibeArmoryToggleRequested, object: nil)
        }
    }

    private func copyItem(_ item: PromptItem) {
        ClipboardManager.shared.copy(prompt: item)
        store.incrementUsage(id: item.id)
        showToast("已装填: \(item.title)")
    }

    private func deleteCustomItem(_ item: PromptItem) {
        guard !item.isPreset else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
            store.delete(id: item.id)
            let count = store.filteredItems.count
            if selectedIndex >= count {
                selectedIndex = max(0, count - 1)
            }
        }
        showToast("已删除自定义武器: \(item.title)")
    }

    private func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            if toastMessage == message {
                withAnimation(.easeOut(duration: 0.22)) {
                    toastMessage = nil
                }
            }
        }
    }

    private func loadLogoImage() -> NSImage? {
        if let appIcon = NSImage(named: "AppIcon") {
            return appIcon
        }

        let possiblePaths = [
            Bundle.main.bundlePath + "/Contents/Resources/AppLogo.png",
            Bundle.main.bundlePath + "/Contents/Resources/AppIcon.icns",
            FileManager.default.currentDirectoryPath + "/Sources/VibeArmory/Resources/AppLogo.png"
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
