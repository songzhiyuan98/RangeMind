import Foundation
import SwiftData
import AuthenticationServices

enum TiltPhase: Equatable {
    case normal
    case watch
    case tilt
    case recovering
}

@MainActor
@Observable
final class DataService {
    private let modelContext: ModelContext

    // 当前玩家数据
    private(set) var player: PlayerData?

    // 当前活跃 session
    private(set) var activeSession: SessionData?

    // 历史 sessions
    private(set) var recentSessions: [SessionData] = []

    // 当前 session 的手牌记录
    private(set) var currentHandRecords: [HandRecordData] = []

    var language: AppLanguage = .english

    // Pro status (placeholder — will be driven by StoreKit)
    var isProUnlocked: Bool { UserDefaults.standard.bool(forKey: "vt_pro_unlocked") }

    // Feature toggles (read from UserDefaults via @AppStorage in views)
    var tiltAlertsEnabled: Bool {
        if UserDefaults.standard.object(forKey: "vt_tilt_enabled") == nil { return true }
        return UserDefaults.standard.bool(forKey: "vt_tilt_enabled")
    }
    var cooldownModeEnabled: Bool {
        if UserDefaults.standard.object(forKey: "vt_cooldown_enabled") == nil { return true }
        return UserDefaults.standard.bool(forKey: "vt_cooldown_enabled")
    }
    // Session game configuration (3-dimension)
    private(set) var sessionGameMode: GameMode = .cash
    private(set) var sessionTableSize: TableSize = .sixMax
    private(set) var sessionTableStyle: PokerTableStyle = .standard

    /// Table size modifier
    var tableSizeModifier: Double {
        switch sessionTableSize {
        case .headsUp: return 8.0
        case .sixMax: return 3.0
        case .nineMax: return -2.0
        case .fullRing: return -5.0
        }
    }

    /// Table style modifier
    var tableStyleModifier: Double {
        switch sessionTableStyle {
        case .standard: return 0.0
        case .loose: return 5.0
        case .friendly: return 8.0
        }
    }

    /// Game mode modifier
    var gameModeModifier: Double {
        switch sessionGameMode {
        case .cash: return 0.0
        case .tournament: return -3.0
        }
    }

    /// Combined table modifier = size + style + mode
    var tableModifier: Double {
        tableSizeModifier + tableStyleModifier + gameModeModifier
    }

    /// Baseline range = player VPIP + table modifier
    var baselinePercent: Double {
        Double(lifetimeVPIP) + tableModifier
    }

    /// Tolerance range = baseline + 10%
    var tolerancePercent: Double {
        baselinePercent + 10.0
    }

    /// Watch threshold (V6: weighted scoring, ~58% of old values)
    var watchThreshold: Double {
        switch sessionGameMode {
        case .cash: return 4.0
        case .tournament: return 3.0
        }
    }

    /// Tilt threshold (V6: weighted scoring)
    var tiltThreshold: Double {
        switch sessionGameMode {
        case .cash: return sessionTableStyle == .friendly ? 7.0 : 6.0
        case .tournament: return 5.0
        }
    }

    /// Consecutive VPIP trigger varies by table size
    var consecutiveVPIPTrigger: Int {
        switch sessionTableSize {
        case .headsUp: return 5
        case .sixMax: return 4
        case .nineMax: return 3
        case .fullRing: return 3
        }
    }

    // cooldownLength removed in V6 — state machine drives recovery naturally

    // V6: 4-state tilt detection
    private(set) var tiltPhase: TiltPhase = .normal
    private(set) var previousTiltPhase: TiltPhase = .normal
    private(set) var lastRecoveryScore: Double = 0
    private(set) var lastLossPoints: Double = 0
    private(set) var lastBehaviorPoints: Double = 0

    // MARK: - User / Account

    private enum AuthKeys {
        static let appleUserID = "vt_apple_user_id"
        static let userName = "vt_user_name"
        static let userEmail = "vt_user_email"
        static let userAvatar = "vt_user_avatar"  // SF Symbol name or emoji
        static let userAvatarImage = "vt_user_avatar_image"  // Custom photo data
        static let guestInstallID = "vt_guest_install_id"
    }

    private(set) var isLoggedIn: Bool = false
    var isGuestMode: Bool { !isLoggedIn }

