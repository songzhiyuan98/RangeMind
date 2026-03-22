import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppearanceManager.self) private var appearance
    @Environment(LanguageManager.self) private var languageManager
    @Environment(DataService.self) private var dataService

    private var lang: AppLanguage { languageManager.language }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeader
                        .padding(.top, 24)

                    // Account
                    accountSection

                    // Settings
                    settingsSection

                    // About
                    aboutSection

                    // Branding
                    branding
                        .padding(.top, 24)

                    Spacer().frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color.vtBlack.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.vtSurface)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle()
                            .stroke(Color.vtBorder, lineWidth: 1)
                    )

                if dataService.isLoggedIn {
                    Text(dataService.userInitial)
                        .font(.system(size: 28, weight: .light, design: .monospaced))
                        .foregroundColor(.vtAccent)
                } else {
                    Image(systemName: "person")
                        .font(.system(size: 28, weight: .ultraLight))
                        .foregroundColor(.vtDim)
                }
            }

            if dataService.isLoggedIn {
                VStack(spacing: 4) {
                    Text(dataService.userName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.vtText)

                    Text("\(dataService.lifetimeHands) \(L10n.s(.hands, lang).lowercased()) · \(dataService.recentSessions.count) \(L10n.s(.sessions, lang).lowercased())")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
            } else {
                VStack(spacing: 4) {
                    Text(L10n.s(.guest, lang))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.vtText)

                    Text(L10n.s(.signInToSync, lang))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Account

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(L10n.s(.account, lang))

            if dataService.isLoggedIn {
                vtCard {
                    HStack {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 14))
                            .foregroundColor(.vtMuted)
                            .frame(width: 20)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Apple ID")
                                .font(.system(size: 14))
                                .foregroundColor(.vtText)
                            Text(dataService.userEmail)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.vtDim)
                        }

                        Spacer()

                        Text(L10n.s(.connected, lang))
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.vtAccent)
                            .tracking(1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                }
            } else {
                Button {
                    // TODO: Sign in with Apple
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 14))

                        Text(L10n.s(.signInWithApple, lang))
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .tracking(1)
                    }
                    .foregroundColor(.vtBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.vtText, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 20)

                vtCard {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.vtAmber)
                            .frame(width: 20)

                        Text(L10n.s(.guestDataLocal, lang))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.vtDim)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(L10n.s(.settings, lang))

            vtCard {
                VStack(spacing: 0) {
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        settingsRow(
                            icon: appearance.mode.icon,
                            title: L10n.s(.appearance, lang),
                            detail: appearance.mode.localizedLabel(lang)
                        )
                    }
                    .buttonStyle(.plain)

                    rowDivider

                    NavigationLink {
                        LanguageSettingsView()
                    } label: {
                        settingsRow(
                            icon: languageManager.language.icon,
                            title: L10n.s(.language, lang),
                            detail: languageManager.language.label
                        )
                    }
                    .buttonStyle(.plain)

                    rowDivider

                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        settingsRow(
                            icon: "bell",
                            title: L10n.s(.notifications, lang),
                            detail: nil
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(L10n.s(.about, lang))

            vtCard {
                VStack(spacing: 0) {
                    // Version — not navigable, just info
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.vtDim)
                            .frame(width: 20)
                        Text(L10n.s(.version, lang))
                            .font(.system(size: 14))
                            .foregroundColor(.vtMuted)
                        Spacer()
                        Text("1.0.0")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.vtDim)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)

                    rowDivider

                    Button {
                        // TODO: Open privacy policy
                    } label: {
                        settingsRow(
                            icon: "hand.raised",
                            title: L10n.s(.privacyPolicy, lang),
                            detail: nil
                        )
                    }
                    .buttonStyle(.plain)

                    rowDivider

                    Button {
                        // TODO: Open terms of use
                    } label: {
                        settingsRow(
                            icon: "doc.text",
                            title: L10n.s(.termsOfUse, lang),
                            detail: nil
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Branding

    private var branding: some View {
        VStack(spacing: 4) {
            Text(L10n.s(.appName, lang))
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.vtAccent)
            Text(L10n.s(.appFullName, lang))
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(2)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .medium, design: .monospaced))
            .foregroundColor(.vtDim)
            .tracking(2)
            .padding(.horizontal, 20)
    }

    private func vtCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background(Color.vtSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.vtBorder, lineWidth: 1)
            )
            .padding(.horizontal, 20)
    }

    private func settingsRow(icon: String, title: String, detail: String?) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.vtDim)
                .frame(width: 20)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.vtMuted)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.vtDim)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.vtDim)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.vtBorder)
            .frame(height: 0.5)
            .padding(.horizontal, 16)
    }
}

#Preview {
    SettingsView()
        .environment(AppearanceManager())
        .environment(LanguageManager())
        .environment(DataService(modelContext: PreviewContainer.shared.mainContext))
        .preferredColorScheme(.dark)
}
