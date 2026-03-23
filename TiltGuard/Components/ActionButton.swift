import SwiftUI

struct ActionButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void

    enum ButtonStyle {
        case primary
        case secondary
        case success
        case neutral
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .tracking(1)
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .vtBlack
        case .secondary: return .vtMuted
        case .success: return .vtBlack
        case .neutral: return .vtMuted
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return .vtText
        case .secondary: return .clear
        case .success: return .vtAccent
        case .neutral: return .clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: return .vtText
        case .secondary: return .vtBorder
        case .success: return .vtAccent
        case .neutral: return .vtBorder
        }
    }
}

struct ScaleButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.vtBlack.ignoresSafeArea()
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ActionButton(title: "FOLD", style: .secondary) {}
                ActionButton(title: "VPIP", style: .primary) {}
            }
            HStack(spacing: 12) {
                ActionButton(title: "WIN", style: .success) {}
                ActionButton(title: "LOSS", style: .neutral) {}
            }
        }
        .padding()
    }
}
