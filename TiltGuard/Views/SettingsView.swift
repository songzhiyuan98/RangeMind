import SwiftUI
import SwiftData
import PhotosUI

struct SettingsView: View {
    @Environment(AppearanceManager.self) private var appearance
    @Environment(LanguageManager.self) private var languageManager
    @Environment(DataService.self) private var dataService
    @State private var showSignOutConfirm = false
    @State private var showEditProfile = false

    private var lang: AppLanguage { languageManager.language }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Profile header
                    profileHeader
                        .padding(.top, 32)
                        .animation(.easeInOut(duration: 0.35), value: dataService.isLoggedIn)

                    // Account
                    accountSection
                        .animation(.easeInOut(duration: 0.35), value: dataService.isLoggedIn)

                    // Settings
                    settingsSection

                    // About
                    aboutSection

                    // Sign out (bottom)
                    if dataService.isLoggedIn {
                        signOutSection
                            .padding(.top, 8)
                    }

                    Spacer().frame(height: 20)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color.vtBlack.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
        .alert(
            L10n.s(.signOutConfirm, lang),
            isPresented: $showSignOutConfirm
        ) {
            Button(L10n.s(.cancel, lang), role: .cancel) {}
            Button(L10n.s(.signOut, lang), role: .destructive) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    dataService.signOut()
                }
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet()
                .environment(dataService)
                .environment(languageManager)
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color.vtBorder, lineWidth: 1)
                    .frame(width: 80, height: 80)

                if dataService.isLoggedIn {
                    if let imageData = dataService.userAvatarImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 78, height: 78)
                            .clipShape(Circle())
                    } else if !dataService.userAvatar.isEmpty {
                        Text(dataService.userAvatar)
                            .font(.system(size: 36))
                    } else {
                        Text(dataService.userInitial)
                            .font(.system(size: 32, weight: .light, design: .monospaced))
                            .foregroundColor(.vtText)
                    }
                } else {
                    Image(systemName: "person")
                        .font(.system(size: 30, weight: .ultraLight))
                        .foregroundColor(.vtDim)
                }
            }

            if dataService.isLoggedIn {
                VStack(spacing: 6) {
                    Text(dataService.userName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.vtText)

                    if !dataService.userEmail.isEmpty {
                        Text(dataService.userEmail)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.vtDim)
                    }

                    Text("\(dataService.lifetimeHands) \(L10n.s(.hands, lang).lowercased()) · \(dataService.recentSessions.count) \(L10n.s(.sessions, lang).lowercased())")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
            } else {
                VStack(spacing: 6) {
                    Text(L10n.s(.guest, lang))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.vtText)

                    Text(L10n.s(.signInToSync, lang))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Account

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(L10n.s(.account, lang))

            if dataService.isLoggedIn {
                VStack(spacing: 0) {
                    // Apple ID connection
                    HStack {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 16))
                            .foregroundColor(.vtDim)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Apple ID")
                                .font(.system(size: 15))
                                .foregroundColor(.vtText)
                            if !dataService.userEmail.isEmpty {
                                Text(dataService.userEmail)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.vtDim)
                            }
                        }

                        Spacer()

                        Text(L10n.s(.connected, lang))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.vtDim)
                            .tracking(1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)

                    rowDivider
                        .padding(.horizontal, 24)

                    // Edit profile
                    Button {
                        showEditProfile = true
                    } label: {
                        settingsRow(
                            icon: "pencil",
                            title: L10n.s(.editProfile, lang),
                            detail: nil
                        )
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // Sign in button
                Button {
                    dataService.signInWithApple()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 15))

                        Text(L10n.s(.signInWithApple, lang))
                            .font(.system(size: 14, weight: .semibold))
                            .tracking(0.5)
                    }
                    .foregroundColor(.vtBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.vtText, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 24)

                // Guest notice
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.vtDim)
                        .frame(width: 4, height: 4)

                    Text(L10n.s(.guestDataLocal, lang))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
                .padding(.horizontal, 28)
            }
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(L10n.s(.settings, lang))

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
                    .padding(.horizontal, 24)

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
                    .padding(.horizontal, 24)

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

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(L10n.s(.about, lang))

            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.vtDim)
                        .frame(width: 24)
                    Text(L10n.s(.version, lang))
                        .font(.system(size: 15))
                        .foregroundColor(.vtMuted)
                    Spacer()
                    Text("1.0.0")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)

                rowDivider
                    .padding(.horizontal, 24)

                Button {
                    sendFeedback()
                } label: {
                    settingsRow(
                        icon: "envelope",
                        title: L10n.s(.feedback, lang),
                        detail: nil
                    )
                }
                .buttonStyle(.plain)

                rowDivider
                    .padding(.horizontal, 24)

                Button {
                    openURL("https://songzhiyuan98.github.io/RangeMind/privacy.html")
                } label: {
                    settingsRow(
                        icon: "hand.raised",
                        title: L10n.s(.privacyPolicy, lang),
                        detail: nil
                    )
                }
                .buttonStyle(.plain)

                rowDivider
                    .padding(.horizontal, 24)

                Button {
                    openURL("https://songzhiyuan98.github.io/RangeMind/terms.html")
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

    // MARK: - Sign Out

    private var signOutSection: some View {
        Button {
            showSignOutConfirm = true
        } label: {
            Text(L10n.s(.signOut, lang))
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(.vtRed)
                .tracking(1)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.vtBorder, lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 24)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .foregroundColor(.vtDim)
            .tracking(2)
            .padding(.horizontal, 24)
    }

    private func settingsRow(icon: String, title: String, detail: String?) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.vtDim)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.vtText)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.vtDim)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.vtDim)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.vtBorder)
            .frame(height: 0.5)
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Feedback

    private func sendFeedback() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        let device = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let hands = dataService.lifetimeHands
        let sessions = dataService.recentSessions.count

        let subject = L10n.s(.feedbackSubject, lang) + "\(version)"
        let body = L10n.s(.feedbackBody, lang) + "\nApp: TiltGuard v\(version) (\(build))\nDevice: \(device) · iOS \(systemVersion)\nHands: \(hands) · Sessions: \(sessions)"

        let email = "songzhiyuan98@gmail.com"
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Edit Profile Sheet

