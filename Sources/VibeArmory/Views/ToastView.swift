import SwiftUI

public struct ToastView: View {
    public let message: String

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 13, weight: .bold))

            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8.5)
        .background(
            ZStack {
                VisualEffectView(material: .popover, blendingMode: .withinWindow, state: .active)
                Color(nsColor: .controlBackgroundColor).opacity(0.4)
            }
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.22), radius: 10, x: 0, y: 5)
    }
}
