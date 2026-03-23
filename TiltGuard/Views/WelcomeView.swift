import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.colorScheme) private var colorScheme

    let onContinue: () -> Void

    private var lang: AppLanguage { languageManager.language }

    @State private var currentPage = 0
    @State private var appeared = false

    private let totalPages = 3

    var body: some View {
        ZStack(alignment: .top) {
            Color.vtBlack.ignoresSafeArea()

            // Skip button (pages 0–1 only)
            if currentPage < totalPages - 1 {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = totalPages - 1
                        }
                    } label: {
                        Text(L10n.s(.onboardingSkip, lang))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.vtDim)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.trailing, 12)
                .padding(.top, 8)
                .zIndex(2)
            }

            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                detectPage.tag(1)
                signInPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text(L10n.s(.welcomeTitle, lang))
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.vtText)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)

                Text(L10n.s(.welcomeSubtitle, lang))
                    .font(.system(size: 16))
                    .foregroundColor(.vtMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
            }
            .padding(.horizontal, 32)

            Spacer()

            bottomBar {
                withAnimation { currentPage = 1 }
            }
        }
    }

    // MARK: - Page 2: What the app does

    private var detectPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text(L10n.s(.onboardingDetectTitle, lang))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.vtText)

                    Text(L10n.s(.onboardingDetectBody, lang))
                        .font(.system(size: 15))
                        .foregroundColor(.vtMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                // Three feature icons
                HStack(spacing: 20) {
                    featureIcon(
                        icon: "exclamationmark.triangle",
                        label: L10n.s(.tiltAlert, lang)
                    )
                    featureIcon(
                        icon: "chart.line.uptrend.xyaxis",
                        label: "VPIP"
                    )
                    featureIcon(
                        icon: "shield.checkered",
                        label: L10n.s(.disciplineScore, lang)
                    )
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            bottomBar {
                withAnimation { currentPage = 2 }
            }
        }
    }

    // MARK: - Page 3: Sign In

    private var signInPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Text(L10n.s(.onboardingSignInTitle, lang))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.vtText)

                Text(L10n.s(.onboardingSignInBody, lang))
                    .font(.system(size: 15))
                    .foregroundColor(.vtMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 14) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        dataService.handleSignInAuthorization(authorization)
                        completeOnboarding()
                    case .failure:
                        break
                    }
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Button {
                    completeOnboarding()
                } label: {
                    Text(L10n.s(.continueAsGuest, lang))
                        .font(.system(size: 14))
                        .foregroundColor(.vtMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)

            pageIndicator
                .padding(.bottom, 16)
        }
    }

    // MARK: - Components

    private func bottomBar(action: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Button {
                action()
            } label: {
                Text(L10n.s(.onboardingContinue, lang))
                    .font(.system(size: 16, weight: .semibold))
                    .tracking(0.5)
                    .foregroundColor(.vtBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.vtText)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 24)

            pageIndicator
        }
        .padding(.bottom, 16)
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.vtText : Color.vtBorder)
                    .frame(width: index == currentPage ? 20 : 6, height: 6)
                    .animation(.easeOut(duration: 0.2), value: currentPage)
            }
        }
    }

    private func featureIcon(icon: String, label: String) -> some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.vtBorder, lineWidth: 1)
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(.vtText)
            }

            Text(label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "has_completed_onboarding")
        onContinue()
    }
}
