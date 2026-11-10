# 方向选定记录 (Gate File · Huashu-Design)

- **项目**：VibeArmory 弹窗 UI 升级与架构演进
- **状态**：已选定并实施中
- **最新迭代核准时间**：2026-11-10
- **最新用户原话**：“方案 2 吧，因为马上就要扩展到不少分类了，保持 apple 原生液态玻璃风格 /huashu-design ，这个 skills 做监督”
- **执行方向**：**方案 2 · macOS 经典两栏架构（Left Sidebar 战区导航 + Right Main HUD 武器库）**
- **设计标准与监督原则 (Huashu-Design)**：
  1. **真原生苹果液态玻璃**：底层坚持 AppKit `NSVisualEffectView(material: .popover, blendingMode: .behindWindow, state: .active)`，杜绝 CSS 拟态或假玻璃；
  2. **高密度专业生产力排版**：全面去除冗余装饰图标，信息层级分明；
  3. **左侧战区栏 (Sidebar)**：垂直原生排布，每个战区右侧展示武器数量角标 (Count Badge)，支持无限分类扩展不截断；
  4. **右侧主战区**：顶部 Spotlight 搜索 + 卡片列表 + 极光双重倒角光学边缘；
  5. **键盘流闭环**：`[↑↓]` 垂直切换武器，`[↵]` 一键装弹，`[Esc]` 隐退，操作零阻力。
- **历史记录**：
  - 2026-11-10: 用户选定“重新做一个真原生苹果液态玻璃风格”并落地。
