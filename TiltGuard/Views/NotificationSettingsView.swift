import SwiftUI

struct NotificationSettingsView: View {
    @Environment(LanguageManager.self) private var languageManager
    @AppStorage("vt_tilt_enabled") private var tiltEnabled = true
    @AppStorage("vt_cooldown_enabled") private var cooldownEnabled = true
    @AppStorage("vt_gto_advice_enabled") private var gtoAdviceEnabled = true

    private var lang: AppLanguage { languageManager.language }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Tilt Alert
                VStack(spacing: 0) {
                    toggleRow(
                        icon: "exclamationmark.triangle",
                        title: L10n.s(.tiltAlert, lang),
                        subtitle: L10n.s(.tiltAlertDesc, lang),
                        isOn: $tiltEnabled
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // Cooldown + GTO
                VStack(spacing: 0) {
                    toggleRow(
                        icon: "timer",
                        title: L10n.s(.cooldownMode, lang),
                        subtitle: L10n.s(.cooldownModeDesc, lang),
                        isOn: $cooldownEnabled
                    )

                    rowDivider

                    toggleRow(
                        icon: "book",
                        title: L10n.s(.gtoAdviceToggle, lang),
                        subtitle: L10n.s(.gtoAdviceToggleDesc, lang),
                        isOn: $gtoAdviceEnabled
                    )
                }
                .padding(.horizontal, 24)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.vtBlack.ignoresSafeArea())
        .navigationTitle(L10n.s(.notificationTitle, lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private func toggleRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.vtDim)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15))
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
        .padding(.vertical, 14)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.vtBorder)
            .frame(height: 0.5)
            .padding(.leading, 48)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
    .environment(LanguageManager())
    .preferredColorScheme(.dark)
}