    /// Stable per-install guest ID, generated once
    var guestInstallID: String {
        if let existing = UserDefaults.standard.string(forKey: AuthKeys.guestInstallID) {
            return existing
        }
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: AuthKeys.guestInstallID)
        return newID
    }

    /// Current user scope: "apple:<id>" or "guest:<installID>"
    var currentUserID: String {
        if let appleID = UserDefaults.standard.string(forKey: AuthKeys.appleUserID), !appleID.isEmpty {
            return "apple:\(appleID)"
        }
        return "guest:\(guestInstallID)"
    }

    private(set) var userName: String = "Guest"
    private(set) var userEmail: String = ""
    private(set) var userAvatar: String = ""  // SF Symbol name, emoji, or empty
    private(set) var userAvatarImageData: Data?  // Custom uploaded photo

    var userInitial: String {
        String(userName.prefix(1)).uppercased()
    }

    /// Update display name (user customization)
    func updateUserName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        userName = trimmed
        UserDefaults.standard.set(trimmed, forKey: AuthKeys.userName)
    }

    /// Update avatar (SF Symbol name or emoji)
    func updateUserAvatar(_ avatar: String) {
        userAvatar = avatar
        UserDefaults.standard.set(avatar, forKey: AuthKeys.userAvatar)
    }

    /// Update avatar with custom photo data
    func updateUserAvatarImage(_ data: Data?) {
        userAvatarImageData = data
        if let data {
            UserDefaults.standard.set(data, forKey: AuthKeys.userAvatarImage)
        } else {
            UserDefaults.standard.removeObject(forKey: AuthKeys.userAvatarImage)
        }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        restoreAuthState()
        loadData()
    }

    // MARK: - Auth State Persistence

    /// Restore auth state from UserDefaults (synchronous, before loadData)
    private func restoreAuthState() {
        if let userID = UserDefaults.standard.string(forKey: AuthKeys.appleUserID),
           !userID.isEmpty {
            isLoggedIn = true
            userName = UserDefaults.standard.string(forKey: AuthKeys.userName) ?? "Player"
            userEmail = UserDefaults.standard.string(forKey: AuthKeys.userEmail) ?? ""
            userAvatar = UserDefaults.standard.string(forKey: AuthKeys.userAvatar) ?? ""
            userAvatarImageData = UserDefaults.standard.data(forKey: AuthKeys.userAvatarImage)
        } else {
            isLoggedIn = false
            userName = "Guest"
            userEmail = ""
            userAvatar = ""
            userAvatarImageData = nil
        }
    }

    // MARK: - Sign in with Apple

    private var signInDelegate: SignInDelegate?

    /// Perform Sign in with Apple
    func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = SignInDelegate { [weak self] result in
            Task { @MainActor in
                self?.handleSignInResult(result)
            }
        }
        self.signInDelegate = delegate
        controller.delegate = delegate
        controller.performRequests()
    }

    /// Handle a completed ASAuthorization (used by SignInWithAppleButton in SwiftUI)
    func handleSignInAuthorization(_ authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        applyAppleCredential(credential)
    }

    private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        signInDelegate = nil

        switch result {
        case .success(let authorization):
            handleSignInAuthorization(authorization)
        case .failure(let error):
            print("Sign in with Apple failed: \(error.localizedDescription)")
        }
    }

    private func applyAppleCredential(_ credential: ASAuthorizationAppleIDCredential) {
        // Capture guest ID before switching to apple context
        let previousGuestUID = "guest:\(guestInstallID)"

        let userID = credential.user

        // Apple only provides name/email on FIRST sign in
        let fullName: String? = {
            guard let name = credential.fullName else { return nil }
            let components = [name.givenName, name.familyName].compactMap { $0 }
            return components.isEmpty ? nil : components.joined(separator: " ")
        }()
        let email = credential.email

        // Persist to UserDefaults
        UserDefaults.standard.set(userID, forKey: AuthKeys.appleUserID)
        if let fullName, !fullName.isEmpty {
            UserDefaults.standard.set(fullName, forKey: AuthKeys.userName)
        }
        if let email, !email.isEmpty {
            UserDefaults.standard.set(email, forKey: AuthKeys.userEmail)
        }

        // Update in-memory state
        isLoggedIn = true
        userName = UserDefaults.standard.string(forKey: AuthKeys.userName) ?? "Player"
        userEmail = UserDefaults.standard.string(forKey: AuthKeys.userEmail) ?? ""
        userAvatar = UserDefaults.standard.string(forKey: AuthKeys.userAvatar) ?? ""
        userAvatarImageData = UserDefaults.standard.data(forKey: AuthKeys.userAvatarImage)

        // Migrate guest data to this apple account
        migrateGuestData(from: previousGuestUID)

        // Reload data in new user context
        activeSession = nil
        currentHandRecords = []
        loadOrCreatePlayer()
        loadActiveSession()
        loadRecentSessions()
    }

    /// Migrate guest sessions and stats to the logged-in user
    private func migrateGuestData(from guestUID: String) {
        let appleUID = currentUserID

        // Migrate guest sessions
        let sessionDescriptor = FetchDescriptor<SessionData>(
            predicate: #Predicate { $0.ownerUserID == guestUID }
        )
        do {
            let guestSessions = try modelContext.fetch(sessionDescriptor)
            for session in guestSessions {
                session.ownerUserID = appleUID
                session.isGuestSession = false
            }

            // Merge guest player stats into apple player
            let guestPlayerDescriptor = FetchDescriptor<PlayerData>(
                predicate: #Predicate { $0.ownerUserID == guestUID }
            )
            let guestPlayers = try modelContext.fetch(guestPlayerDescriptor)
            if let guestPlayer = guestPlayers.first, guestPlayer.lifetimeHands > 0 {
                // Find or create apple player
                let applePlayerDescriptor = FetchDescriptor<PlayerData>(
                    predicate: #Predicate { $0.ownerUserID == appleUID }
                )
                let applePlayers = try modelContext.fetch(applePlayerDescriptor)
                if let applePlayer = applePlayers.first {
                    applePlayer.lifetimeHands += guestPlayer.lifetimeHands
                    applePlayer.lifetimeVPIPHands += guestPlayer.lifetimeVPIPHands
                } else {
                    guestPlayer.ownerUserID = appleUID
                }
                // Delete guest player if it was merged (not reassigned)
                if guestPlayer.ownerUserID == guestUID {
                    modelContext.delete(guestPlayer)
                }
            }

            try modelContext.save()
        } catch {
            print("Failed to migrate guest data: \(error)")
        }
    }

    /// Sign out: clear auth state and revert to guest mode
    /// SwiftData is preserved — signing back in restores everything
    func signOut() {
        // Only clear login flag — preserve name, avatar, email in UserDefaults
        // so re-login restores them (Apple only sends name on first auth)
        UserDefaults.standard.removeObject(forKey: AuthKeys.appleUserID)

        isLoggedIn = false
        userName = "Guest"
        userEmail = ""
        userAvatar = ""
        userAvatarImageData = nil

        // Switch to guest context — reload guest's own data
        activeSession = nil
        currentHandRecords = []
        loadOrCreatePlayer()
        loadActiveSession()
        loadRecentSessions()
    }

    /// Check if Apple credential is still valid. Call on app launch.
    func checkAppleCredentialState() {
        guard let userID = UserDefaults.standard.string(forKey: AuthKeys.appleUserID),
              !userID.isEmpty else {
            return
        }

        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userID) { [weak self] state, _ in
            Task { @MainActor in
                switch state {
                case .revoked, .notFound:
                    self?.signOut()
                case .authorized:
                    break
                case .transferred:
                    break
                @unknown default:
                    break
                }
            }
        }
    }

    // MARK: - 数据加载

    private func loadData() {
        migrateOwnerlessData()
        loadOrCreatePlayer()
        loadActiveSession()
        loadRecentSessions()
    }

    /// One-time migration: assign ownerUserID to legacy data that has none
    private func migrateOwnerlessData() {
        let uid = currentUserID
        // Migrate sessions without ownerUserID
        let sessionDesc = FetchDescriptor<SessionData>(
            predicate: #Predicate { $0.ownerUserID == "" }
        )
        // Migrate players without ownerUserID
        let playerDesc = FetchDescriptor<PlayerData>(
            predicate: #Predicate { $0.ownerUserID == "" }
        )
        do {
            let sessions = try modelContext.fetch(sessionDesc)
            for s in sessions {
                s.ownerUserID = uid
            }
            let players = try modelContext.fetch(playerDesc)
            for p in players {
                p.ownerUserID = uid
            }
            if !sessions.isEmpty || !players.isEmpty {
                try modelContext.save()
            }
        } catch {
            print("Failed to migrate ownerless data: \(error)")
        }
    }

    private func loadOrCreatePlayer() {
        let uid = currentUserID
        let descriptor = FetchDescriptor<PlayerData>(
            predicate: #Predicate { $0.ownerUserID == uid }
        )
        do {
            let players = try modelContext.fetch(descriptor)
            if let existingPlayer = players.first {
                player = existingPlayer
            } else {
                // Migrate legacy player (ownerUserID == "") if exists
                let legacyDescriptor = FetchDescriptor<PlayerData>(
                    predicate: #Predicate { $0.ownerUserID == "" }
                )
                let legacyPlayers = try modelContext.fetch(legacyDescriptor)
                if let legacy = legacyPlayers.first {
                    legacy.ownerUserID = uid
                    try modelContext.save()
                    player = legacy
                } else {
                    let newPlayer = PlayerData(ownerUserID: uid)
                    modelContext.insert(newPlayer)
                    try modelContext.save()
                    player = newPlayer
                }
            }
        } catch {
            print("Failed to load player: \(error)")
        }
    }

    private func loadActiveSession() {
        let uid = currentUserID
        var descriptor = FetchDescriptor<SessionData>(
            predicate: #Predicate { $0.endTime == nil && $0.ownerUserID == uid }
        )
        descriptor.fetchLimit = 1

        do {
            let sessions = try modelContext.fetch(descriptor)
            activeSession = sessions.first

            if let session = activeSession {
                // Restore game configuration from session
                sessionGameMode = session.gameMode
                sessionTableSize = session.tableSize
                sessionTableStyle = session.tableStyle
                loadHandRecords(for: session)
            }
        } catch {
            print("Failed to load active session: \(error)")
        }
    }

    private func loadRecentSessions() {
        let uid = currentUserID
        var descriptor = FetchDescriptor<SessionData>(
            predicate: #Predicate { $0.endTime != nil && $0.ownerUserID == uid },
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        descriptor.fetchLimit = 10

        do {
            recentSessions = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load recent sessions: \(error)")
        }
    }

    private func loadHandRecords(for session: SessionData) {
        let sessionId = session.id
        let descriptor = FetchDescriptor<HandRecordData>(
            predicate: #Predicate { $0.session?.id == sessionId },
            sortBy: [SortDescriptor(\.timestamp)]
        )

        do {
            currentHandRecords = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load hand records: \(error)")
        }
    }

    // MARK: - Session 操作

    func startSession(title: String? = nil, gameMode: GameMode = .cash, tableSize: TableSize = .sixMax, tableStyle: PokerTableStyle = .standard) {
        guard activeSession == nil else { return }
        sessionGameMode = gameMode
        sessionTableSize = tableSize
        sessionTableStyle = tableStyle

        let newSession = SessionData(
            ownerUserID: currentUserID,
            isGuestSession: isGuestMode,
            title: title,
            gameMode: gameMode,
            tableSize: tableSize,
            tableStyle: tableStyle
        )
        modelContext.insert(newSession)

        do {
            try modelContext.save()
            activeSession = newSession
            currentHandRecords = []
            resetTiltPhase()
        } catch {
            print("Failed to start session: \(error)")
        }
    }

    func endSession() -> SessionData? {
        guard let session = activeSession else { return nil }

        session.endTime = Date()

        do {
            try modelContext.save()
            let endedSession = session
            activeSession = nil
            currentHandRecords = []
            resetTiltPhase()

            loadRecentSessions()

            return endedSession
        } catch {
            print("Failed to end session: \(error)")
            return nil
        }
    }

    func deleteSession(_ session: SessionData) {
        // Reverse lifetime stats
        if let p = player {
            p.lifetimeHands = max(0, p.lifetimeHands - session.totalHands)
            p.lifetimeVPIPHands = max(0, p.lifetimeVPIPHands - session.vpipHands)
        }

        // Delete from database (cascade deletes hand records)
        modelContext.delete(session)

        do {
            try modelContext.save()
            // Reload sessions list
            loadRecentSessions()
        } catch {
            print("Failed to delete session: \(error)")
        }
    }

    // MARK: - GTO Deviation Check

    /// Check if the action deviates from GTO.
    /// For VPIP: deviation if hand is NOT in any open raise range (should have folded).
    /// For Fold: deviation if hand IS in most open raise ranges (should have played).
    private func checkGTODeviation(handType: String?, didVPIP: Bool) -> Bool? {
        guard let hand = handType else { return nil }

        if didVPIP {
            // VPIP'd a hand that GTO says fold → deviation
            let inAnyRange = GTORange.openRaiseRanges.values.contains { $0.contains(hand) }
            if !inAnyRange && !GTORange.callingRanges.values.contains(where: { $0.contains(hand) }) {
                return true
            }
            // Obviously weak hand → always deviation
            if GTORange.isObviouslyWeak(hand: hand) {
                return true
            }
            return false
        } else {
            // Folded a hand that GTO says play from most positions → deviation
            // Count how many positions this hand is in the open raise range
            let openCount = GTORange.openRaiseRanges.values.filter { $0.contains(hand) }.count
            // If playable from 4+ positions (out of 6), folding is a deviation
            if openCount >= 4 {
                return true
            }
            return false
        }
    }

    // MARK: - 记录手牌

    func recordFold(card1: String? = nil, card2: String? = nil, isSuited: Bool? = nil) {
        guard let session = activeSession else { return }

        session.totalHands += 1

        // Compute hand type for deviation check
        var handType: String? = nil
        if let c1 = card1, let c2 = card2 {
            let ranks = ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]
            let sorted = [c1, c2].sorted { ranks.firstIndex(of: $0)! < ranks.firstIndex(of: $1)! }
            if c1 == c2 {
                handType = "\(c1)\(c2)"
            } else {
                let suffix = (isSuited ?? false) ? "s" : "o"
                handType = "\(sorted[0])\(sorted[1])\(suffix)"
            }
        }
        let deviation = checkGTODeviation(handType: handType, didVPIP: false)

        let record = HandRecordData(didVPIP: false, card1Rank: card1, card2Rank: card2, isSuited: isSuited, isGTODeviation: deviation, session: session)
        modelContext.insert(record)

        player?.addHand(didVPIP: false)

        do {
            try modelContext.save()
            currentHandRecords.append(record)
            checkTiltPhaseTransition()
        } catch {
            print("Failed to record fold: \(error)")
        }
    }

    func recordVPIP(
        card1: String,
        card2: String,
        isSuited: Bool?,
        result: HandResult,
        emotionSignal: EmotionSignal? = nil,
        bbResult: Double? = nil,
        position: PokerPosition? = nil,
        actionType: ActionType? = nil
    ) {
        guard let session = activeSession else { return }

        session.totalHands += 1
        session.vpipHands += 1

        // 累计 BB 结果
        if let bb = bbResult {
            session.totalBBResult = (session.totalBBResult ?? 0) + bb
        }

        // Compute hand type for deviation check
        let ranks = ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]
        let sorted = [card1, card2].sorted { ranks.firstIndex(of: $0)! < ranks.firstIndex(of: $1)! }
        let vpipHandType: String
        if card1 == card2 {
            vpipHandType = "\(card1)\(card2)"
        } else {
            let suffix = (isSuited ?? false) ? "s" : "o"
            vpipHandType = "\(sorted[0])\(sorted[1])\(suffix)"
        }
        let deviation = checkGTODeviation(handType: vpipHandType, didVPIP: true)

        let record = HandRecordData(
            didVPIP: true,
            card1Rank: card1,
            card2Rank: card2,
            isSuited: isSuited,
            result: result,
            isGTODeviation: deviation,
            emotionSignal: emotionSignal,
            bbResult: bbResult,
            position: position,
            actionType: actionType,
            session: session
        )
        modelContext.insert(record)

        player?.addHand(didVPIP: true)

        do {
            try modelContext.save()
            currentHandRecords.append(record)
            checkTiltPhaseTransition()
        } catch {
            print("Failed to record VPIP: \(error)")
        }
    }

    func deleteHandRecord(_ record: HandRecordData) {
        guard let session = activeSession else { return }

        // Update session counters
        session.totalHands -= 1
        if record.didVPIP {
            session.vpipHands -= 1
            // Reverse BB result
            if let bb = record.bbResult {
                session.totalBBResult = (session.totalBBResult ?? 0) - bb
            }
        }

        // Update player lifetime stats
        if let p = player {
            p.lifetimeHands = max(0, p.lifetimeHands - 1)
            if record.didVPIP {
                p.lifetimeVPIPHands = max(0, p.lifetimeVPIPHands - 1)
            }
        }

        // Remove from in-memory array
        currentHandRecords.removeAll { $0.id == record.id }

        // Delete from database
        modelContext.delete(record)

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete hand record: \(error)")
        }
    }

    // MARK: - 统计计算

    var lifetimeVPIP: Int {
        player?.lifetimeVPIP ?? sessionVPIP
    }

    var lifetimeHands: Int {
        player?.lifetimeHands ?? 0
    }

    var sessionVPIP: Int {
        activeSession?.sessionVPIP ?? 0
    }

    var sessionHands: Int {
        activeSession?.totalHands ?? 0
    }

    var thirtyMinVPIP: Int {
        let thirtyMinAgo = Date().addingTimeInterval(-1800)
        let recentHands = currentHandRecords.filter { $0.timestamp >= thirtyMinAgo }

        guard !recentHands.isEmpty else { return sessionVPIP }

        let vpipCount = recentHands.filter { $0.didVPIP }.count
        return Int(Double(vpipCount) / Double(recentHands.count) * 100)
    }

    var thirtyMinHandCount: Int {
        let thirtyMinAgo = Date().addingTimeInterval(-1800)
        return currentHandRecords.filter { $0.timestamp >= thirtyMinAgo }.count
    }

    var hasActiveSession: Bool {
        activeSession != nil
    }

    // MARK: - Hand History Helpers

    func isHandProfitable(_ handType: String) -> Bool {
        let history = getHandHistory(handType: handType)
        guard history.count >= 2 else { return false }
        let totalBB = history.compactMap { $0.bbResult }.reduce(0, +)
        return totalBB > 0
    }

    // MARK: - Risk Score Tilt Detection (V6: Decay-Weighted + Recovery)

    private let premiumHands: Set<String> = [
        "AA", "KK", "QQ", "JJ", "TT", "99",
        "AKs", "AQs", "AJs", "ATs", "KQs", "KJs",
        "AKo", "AQo"
    ]

    /// Decay weights for positions 1 (newest) to 8 (oldest)
    private let decayWeights: [Double] = [1.00, 0.85, 0.72, 0.60, 0.50, 0.40, 0.32, 0.25]

    /// Classify a hand using the percentile-based baseline/tolerance system
    private func classifyHand(_ handType: String) -> HandPercentile.Classification {
        return HandPercentile.classify(handType, baseline: baselinePercent, tolerance: tolerancePercent)
    }

    /// Check if a hand represents "normal behavior"
    func isNormalBehavior(_ hand: HandRecordData) -> Bool {
        // Has active tilt emotion signal → not normal
        if hand.emotionSignal == .tilt { return false }

        if !hand.didVPIP {
            // fold without bad emotion is normal
            return hand.emotionSignal == nil || hand.emotionSignal == .badBeat || hand.emotionSignal == .cooler
        }

        // VPIP hand: check classification
        if let ht = hand.handType {
            let classification = classifyHand(ht)
            if classification == .deviation { return false }
        }

        // Big loss → not normal
        if let bb = hand.bbResult, bb <= -30 { return false }

        return true
    }

    /// Calculate weighted risk score from last 8 hands (V6)
    func calculateWeightedRiskScore() -> (weightedRisk: Double, lossPoints: Double, behaviorPoints: Double) {
        let recent = Array(currentHandRecords.suffix(8))
        guard recent.count >= 5 else { return (0, 0, 0) }

        var weightedRisk: Double = 0
        var lossPoints: Double = 0
        var behaviorPoints: Double = 0
        var consecutiveVPIP = 0
        var maxConsecutiveVPIP = 0
        var hasDeviation = false
        var hasLoss = false
        var hasEmotion = false

        // Index 0 = newest hand, index N = oldest hand
        let reversed = Array(recent.reversed())
        for (i, hand) in reversed.enumerated() {
            let weight = i < decayWeights.count ? decayWeights[i] : 0.25
            var handRisk: Double = 0
            var handLoss: Double = 0
            var handBehavior: Double = 0

            if hand.didVPIP {
                consecutiveVPIP += 1
                maxConsecutiveVPIP = max(maxConsecutiveVPIP, consecutiveVPIP)

                // Base VPIP: +1
                handRisk += 1
                handBehavior += 1

                // Hand classification
                if let ht = hand.handType {
                    let classification = classifyHand(ht)
                    switch classification {
                    case .baseline:
                        break
                    case .edge:
                        handRisk += 1
                        handBehavior += 1
                        hasDeviation = true
                    case .deviation:
                        handRisk += 2
                        handBehavior += 2
                        hasDeviation = true
                    }
                }

                // Single hand loss (non-stacking: ≥80 takes +3, ≥30 takes +2)
                if let bb = hand.bbResult {
                    if bb <= -80 {
                        handRisk += 3
                        handLoss += 3
                        hasLoss = true
                    } else if bb <= -30 {
                        handRisk += 2
                        handLoss += 2
                        hasLoss = true
                    }
                }
            } else {
                consecutiveVPIP = 0
            }

            // Emotion signals within this hand (5-hand window check)
            if let emotion = hand.emotionSignal {
                let emotionWindow = Array(currentHandRecords.suffix(5))
                if emotionWindow.contains(where: { $0.id == hand.id }) {
                    hasEmotion = true
                    switch emotion {
                    case .badBeat:
                        handRisk += 2
                        handLoss += 2
                    case .cooler:
                        handRisk += 2
                        handLoss += 2
                    case .tilt:
                        handRisk += 4
                        handBehavior += 4
                    }
                }
            }

            weightedRisk += handRisk * weight
            lossPoints += handLoss * weight
            behaviorPoints += handBehavior * weight
        }

        // Global bonus: consecutive VPIP (not weighted)
        if maxConsecutiveVPIP >= consecutiveVPIPTrigger {
            weightedRisk += 2
            behaviorPoints += 2
        }

        // VPIP-only cap: if no deviation/loss/emotion, raw risk capped at 4
        if !hasDeviation && !hasLoss && !hasEmotion {
            weightedRisk = min(weightedRisk, 4.0)
            behaviorPoints = min(behaviorPoints, 4.0)
        }

        return (weightedRisk, lossPoints, behaviorPoints)
    }

    /// Calculate weighted recovery score (V6)
    func calculateWeightedRecoveryScore() -> Double {
        let recent = Array(currentHandRecords.suffix(8))
        guard recent.count >= 5 else { return 0 }

        let reversed = Array(recent.reversed()) // index 0 = newest

        // Recovery validity: at least 1 of the 2 most recent hands must be normal
        let recentTwo = Array(reversed.prefix(2))
        let recentNormalCount = recentTwo.filter { isNormalBehavior($0) }.count
        guard recentNormalCount >= 1 else { return 0 }

        var weightedRecovery: Double = 0

        for (i, hand) in reversed.enumerated() {
            let weight = i < decayWeights.count ? decayWeights[i] : 0.25
            guard isNormalBehavior(hand) else { continue }

            var recovery: Double = 0

            if !hand.didVPIP {
                // fold = +1.0
                recovery += 1.0
            } else {
                // VPIP in baseline/tolerance = +1.25
                recovery += 1.25
            }

            // Consecutive normal bonus: +0.5 if previous hand was also normal
            if i + 1 < reversed.count && isNormalBehavior(reversed[i + 1]) {
                recovery += 0.5
            }

            // No emotion signal: +0.25
            if hand.emotionSignal == nil {
                recovery += 0.25
            }

            weightedRecovery += recovery * weight
        }

        return weightedRecovery
    }

    /// Calculate net score (V6): risk - recovery
    func calculateNetScore() -> (netScore: Double, weightedRisk: Double, weightedRecovery: Double, lossPoints: Double, behaviorPoints: Double) {
        let risk = calculateWeightedRiskScore()
        let recovery = calculateWeightedRecoveryScore()
        let net = risk.weightedRisk - recovery
        return (net, risk.weightedRisk, recovery, risk.lossPoints, risk.behaviorPoints)
    }

    /// Count high-risk deviations in last N hands
    private func recentDeviationCount(_ n: Int) -> Int {
        let recent = Array(currentHandRecords.suffix(n))
        return recent.filter { hand in
            guard hand.didVPIP, let ht = hand.handType else { return false }
            return classifyHand(ht) == .deviation
        }.count
    }

    /// Count normal hands in last N hands
    private func recentNormalCount(_ n: Int) -> Int {
        let recent = Array(currentHandRecords.suffix(n))
        return recent.filter { isNormalBehavior($0) }.count
    }

    /// Check if the latest hand has a new deviation or emotion signal
    private var latestHandIsDeviation: Bool {
        guard let last = currentHandRecords.last else { return false }
        if let emotion = last.emotionSignal, emotion == .tilt || emotion == .badBeat || emotion == .cooler {
            return true
        }
        guard last.didVPIP, let ht = last.handType else { return false }
        return classifyHand(ht) == .deviation
    }

    /// Check if the latest hand is a "correction" — a correct DECISION regardless of outcome.
    /// Checks decision quality (hand in range, no emotion), NOT the BB result.
    /// Used to block Watch → Tilt escalation and trigger positive feedback.
    private var latestHandIsCorrection: Bool {
        guard let last = currentHandRecords.last else { return false }
        guard last.emotionSignal == nil else { return false }

        if !last.didVPIP {
            // Fold without emotion is always a correct decision
            return true
        }

        // VPIP: hand must be within baseline/tolerance (not deviation)
        if let ht = last.handType {
            let classification = classifyHand(ht)
            if classification == .deviation { return false }
        }

        return true
    }

    /// V6: Phase-based tilt alert message
    private var phaseBasedAlert: TiltCoachMessage? {
        guard sessionHands >= 5 else { return nil }

        let isLossDominant = lastLossPoints > lastBehaviorPoints

        switch tiltPhase {
        case .normal:
            // One-time positive feedback when just recovered from elevated state via fold
            if previousTiltPhase != .normal && latestHandIsCorrection {
                if let last = currentHandRecords.last, !last.didVPIP {
                    return TiltCoachMessage(
                        type: .watch,
                        category: isLossDominant ? .lossTilt : .techTilt,
                        headline: L10n.s(.normalReturnH, language),
                        detail: L10n.s(.normalReturnD, language)
                    )
                }
            }
            return nil

        case .watch:
            // Correction = positive detail under the main status headline
            let category: TiltCategory = isLossDominant ? .lossTilt : .techTilt
            let headline = isLossDominant ? L10n.s(.lossTiltH, language) : L10n.s(.techTiltH, language)

            if latestHandIsCorrection {
                let isFold = currentHandRecords.last.map { !$0.didVPIP } ?? false
                let detail = isFold
                    ? L10n.s(.watchFoldD, language)
                    : L10n.s(.watchCorrectionD, language)
                return TiltCoachMessage(
                    type: .watch,
                    category: category,
                    headline: isFold ? L10n.s(.watchFoldH, language) : headline,
                    detail: detail
                )
            }

            return TiltCoachMessage(
                type: .watch,
                category: category,
                headline: headline,
                detail: isLossDominant ? L10n.s(.watchLossTiltD, language) : L10n.s(.watchTechTiltD, language)
            )

        case .tilt:
            let category: TiltCategory = isLossDominant ? .lossTilt : .techTilt
            let headline = isLossDominant ? L10n.s(.lossTiltH, language) : L10n.s(.techTiltH, language)

            if latestHandIsCorrection {
                let isFold = currentHandRecords.last.map { !$0.didVPIP } ?? false
                let detail = isFold
                    ? L10n.s(.tiltFoldD, language)
                    : L10n.s(.tiltCorrectionD, language)
                return TiltCoachMessage(
                    type: .danger,
                    category: category,
                    headline: isFold ? L10n.s(.tiltFoldH, language) : headline,
                    detail: detail
                )
            }

            return TiltCoachMessage(
                type: .danger,
                category: category,
                headline: headline,
                detail: isLossDominant ? L10n.s(.lossTiltDangerD, language) : L10n.s(.techTiltDangerD, language)
            )

        case .recovering:
            if latestHandIsCorrection {
                let isFold = currentHandRecords.last.map { !$0.didVPIP } ?? false
                return TiltCoachMessage(
                    type: .recovering,
                    category: .techTilt,
                    headline: isFold ? L10n.s(.recoveringFoldH, language) : L10n.s(.recoveringCorrectionH, language),
                    detail: isFold ? L10n.s(.recoveringFoldD, language) : L10n.s(.recoveringCorrectionD, language)
                )
            }
            return TiltCoachMessage(
                type: .recovering,
                category: .techTilt,
                headline: L10n.s(.recoveringH, language),
                detail: L10n.s(.recoveringD, language)
            )
        }
    }

    /// Big Pot — tiered event alert (Large 100-149, Huge 150-249, Massive ≥250)
    var bigPotAlert: TiltCoachMessage? {
        guard let lastHand = currentHandRecords.last,
              lastHand.didVPIP,
              let bb = lastHand.bbResult,
              let tier = PotTier.from(bb: bb) else { return nil }

        let handType = lastHand.handType
        let isStrong = handType.map { premiumHands.contains($0) } ?? false
        let isWin = bb > 0

        let headline: String
        switch tier {
        case .large:   headline = L10n.s(.bigPotH, language)
        case .huge:    headline = L10n.s(.bigPotHugeH, language)
        case .massive: headline = L10n.s(.bigPotMassiveH, language)
        }

        let type: TiltCoachMessage.MessageType
        let detail: String

        switch (isStrong, isWin, tier) {
        // Strong hand WIN
        case (true, true, .large):
            type = .warning
            detail = L10n.s(.bigPotWinStrongD, language)
        case (true, true, .huge):
            type = .warning
            detail = L10n.s(.bigPotWinStrongHugeD, language)
        case (true, true, .massive):
            type = .warning
            detail = L10n.s(.bigPotWinStrongMassiveD, language)

        // Strong hand LOSS
        case (true, false, .large):
            type = .warning
            detail = L10n.s(.bigPotLossStrongD, language)
        case (true, false, .huge):
            type = .warning
            detail = L10n.s(.bigPotLossStrongHugeD, language)
        case (true, false, .massive):
            type = .danger
            detail = L10n.s(.bigPotLossStrongMassiveD, language)

        // Weak hand WIN
        case (false, true, .large):
            type = .warning
            detail = L10n.s(.bigPotWinWeakD, language)
        case (false, true, .huge):
            type = .warning
            detail = L10n.s(.bigPotWinWeakHugeD, language)
        case (false, true, .massive):
            type = .danger
            detail = L10n.s(.bigPotWinWeakMassiveD, language)

        // Weak hand LOSS
        case (false, false, .large):
            type = .danger
            detail = L10n.s(.bigPotLossWeakD, language)
        case (false, false, .huge):
            type = .danger
            detail = L10n.s(.bigPotLossWeakHugeD, language)
        case (false, false, .massive):
            type = .danger
            detail = L10n.s(.bigPotLossWeakMassiveD, language)
        }

        return TiltCoachMessage(
            type: type,
            category: .bigPot,
            headline: headline,
            detail: detail
        )
    }

    // MARK: - V6: 4-State Phase Transitions

    /// Called after every hand record to check phase transitions
    func checkTiltPhaseTransition() {
        guard cooldownModeEnabled else { return }
        guard currentHandRecords.count >= 5 else { return }

        let scores = calculateNetScore()
        let netScore = scores.netScore
        let weightedRecovery = scores.weightedRecovery

        // Store for UI display
        lastLossPoints = scores.lossPoints
        lastBehaviorPoints = scores.behaviorPoints

        // Track previous phase for post-transition positive feedback
        previousTiltPhase = tiltPhase

        switch tiltPhase {
        case .normal:
            // Normal → Watch: netScore >= watchThreshold
            if netScore >= watchThreshold {
                tiltPhase = .watch
            }

        case .watch:
            // Correction protection: if the latest hand is a clear correction,
            // do NOT escalate to Tilt this hand. The user is actively adjusting.
            let correctionBlocked = latestHandIsCorrection

            // Watch → Tilt: netScore >= tiltThreshold OR 2 deviations in last 3 hands
            // BUT blocked if latest hand is a correction
            if !correctionBlocked && (netScore >= tiltThreshold || recentDeviationCount(3) >= 2) {
                tiltPhase = .tilt
            }
            // Watch → Normal: netScore < watchThreshold
            else if netScore < watchThreshold {
                tiltPhase = .normal
            }

        case .tilt:
            // Tilt → Recovering: netScore < tiltThreshold AND last 2 hands normal AND recovery rising
            let last2Normal = recentNormalCount(2) >= 2
            let recoveryRising = weightedRecovery > lastRecoveryScore

            if netScore < tiltThreshold && last2Normal && recoveryRising {
                tiltPhase = .recovering
            }

        case .recovering:
            // Recovering → Watch/Tilt: new deviation detected
            if latestHandIsDeviation {
                if netScore >= tiltThreshold {
                    tiltPhase = .tilt
                } else {
                    tiltPhase = .watch
                }
            }
            // Recovering → Normal: netScore < watchThreshold AND ≥3 of last 4 normal
            else if netScore < watchThreshold && recentNormalCount(4) >= 3 {
                tiltPhase = .normal
            }
        }

        // Update last recovery score for trend detection
        lastRecoveryScore = weightedRecovery
    }

    /// Reset tilt state (called when session ends or starts)
    func resetTiltPhase() {
        tiltPhase = .normal
        previousTiltPhase = .normal
        lastRecoveryScore = 0
        lastLossPoints = 0
        lastBehaviorPoints = 0
    }

    // MARK: - Aggregated Status & Alerts

    /// Returns the active coach message: big pot first (event), then phase-based
    var activeCoachMessage: TiltCoachMessage? {
        guard tiltAlertsEnabled else { return nil }

        // Big pot is independent event — always check first
        if let msg = bigPotAlert { return msg }

        // Phase-based alert (V6)
        return phaseBasedAlert
    }

    var currentStatus: GlowStatus {
        switch tiltPhase {
        case .tilt: return .danger
        case .watch: return .warning
        case .recovering: return .recovering
        case .normal: break
        }

        // Even if phase is normal, check for big pot alert
        if let msg = activeCoachMessage {
            switch msg.type {
            case .danger: return .danger
            case .warning, .watch: return .warning
            case .recovering: return .recovering
            }
        }

        return .normal
    }

    var currentAlert: TiltAlert? {
        guard let msg = activeCoachMessage else { return nil }
        let alertType: TiltAlert.AlertType = (msg.type == .danger) ? .danger : .warning
        return TiltAlert(type: alertType, message: msg.headline)
    }

    // MARK: - 统计数据

    func getRecentTrend() -> [DayVPIP] {
        // 获取最近 7 天的 VPIP 趋势
        let calendar = Calendar.current
        var trend: [DayVPIP] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }

            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            let daySessions = recentSessions.filter {
                $0.startTime >= startOfDay && $0.startTime < endOfDay
            }

            let totalHands = daySessions.reduce(0) { $0 + $1.totalHands }
            let vpipHands = daySessions.reduce(0) { $0 + $1.vpipHands }
            let vpip = totalHands > 0 ? Int(Double(vpipHands) / Double(totalHands) * 100) : 0

            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            formatter.locale = Locale(identifier: "zh_CN")

            trend.append(DayVPIP(label: formatter.string(from: date), vpip: vpip))
        }

        return trend
    }

    func getTopHands() -> [HandStat] {
        // 统计所有手牌
        var handStats: [String: (playCount: Int, winCount: Int)] = [:]

        for session in recentSessions {
            for record in session.handRecords where record.didVPIP {
                guard let handType = record.handType else { continue }

                var stat = handStats[handType] ?? (0, 0)
                stat.playCount += 1
                if record.result == .win {
                    stat.winCount += 1
                }
                handStats[handType] = stat
            }
        }

        // 也统计当前 session
        for record in currentHandRecords where record.didVPIP {
            guard let handType = record.handType else { continue }

            var stat = handStats[handType] ?? (0, 0)
            stat.playCount += 1
            if record.result == .win {
                stat.winCount += 1
            }
            handStats[handType] = stat
        }

        // 排序并取前 5
        return handStats
            .map { HandStat(handType: $0.key, playCount: $0.value.playCount, winCount: $0.value.winCount) }
            .sorted { $0.playCount > $1.playCount }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Pro 统计功能

    // 位置 VPIP 分析
    func getPositionStats() -> [PositionStat] {
        var positionData: [PokerPosition: (total: Int, vpip: Int, wins: Int, bbResult: Double)] = [:]

        // 初始化所有位置
        for position in PokerPosition.allCases {
            positionData[position] = (0, 0, 0, 0)
        }

        // 统计所有 session
        for session in recentSessions {
            for record in session.handRecords {
                guard let position = record.position else { continue }
                var stat = positionData[position]!
                stat.total += 1
                if record.didVPIP {
                    stat.vpip += 1
                    if record.result == .win {
                        stat.wins += 1
                    }
                    stat.bbResult += record.bbResult ?? 0
                }
                positionData[position] = stat
            }
        }

        // 当前 session
        for record in currentHandRecords {
            guard let position = record.position else { continue }
            var stat = positionData[position]!
            stat.total += 1
            if record.didVPIP {
                stat.vpip += 1
                if record.result == .win {
                    stat.wins += 1
                }
                stat.bbResult += record.bbResult ?? 0
            }
            positionData[position] = stat
        }

        return PokerPosition.allCases.map { position in
            let data = positionData[position]!
            let vpipPercent = data.total > 0 ? Int(Double(data.vpip) / Double(data.total) * 100) : 0
            let winRate = data.vpip > 0 ? Int(Double(data.wins) / Double(data.vpip) * 100) : 0
            return PositionStat(
                position: position,
                totalHands: data.total,
                vpipHands: data.vpip,
                vpipPercent: vpipPercent,
                winRate: winRate,
                bbResult: data.bbResult
            )
        }
    }

    // 入池方式分析
    func getActionTypeStats() -> [ActionTypeStat] {
        var actionData: [ActionType: (count: Int, wins: Int, bbResult: Double)] = [:]

        for action in ActionType.allCases {
            actionData[action] = (0, 0, 0)
        }

        for session in recentSessions {
            for record in session.handRecords where record.didVPIP {
                guard let action = record.actionType else { continue }
                var stat = actionData[action]!
                stat.count += 1
                if record.result == .win {
                    stat.wins += 1
                }
                stat.bbResult += record.bbResult ?? 0
                actionData[action] = stat
            }
        }

        for record in currentHandRecords where record.didVPIP {
            guard let action = record.actionType else { continue }
            var stat = actionData[action]!
            stat.count += 1
            if record.result == .win {
                stat.wins += 1
            }
            stat.bbResult += record.bbResult ?? 0
            actionData[action] = stat
        }

        return ActionType.allCases.map { action in
            let data = actionData[action]!
            let winRate = data.count > 0 ? Int(Double(data.wins) / Double(data.count) * 100) : 0
            return ActionTypeStat(
                actionType: action,
                count: data.count,
                winRate: winRate,
                bbResult: data.bbResult
            )
        }
    }

    // BB 统计
    var totalBBResult: Double {
        var total: Double = 0
        for session in recentSessions {
            total += session.totalBBResult ?? 0
        }
        total += activeSession?.totalBBResult ?? 0
        return total
    }

    var bb100: Double {
        let totalHands = lifetimeHands
        guard totalHands >= 100 else { return 0 }
        return (totalBBResult / Double(totalHands)) * 100
    }

    // 手牌 EV 分析
    func getHandEVStats() -> [HandEVStat] {
        var handData: [String: (plays: Int, bbResult: Double)] = [:]

        for session in recentSessions {
            for record in session.handRecords where record.didVPIP {
                guard let handType = record.handType else { continue }
                var stat = handData[handType] ?? (0, 0)
                stat.plays += 1
                stat.bbResult += record.bbResult ?? 0
                handData[handType] = stat
            }
        }

        for record in currentHandRecords where record.didVPIP {
            guard let handType = record.handType else { continue }
            var stat = handData[handType] ?? (0, 0)
            stat.plays += 1
            stat.bbResult += record.bbResult ?? 0
            handData[handType] = stat
        }

        return handData
            .filter { $0.value.plays >= 3 } // 至少玩过3次
            .map { HandEVStat(handType: $0.key, plays: $0.value.plays, totalBB: $0.value.bbResult) }
            .sorted { $0.bbPer100 > $1.bbPer100 }
    }

    // MARK: - 手牌历史

    /// 获取某个手牌类型的历史记录
    func getHandHistory(handType: String) -> [HandRecordData] {
        var history: [HandRecordData] = []

        // 从历史 session 中收集
        for session in recentSessions {
            for record in session.handRecords where record.didVPIP && record.handType == handType {
                history.append(record)
            }
        }

        // 从当前 session 收集
        for record in currentHandRecords where record.didVPIP && record.handType == handType {
            history.append(record)
        }

        // 按时间倒序
        return history.sorted { $0.timestamp > $1.timestamp }
    }

    // MARK: - GTO 范围分析

    /// 分析单手牌的 GTO 合规性
    func analyzeGTO(hand: String, position: PokerPosition, action: ActionType) -> GTOAnalysisResult {
        let isInRange = GTORange.isInRange(hand: hand, position: position, action: action)
        let deviation = GTORange.getDeviationLevel(hand: hand, position: position, action: action)

        var recommendation = ""
        if !isInRange {
            let recommendedRange = GTORange.getRecommendedRange(position: position)
            if recommendedRange.isEmpty {
                recommendation = "建议在 \(position.rawValue) 位置更谨慎"
            } else {
                recommendation = "该位置标准范围不包含此牌"
            }
        }

        return GTOAnalysisResult(
            hand: hand,
            position: position,
            action: action,
            isInRange: isInRange,
            deviationLevel: deviation,
            recommendation: recommendation
        )
    }

    /// 检查是否有连续 GTO 偏离并输掉大池
    var gtoDeviationAlert: GTODeviationAlert? {
        // 获取最近的入池手牌
        let recentVPIPHands = currentHandRecords.filter { $0.didVPIP }.suffix(5)
        guard recentVPIPHands.count >= 3 else { return nil }

        var deviatedLossHands: [String] = []
        var totalBBLoss: Double = 0

        for hand in recentVPIPHands {
            guard let handType = hand.handType,
                  let position = hand.position,
                  let action = hand.actionType else { continue }

            // 如果这手牌历史上盈利，跳过
            if isHandProfitable(handType) {
                continue
            }

            let deviation = GTORange.getDeviationLevel(hand: handType, position: position, action: action)

            // 只统计偏离且输掉的手牌
            if deviation.shouldWarn && hand.result == .notWin {
                deviatedLossHands.append(handType)
                if let bb = hand.bbResult, bb < 0 {
                    totalBBLoss += bb
                }
            }
        }

        // 如果有3+手偏离范围并且输了
        if deviatedLossHands.count >= 3 {
            if totalBBLoss <= -20 {
                return GTODeviationAlert(
                    message: "偏离范围连输 \(deviatedLossHands.count) 手，共 \(Int(totalBBLoss))BB",
                    severity: .significant,
                    hands: deviatedLossHands
                )
            } else {
                return GTODeviationAlert(
                    message: "偏离范围连输 \(deviatedLossHands.count) 手",
                    severity: .moderate,
                    hands: deviatedLossHands
                )
            }
        }

        // 如果打了真正的弱牌（历史不盈利）并输掉大池
        if let lastHand = recentVPIPHands.last,
           let handType = lastHand.handType,
           classifyHand(handType) == .deviation,
           let bb = lastHand.bbResult, bb <= -15 {
            return GTODeviationAlert(
                message: "\(handType) 是弱牌，刚输掉 \(Int(abs(bb)))BB，请收紧范围",
                severity: .severe,
                hands: [handType]
            )
        }

        return nil
    }

    /// 获取本场 GTO 合规统计
    func getGTOComplianceStats() -> GTOComplianceStats {
        let vpipHands = currentHandRecords.filter { $0.didVPIP }
        var inRangeCount = 0
        var outOfRangeCount = 0
        var deviationDetails: [String: Int] = [:]

        for hand in vpipHands {
            guard let handType = hand.handType,
                  let position = hand.position,
                  let action = hand.actionType else { continue }

            if GTORange.isInRange(hand: handType, position: position, action: action) {
                inRangeCount += 1
            } else {
                outOfRangeCount += 1
                deviationDetails[handType, default: 0] += 1
            }
        }

        let total = inRangeCount + outOfRangeCount
        let complianceRate = total > 0 ? Int(Double(inRangeCount) / Double(total) * 100) : 100

        // 找出最常偏离的手牌
        let topDeviations = deviationDetails
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }

        return GTOComplianceStats(
            totalAnalyzed: total,
            inRangeCount: inRangeCount,
            outOfRangeCount: outOfRangeCount,
            complianceRate: complianceRate,
            topDeviations: topDeviations
        )
    }

    // 疲劳检测
    func getFatigueStatus() -> FatigueStatus? {
        guard let session = activeSession else { return nil }

        let sessionLength = Date().timeIntervalSince(session.startTime)
        let isLongSession = sessionLength >= 3 * 3600 // 3小时以上

        // 计算 VPIP 趋势
        let hands = currentHandRecords
        guard hands.count >= 20 else {
            return FatigueStatus(
                sessionLength: sessionLength,
                vpipTrend: .stable,
                isLongSession: isLongSession,
                recommendation: nil
            )
        }

        let midPoint = hands.count / 2
        let firstHalf = Array(hands.prefix(midPoint))
        let secondHalf = Array(hands.suffix(midPoint))

        let firstVPIP = Double(firstHalf.filter { $0.didVPIP }.count) / Double(firstHalf.count) * 100
        let secondVPIP = Double(secondHalf.filter { $0.didVPIP }.count) / Double(secondHalf.count) * 100

        let trend: FatigueStatus.VPIPTrend
        if secondVPIP - firstVPIP >= 8 {
            trend = .increasing
        } else if firstVPIP - secondVPIP >= 8 {
            trend = .decreasing
        } else {
            trend = .stable
        }

        // 生成建议
        var recommendation: String? = nil
        if isLongSession && trend == .increasing {
            recommendation = "已打3小时以上，入池率在上升，建议休息15分钟"
        } else if isLongSession {
            recommendation = "已打3小时以上，注意保持专注"
        } else if trend == .increasing && sessionLength >= 2 * 3600 {
            recommendation = "入池率有上升趋势，注意控制"
        }

        return FatigueStatus(
            sessionLength: sessionLength,
            vpipTrend: trend,
            isLongSession: isLongSession,
            recommendation: recommendation
        )
    }

    // Tilt 频率分析
    func getTiltAnalysis() -> TiltAnalysis {
        var tiltSessions = 0
        var totalTiltMinutes = 0

        for session in recentSessions {
            // 检查该 session 是否有 tilt
            let hands = session.handRecords
            guard hands.count >= 10 else { continue }

            let midPoint = hands.count / 2
            let firstHalf = Array(hands.prefix(midPoint))
            let secondHalf = Array(hands.suffix(midPoint))

            let firstVPIP = firstHalf.isEmpty ? 0 : Double(firstHalf.filter { $0.didVPIP }.count) / Double(firstHalf.count) * 100
            let secondVPIP = secondHalf.isEmpty ? 0 : Double(secondHalf.filter { $0.didVPIP }.count) / Double(secondHalf.count) * 100

            if secondVPIP - firstVPIP >= 10 {
                tiltSessions += 1
                totalTiltMinutes += Int(session.duration / 60)
            }
        }

        let totalSessions = recentSessions.count
        let tiltRate = totalSessions > 0 ? Int(Double(tiltSessions) / Double(totalSessions) * 100) : 0
        let avgTiltDuration = tiltSessions > 0 ? totalTiltMinutes / tiltSessions : 0

        return TiltAnalysis(
            totalSessions: totalSessions,
            tiltSessions: tiltSessions,
            tiltRate: tiltRate,
            avgTiltDuration: avgTiltDuration
        )
    }

    // MARK: - Today Stats (for Stats page)

    func getTodayStats() -> TodayStats {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        // Gather today's sessions
        let todaySessions = recentSessions.filter { $0.startTime >= startOfToday }

        var totalHands = 0
        var vpipHands = 0
        var bbResult: Double = 0
        var hasBBData = false
        var tiltWarnings = 0
        var tiltDangers = 0
        var cooldownCount = 0
        var deviationCount = 0
        var weakEntryCount = 0

        for session in todaySessions {
            totalHands += session.totalHands
            vpipHands += session.vpipHands
            if let bb = session.totalBBResult {
                bbResult += bb
                hasBBData = true
            }

            for hand in session.handRecords {
                if hand.isGTODeviation == true && hand.didVPIP {
                    deviationCount += 1
                }
                if hand.didVPIP, let ht = hand.handType {
                    if GTORange.isObviouslyWeak(hand: ht) {
                        weakEntryCount += 1
                    }
                }
            }
        }

        // Include active session if it started today
        if let active = activeSession, active.startTime >= startOfToday {
            totalHands += active.totalHands
            vpipHands += active.vpipHands
            if let bb = active.totalBBResult {
                bbResult += bb
                hasBBData = true
            }

            for hand in currentHandRecords {
                if hand.isGTODeviation == true && hand.didVPIP {
                    deviationCount += 1
                }
                if hand.didVPIP, let ht = hand.handType {
                    if GTORange.isObviouslyWeak(hand: ht) {
                        weakEntryCount += 1
                    }
                }
            }
        }

        let vpip = totalHands > 0 ? Int(Double(vpipHands) / Double(totalHands) * 100) : 0

        // Discipline score: start at 100, deduct for bad behavior
        var discipline = 100
        discipline -= deviationCount * 5   // -5 per deviation hand
        discipline -= weakEntryCount * 8   // -8 per weak entry
        discipline -= tiltDangers * 10     // -10 per danger
        discipline -= tiltWarnings * 3     // -3 per warning
        discipline = max(0, min(100, discipline))

        return TodayStats(
            totalHands: totalHands,
            vpip: vpip,
            bbResult: hasBBData ? bbResult : nil,
            disciplineScore: totalHands >= 10 ? discipline : nil,
            tiltWarnings: tiltWarnings,
            tiltDangers: tiltDangers,
            cooldownCount: cooldownCount,
            deviationCount: deviationCount,
            weakEntryCount: weakEntryCount
        )
    }
}