private struct EditProfileSheet: View {
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.dismiss) private var dismiss
    @State private var editName: String = ""
    @State private var selectedAvatar: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var avatarImageData: Data?
    @State private var isLoadingPhoto = false

    private var lang: AppLanguage { languageManager.language }

    private let avatarOptions = [
        "", "🃏", "♠️", "♦️", "♣️", "♥️",
        "🎰", "🎲", "🏆", "🔥", "⚡️", "🐺",
        "🦅", "🦊", "🐉", "💎", "👑", "🎯"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.vtBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        // Avatar preview + upload
                        avatarPreviewSection
                            .padding(.top, 24)

                        // Name input
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.s(.displayName, lang).uppercased())
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.vtDim)
                                .tracking(2)

                            TextField("Player", text: $editName)
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundColor(.vtText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .stroke(Color.vtBorder, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 24)

                        // Avatar picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text(L10n.s(.chooseAvatar, lang).uppercased())
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.vtDim)
                                .tracking(2)
                                .padding(.horizontal, 24)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                                // Upload photo button
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .stroke(avatarImageData != nil && selectedAvatar.isEmpty ? Color.vtText : Color.vtBorder, lineWidth: 1)
                                            .frame(height: 48)

                                        if let data = avatarImageData, let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 44, height: 44)
                                                .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
                                        } else {
                                            Image(systemName: "camera")
                                                .font(.system(size: 14))
                                                .foregroundColor(.vtDim)
                                        }
                                    }
                                }

                                ForEach(avatarOptions, id: \.self) { avatar in
                                    Button {
                                        selectedAvatar = avatar
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                                .stroke(selectedAvatar == avatar && avatarImageData == nil ? Color.vtText : Color.vtBorder, lineWidth: 1)
                                                .frame(height: 48)

                                            if avatar.isEmpty {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.vtDim)
                                            } else {
                                                Text(avatar)
                                                    .font(.system(size: 24))
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 24)

                            // Remove photo button
                            if avatarImageData != nil {
                                Button {
                                    avatarImageData = nil
                                    selectedPhotoItem = nil
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 12))
                                        Text(L10n.s(.removePhoto, lang))
                                            .font(.system(size: 13, design: .monospaced))
                                    }
                                    .foregroundColor(.vtDim)
                                }
                                .padding(.horizontal, 24)
                            }
                        }

                        Spacer().frame(height: 40)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.s(.cancel, lang)) {
                        dismiss()
                    }
                    .foregroundColor(.vtMuted)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.s(.save, lang)) {
                        if !editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            dataService.updateUserName(editName)
                        }
                        if let imageData = avatarImageData {
                            dataService.updateUserAvatarImage(imageData)
                            dataService.updateUserAvatar("")
                        } else {
                            dataService.updateUserAvatarImage(nil)
                            dataService.updateUserAvatar(selectedAvatar)
                        }
                        dismiss()
                    }
                    .foregroundColor(.vtText)
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle(L10n.s(.editProfile, lang))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            editName = dataService.userName
            selectedAvatar = dataService.userAvatar
            avatarImageData = dataService.userAvatarImageData
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            isLoadingPhoto = true
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    let cropped = cropToSquare(uiImage)
                    if let compressed = cropped.jpegData(compressionQuality: 0.7) {
                        avatarImageData = compressed
                        selectedAvatar = ""
                    }
                }
                isLoadingPhoto = false
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Avatar Preview

    private var avatarPreviewSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.vtBorder, lineWidth: 1)
                    .frame(width: 88, height: 88)

                if isLoadingPhoto {
                    ProgressView()
                        .tint(.vtMuted)
                } else if let data = avatarImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 86, height: 86)
                        .clipShape(Circle())
                } else if !selectedAvatar.isEmpty {
                    Text(selectedAvatar)
                        .font(.system(size: 40))
                } else {
                    Text(editName.isEmpty ? dataService.userInitial : String(editName.prefix(1)).uppercased())
                        .font(.system(size: 34, weight: .light, design: .monospaced))
                        .foregroundColor(.vtText)
                }
            }

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Text(L10n.s(.uploadPhoto, lang))
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.vtMuted)
            }
        }
    }

    // MARK: - Image Processing

    private func cropToSquare(_ image: UIImage) -> UIImage {
        let side = min(image.size.width, image.size.height)
        let origin = CGPoint(
            x: (image.size.width - side) / 2,
            y: (image.size.height - side) / 2
        )
        let cropRect = CGRect(origin: origin, size: CGSize(width: side, height: side))

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else { return image }

        let targetSize = CGSize(width: 256, height: 256)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
                .draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppearanceManager())
        .environment(LanguageManager())
        .environment(DataService(modelContext: PreviewContainer.shared.mainContext))
        .preferredColorScheme(.dark)
}
