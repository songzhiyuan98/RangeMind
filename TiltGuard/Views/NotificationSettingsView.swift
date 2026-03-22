import SwiftUI

struct NotificationSettingsView: View {
    @Environment(LanguageManager.self) private var languageManager
    @AppStorage("vt_tilt_enabled") private var tiltEnabled = true
    @AppStorage("vt_cooldown_enabled") private var cooldownEnabled = true
    @AppStorage("vt_gto_advice_enabled") private var gtoAdviceEnabled = true

    private var lang: AppLanguage { languageManager.language }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 0) {
                    toggleRow(
                        icon: "exclamationmark.triangle",
                        title: L10n.s(.tiltAlert, lang),
                        subtitle: L10n.s(.tiltAlertDesc, lang),
                        isOn: $tiltEnabled
                    )

                    Rectangle()
                        .fill(Color.vtBorder)
                        .frame(height: 0.5)
                        .padding(.horizontal, 16)

                    toggleRow(
                        icon: "timer",
                        title: L10n.s(.cooldownMode, lang),
                        subtitle: L10n.s(.cooldownModeDesc, lang),
                        isOn: $cooldownEnabled
                    )

                    Rectangle()
                        .fill(Color.vtBorder)
                        .frame(height: 0.5)
                        .padding(.horizontal, 16)

                    toggleRow(
                        icon: "book",
                        title: L10n.s(.gtoAdviceToggle, lang),
                        subtitle: L10n.s(.gtoAdviceToggleDesc, lang),
                        isOn: $gtoAdviceEnabled
                    )
                }
                .background(Color.vtSurface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.vtBorder, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.vtBlack.ignoresSafeArea())
        .navigationTitle(L10n.s(.notificationTitle, lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.vtDim)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.vtText)

                Text(subtitle)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.vtDim)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.vtAccent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
    .environment(LanguageManager())
    .preferredColorScheme(.dark)
}