struct TodayStats {
    let totalHands: Int
    let vpip: Int
    let bbResult: Double?
    let disciplineScore: Int?
    let tiltWarnings: Int
    let tiltDangers: Int
    let cooldownCount: Int
    let deviationCount: Int
    let weakEntryCount: Int
}

// MARK: - Pro 统计模型

struct PositionStat: Identifiable {
    let id = UUID()
    let position: PokerPosition
    let totalHands: Int
    let vpipHands: Int
    let vpipPercent: Int
    let winRate: Int
    let bbResult: Double

    var isOptimal: Bool {
        switch position {
        case .utg: return vpipPercent <= 15
        case .mp: return vpipPercent <= 18
        case .co: return vpipPercent <= 25
        case .btn: return vpipPercent <= 35
        case .sb: return vpipPercent <= 30
        case .bb: return vpipPercent <= 20
        }
    }
}

struct ActionTypeStat: Identifiable {
    let id = UUID()
    let actionType: ActionType
    let count: Int
    let winRate: Int
    let bbResult: Double
}

struct HandEVStat: Identifiable {
    let id = UUID()
    let handType: String
    let plays: Int
    let totalBB: Double

    var bbPer100: Double {
        guard plays > 0 else { return 0 }
        return (totalBB / Double(plays)) * 100
    }
}

