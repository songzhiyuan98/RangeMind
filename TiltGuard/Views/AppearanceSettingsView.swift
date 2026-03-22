import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(AppearanceManager.self) private var appearance
    @Environment(LanguageManager.self) private var languageManager

    private var lang: AppLanguage { languageManager.language }

    var body: some View {
        @Bindable var appearance = appearance

        ScrollView {
            VStack(spacing: 24) {
                // Mode picker
                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.s(.mode, lang))
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtDim)
                        .tracking(2)
                        .padding(.horizontal, 20)

                    HStack(spacing: 8) {
                        ForEach(AppearanceMode.allCases, id: \.rawValue) { mode in
                            Button {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    appearance.mode = mode
                                }
                            } label: {
                                modeCard(mode)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)

                Spacer().frame(height: 40)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.vtBlack.ignoresSafeArea())
        .navigationTitle(L10n.s(.appearance, lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func modeCard(_ mode: AppearanceMode) -> some View {
        let isSelected = appearance.mode == mode

        return VStack(spacing: 0) {
            // Preview swatch
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(previewBg(mode))
                    .frame(height: 56)

                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(previewFg(mode))
                        .frame(width: 24, height: 3)
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(previewFg(mode).opacity(0.4))
                        .frame(width: 16, height: 3)
                }
            }
            .padding(8)

            // Label
            VStack(spacing: 4) {
                Image(systemName: mode.icon)
                    .font(.system(size: 14, weight: isSelected ? .medium : .light))

                Text(mode.localizedLabel(lang))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
            }
            .foregroundColor(isSelected ? .vtAccent : .vtDim)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.vtAccentMuted : Color.vtSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isSelected ? Color.vtAccent.opacity(0.3) : Color.vtBorder, lineWidth: 1)
        )
    }

    private func previewBg(_ mode: AppearanceMode) -> Color {
        switch mode {
        case .system: return Color(UIColor.systemBackground)
        case .light: return Color(white: 0.96)
        case .dark: return Color(white: 0.06)
        }
    }

    private func previewFg(_ mode: AppearanceMode) -> Color {
        switch mode {
        case .system: return Color(UIColor.label)
        case .light: return Color(white: 0.15)
        case .dark: return Color(white: 0.88)
        }
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
    .environment(AppearanceManager())
    .environment(LanguageManager())
    .preferredColorScheme(.dark)
}
