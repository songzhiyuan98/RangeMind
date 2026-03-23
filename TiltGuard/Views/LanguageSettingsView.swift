import SwiftUI

struct LanguageSettingsView: View {
    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        @Bindable var languageManager = languageManager
        let lang = languageManager.language

        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.s(.languageDescription, lang))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.vtDim)
                        .padding(.horizontal, 24)

                    VStack(spacing: 0) {
                        ForEach(Array(AppLanguage.allCases.enumerated()), id: \.element.rawValue) { index, language in
                            Button {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    languageManager.language = language
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: language.icon)
                                        .font(.system(size: 16))
                                        .foregroundColor(languageManager.language == language ? .vtText : .vtDim)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(language.label)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(languageManager.language == language ? .vtText : .vtMuted)

                                        Text(language == .english ? "Default" : "默认")
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(.vtDim)
                                            .opacity(language == .english ? 1 : 0)
                                    }

                                    Spacer()

                                    if languageManager.language == language {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.vtText)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            if index < AppLanguage.allCases.count - 1 {
                                Rectangle()
                                    .fill(Color.vtBorder)
                                    .frame(height: 0.5)
                                    .padding(.horizontal, 24)
                            }
                        }
                    }
                }
                .padding(.top, 20)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.vtBlack.ignoresSafeArea())
        .navigationTitle(L10n.s(.languageTitle, lang))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LanguageSettingsView()
    }
    .environment(LanguageManager())
    .preferredColorScheme(.dark)
}