struct TiltAnalysis {
    let totalSessions: Int
    let tiltSessions: Int
    let tiltRate: Int
    let avgTiltDuration: Int
}

struct GTOComplianceStats {
    let totalAnalyzed: Int
    let inRangeCount: Int
    let outOfRangeCount: Int
    let complianceRate: Int
    let topDeviations: [String]

    var isGood: Bool {
        complianceRate >= 80
    }
}

// MARK: - 疲劳检测

// MARK: - GTO 偏离警告

struct GTODeviationAlert {
    let message: String
    let severity: GTORange.DeviationLevel
    let hands: [String]  // 偏离的手牌列表

    var icon: String {
        switch severity {
        case .severe: return "🚫"
        case .significant: return "⚠️"
        case .moderate: return "⚡️"
        default: return "💡"
        }
    }
}

struct FatigueStatus {
    let sessionLength: TimeInterval
    let vpipTrend: VPIPTrend
    let isLongSession: Bool
    let recommendation: String?

    enum VPIPTrend {
        case stable
        case increasing
        case decreasing
    }

    var trendIcon: String {
        switch vpipTrend {
        case .stable: return "→"
        case .increasing: return "↗️"
        case .decreasing: return "↘️"
        }
    }

    var trendText: String {
        switch vpipTrend {
        case .stable: return "稳定"
        case .increasing: return "上升中"
        case .decreasing: return "下降中"
        }
    }
}

// MARK: - ASAuthorizationController Delegate

private class SignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    let completion: (Result<ASAuthorization, Error>) -> Void

    init(completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.completion = completion
    }

    func authorizationController(controller: ASAuthorizationController,
                                  didCompleteWithAuthorization authorization: ASAuthorization) {
        completion(.success(authorization))
    }

    func authorizationController(controller: ASAuthorizationController,
                                  didCompleteWithError error: Error) {
        completion(.failure(error))
    }
}
