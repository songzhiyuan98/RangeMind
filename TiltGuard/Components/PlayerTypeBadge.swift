import SwiftUI

struct PlayerTypeBadge: View {
    let type: PlayerType
    var lang: AppLanguage = .english

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(type.color)
                .frame(width: 5, height: 5)

            Text(type.displayName(lang))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.vtMuted)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(Color.vtBorder, lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.vtBlack.ignoresSafeArea()
        VStack(spacing: 12) {
            PlayerTypeBadge(type: .nit)
            PlayerTypeBadge(type: .tight)
            PlayerTypeBadge(type: .standard)
            PlayerTypeBadge(type: .loose)
            PlayerTypeBadge(type: .veryLoose)
        }
    }
}
