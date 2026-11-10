# 方向选定记录 (Gate File · Huashu-Design)

- **项目**：VibeArmory 弹窗 UI 升级
- **状态**：已选定并实施中
- **用户原话**：“我不是选择方案 B，而是让你重新做一个真原生苹果液态玻璃风格”
- **执行方向**：**真正的 Apple 原生液态玻璃风格（True Apple Native Liquid Glass）**
- **技术实现基准**：
  1. 底层抛弃伪 Web Blur，全面采用 AppKit `NSVisualEffectView` 硬件加速材质（`material: .popover`, `blendingMode: .behindWindow`）；
  2. 实现 1.5px 迎光面菲涅尔光学镜面高光反射与 0.5px 环境闭塞暗线；
  3. 控件与卡片全面接入 macOS 原生语义 Vibrancy 与系统强调色（`Color.accentColor`）；
  4. 采用 Apple 签名级弹簧物理动效（`response: 0.28, dampingFraction: 0.85`）。
- **核准时间**：2026-11-10
