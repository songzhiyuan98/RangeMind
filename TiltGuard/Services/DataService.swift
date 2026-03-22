import Foundation
import SwiftData

enum TiltPhase: Equatable {
    case normal
    case observing
    case cooldown
}

enum CooldownTrigger: Equatable {
    case lossBased   // loss-chase, revenge tilt
    case winBased    // win-tilt, overconfidence
    case driftBased  // general VPIP drift, style drift
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

    // Feature toggles (read from UserDefaults via @AppStorage in views)
    var tiltAlertsEnabled: Bool {
        if UserDefaults.standard.object(forKey: "vt_tilt_enabled") == nil { return true }
        return UserDefaults.standard.bool(forKey: "vt_tilt_enabled")
    }
    var cooldownModeEnabled: Bool {
        if UserDefaults.standard.object(forKey: "vt_cooldown_enabled") == nil { return true }
        return UserDefaults.standard.bool(forKey: "vt_cooldown_enabled")
    }

    // Cooldown system
    private(set) var tiltPhase: TiltPhase = .normal
    private(set) var phaseStartHandCount: Int = 0
    private(set) var cooldownRemaining: Int = 0
    private(set) var cooldownTotal: Int = 0
    private(set) var cooldownTrigger: CooldownTrigger = .driftBased
    private var observationWindowSize: Int = 5
    private var initialCooldownHands: Int = 10
    private var maxCooldownHands: Int = 20

    // MARK: - User / Account

    var isLoggedIn: Bool { true } // TODO: Sign in with Apple — temporarily true to unlock all features

    var isGuestMode: Bool { !isLoggedIn }

    var userName: String { isLoggedIn ? "Player" : "Guest" }

    var userEmail: String { "" }

    var userInitial: String {
        String(userName.prefix(1)).uppercased()
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadData()
    }

    // MARK: - 数据加载

    private func loadData() {
        if isGuestMode {
            // Guest mode: clean up any stale data from previous sessions
            cleanGuestData()
        }
        loadOrCreatePlayer()
        loadActiveSession()
        loadRecentSessions()
    }

    /// Guest mode: delete all completed sessions on app launch
    private func cleanGuestData() {
        let descriptor = FetchDescriptor<SessionData>(
            predicate: #Predicate { $0.endTime != nil }
        )
        do {
            let staleSessions = try modelContext.fetch(descriptor)
            for session in staleSessions {
                modelContext.delete(session)
            }
            // Reset player stats
            let playerDescriptor = FetchDescriptor<PlayerData>()
            let players = try modelContext.fetch(playerDescriptor)
            for p in players {
                p.lifetimeHands = 0
                p.lifetimeVPIPHands = 0
            }
            try modelContext.save()
        } catch {
            print("Failed to clean guest data: \(error)")
        }
    }

    private func loadOrCreatePlayer() {
        let descriptor = FetchDescriptor<PlayerData>()
        do {
            let players = try modelContext.fetch(descriptor)
            if let existingPlayer = players.first {
                player = existingPlayer
            } else {
                let newPlayer = PlayerData()
                modelContext.insert(newPlayer)
                try modelContext.save()
                player = newPlayer
            }
        } catch {
            print("Failed to load player: \(error)")
        }
    }

    private func loadActiveSession() {
        var descriptor = FetchDescriptor<SessionData>(
            predicate: #Predicate { $0.endTime == nil }
        )
        descriptor.fetchLimit = 1

        do {
            let sessions = try modelContext.fetch(descriptor)
            activeSession = sessions.first

            if let session = activeSession {
                loadHandRecords(for: session)
            }
        } catch {
            print("Failed to load active session: \(error)")
        }
    }

    private func loadRecentSessions() {
        if isGuestMode {
            recentSessions = []
            return
        }

        var descriptor = FetchDescriptor<SessionData>(
            predicate: #Predicate { $0.endTime != nil },
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

    func startSession() {
        guard activeSession == nil else { return }

        let newSession = SessionData()
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

            if isGuestMode {
                // Guest mode: don't persist history, don't accumulate lifetime stats
                // Session data remains in memory for summary view but won't survive app restart
            } else {
                loadRecentSessions()
            }

            return endedSession
        } catch {
            print("Failed to end session: \(error)")
            return nil
        }
    }

    func deleteSession(_ session: SessionData) {
        // Reverse lifetime stats for logged-in users
        if !isGuestMode, let p = player {
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

        if !isGuestMode {
            player?.addHand(didVPIP: false)
        }

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
            bbResult: bbResult,
            position: position,
            actionType: actionType,
            session: session
        )
        modelContext.insert(record)

        if !isGuestMode {
            player?.addHand(didVPIP: true)
        }

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
        if !isGuestMode {
            if let p = player {
                p.lifetimeHands = max(0, p.lifetimeHands - 1)
                if record.didVPIP {
                    p.lifetimeVPIPHands = max(0, p.lifetimeVPIPHands - 1)
                }
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
        if isGuestMode {
            // Guest: use session VPIP as baseline for tilt detection
            return sessionVPIP
        }
        return player?.lifetimeVPIP ?? 0
    }

    var lifetimeHands: Int {
        if isGuestMode { return 0 }
        return player?.lifetimeHands ?? 0
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

    // MARK: - Tilt Detection (Event → Behavioral Deviation)

    // Hands outside the player's usual range
    private let theoreticalWeakHands: Set<String> = [
        "KTo", "QTo", "JTo", "K9o", "Q9o", "J9o",
        "K9s", "Q9s", "J8s", "K7s", "Q8s", "J7s",
        "A9o", "K8o", "Q7o", "T9o", "98o", "87o"
    ]

    func isHandProfitable(_ handType: String) -> Bool {
        let history = getHandHistory(handType: handType)
        guard history.count >= 2 else { return false }
        let totalBB = history.compactMap { $0.bbResult }.reduce(0, +)
        return totalBB > 0
    }

    func isActuallyWeakHand(_ handType: String) -> Bool {
        if isHandProfitable(handType) { return false }
        return theoreticalWeakHands.contains(handType)
    }

    // --- Raw signals (used by multiple detectors) ---

    var hasConsecutiveLosses: Bool {
        let recentVPIPHands = currentHandRecords.filter { $0.didVPIP }.suffix(4)
        guard recentVPIPHands.count >= 4 else { return false }
        return recentVPIPHands.allSatisfy { $0.result == .notWin }
    }

    var hasWeakRangeExpansion: Bool {
        let recentVPIPHands = currentHandRecords.filter { $0.didVPIP }.suffix(5)
        guard recentVPIPHands.count >= 3 else { return false }
        let weakHandCount = recentVPIPHands.filter { hand in
            // Use recorded GTO deviation if available, otherwise fall back to weak hand check
            if let deviation = hand.isGTODeviation { return deviation }
            guard let handType = hand.handType else { return false }
            return isActuallyWeakHand(handType)
        }.count
        return weakHandCount >= 3
    }

    /// Recent GTO deviation rate (last N hands with card data)
    var recentGTODeviationCount: Int {
        let recentWithCards = currentHandRecords.suffix(10).filter { $0.isGTODeviation != nil }
        return recentWithCards.filter { $0.isGTODeviation == true }.count
    }

    var hasProgressiveLoosening: Bool {
        guard currentHandRecords.count >= 20 else { return false }
        let midPoint = currentHandRecords.count / 2
        let firstHalf = Array(currentHandRecords.prefix(midPoint))
        let secondHalf = Array(currentHandRecords.suffix(midPoint))

        let firstVPIPCount = firstHalf.filter { $0.didVPIP }.count
        let firstVPIP = firstHalf.isEmpty ? 0 : Int(Double(firstVPIPCount) / Double(firstHalf.count) * 100)

        let secondVPIPCount = secondHalf.filter { $0.didVPIP }.count
        let secondVPIP = secondHalf.isEmpty ? 0 : Int(Double(secondVPIPCount) / Double(secondHalf.count) * 100)

        return secondVPIP - firstVPIP >= 10
    }

    var hasBigLossRevengeTilt: Bool {
        guard currentHandRecords.count >= 10 else { return false }
        let vpipHands = currentHandRecords.filter { $0.didVPIP }
        guard let bigLossIndex = vpipHands.lastIndex(where: { ($0.bbResult ?? 0) <= -15 }) else {
            return false
        }
        let bigLossHand = vpipHands[bigLossIndex]
        let handsAfterLoss = currentHandRecords.filter { $0.timestamp > bigLossHand.timestamp }
        guard handsAfterLoss.count >= 5 else { return false }
        let vpipAfterLoss = handsAfterLoss.filter { $0.didVPIP }.count
        let vpipRateAfter = Double(vpipAfterLoss) / Double(handsAfterLoss.count) * 100
        return vpipRateAfter >= 40
    }

    var consecutiveBigLosses: Int {
        let vpipHands = currentHandRecords.filter { $0.didVPIP }.suffix(6)
        var count = 0
        for hand in vpipHands.reversed() {
            if let bb = hand.bbResult, bb <= -10 {
                count += 1
            } else if hand.result == .win {
                break
            }
        }
        return count
    }

    var sessionBBLoss: Double {
        return activeSession?.totalBBResult ?? 0
    }

    // MARK: - 4 Core Deviation Detectors

    /// 1. VPIP Drift — basic: 30min VPIP significantly above lifetime
    var vpipDriftAlert: TiltCoachMessage? {
        guard thirtyMinHandCount >= 8 else { return nil }
        let diff = thirtyMinVPIP - lifetimeVPIP
        if diff >= 15 {
            return TiltCoachMessage(
                type: .danger,
                headline: L10n.s(.tiltVpipDriftDangerH, language),
                detail: String(format: L10n.s(.tiltVpipDriftDangerD, language), diff)
            )
        }
        if diff >= 10 {
            return TiltCoachMessage(
                type: .warning,
                headline: L10n.s(.tiltVpipDriftWarnH, language),
                detail: L10n.s(.tiltVpipDriftWarnD, language)
            )
        }
        return nil
    }

    /// 2. Win-Tilt (顺风膨胀) — after winning streak, range expands
    var winTiltAlert: TiltCoachMessage? {
        guard currentHandRecords.count >= 15 else { return nil }

        let vpipHands = currentHandRecords.filter { $0.didVPIP }
        guard vpipHands.count >= 5 else { return nil }

        // Check: recent results skew positive
        let recent10 = Array(vpipHands.suffix(10))
        let winCount = recent10.filter { $0.result == .win }.count
        let winRate = Double(winCount) / Double(recent10.count)

        guard winRate >= 0.6 else { return nil } // Winning more than 60%

        // Check: VPIP expanding after the wins
        let recentVPIPRate: Int = {
            let recent = Array(currentHandRecords.suffix(8))
            guard !recent.isEmpty else { return 0 }
            return Int(Double(recent.filter { $0.didVPIP }.count) / Double(recent.count) * 100)
        }()

        let expansion = recentVPIPRate - lifetimeVPIP
        guard expansion >= 8 else { return nil }

        // Check: weak hands creeping in
        let recentWeakCount = vpipHands.suffix(5).filter { hand in
            guard let ht = hand.handType else { return false }
            return isActuallyWeakHand(ht)
        }.count

        if recentWeakCount >= 2 {
            return TiltCoachMessage(
                type: .warning,
                headline: L10n.s(.tiltWinStreakH, language),
                detail: L10n.s(.tiltWinStreakD, language)
            )
        }

        if expansion >= 12 {
            return TiltCoachMessage(
                type: .warning,
                headline: L10n.s(.tiltWinMomentumH, language),
                detail: String(format: L10n.s(.tiltWinMomentumD, language), expansion)
            )
        }

        return nil
    }

    /// 3. Loss-Chase (逆风追损) — after losses, VPIP spikes trying to recover
    var lossChaseAlert: TiltCoachMessage? {
        guard currentHandRecords.count >= 15 else { return nil }

        // Signal A: recent results skew negative
        let vpipHands = currentHandRecords.filter { $0.didVPIP }
        let recent8 = Array(vpipHands.suffix(8))
        guard recent8.count >= 5 else { return nil }

        let lossCount = recent8.filter { $0.result == .notWin }.count
        let lossRate = Double(lossCount) / Double(recent8.count)

        guard lossRate >= 0.6 else { return nil } // Losing more than 60%

        // Signal B: VPIP spiking after the losses
        let postLossVPIPRate: Int = {
            let recent = Array(currentHandRecords.suffix(8))
            guard !recent.isEmpty else { return 0 }
            return Int(Double(recent.filter { $0.didVPIP }.count) / Double(recent.count) * 100)
        }()

        let spike = postLossVPIPRate - lifetimeVPIP
        guard spike >= 8 else { return nil }

        // Big loss revenge is the strongest signal
        if hasBigLossRevengeTilt {
            return TiltCoachMessage(
                type: .danger,
                headline: L10n.s(.tiltLossChaseH, language),
                detail: L10n.s(.tiltLossChaseD, language)
            )
        }

        return TiltCoachMessage(
            type: .warning,
            headline: L10n.s(.tiltLossRisingH, language),
            detail: L10n.s(.tiltLossRisingD, language)
        )
    }

    /// 4. Style Drift (风格失真) — playing hands outside personal baseline
    var styleDriftAlert: TiltCoachMessage? {
        guard currentHandRecords.count >= 15 else { return nil }

        let vpipHands = currentHandRecords.filter { $0.didVPIP }
        guard vpipHands.count >= 5 else { return nil }

        // Build personal baseline from lifetime data
        var lifetimeHandTypes: Set<String> = []
        for session in recentSessions {
            for record in session.handRecords where record.didVPIP {
                if let ht = record.handType { lifetimeHandTypes.insert(ht) }
            }
        }

        // If not enough lifetime data, skip this check
        guard lifetimeHandTypes.count >= 8 else { return nil }

        // Check recent hands for types never/rarely played before OR recorded GTO deviations
        let recentHands = Array(vpipHands.suffix(8))
        var unusualHands: [String] = []

        for hand in recentHands {
            guard let ht = hand.handType else { continue }
            // Count as unusual if: recorded GTO deviation, OR not in lifetime baseline + weak
            if hand.isGTODeviation == true {
                unusualHands.append(ht)
            } else if !lifetimeHandTypes.contains(ht) && isActuallyWeakHand(ht) {
                unusualHands.append(ht)
            }
        }

        if unusualHands.count >= 3 {
            let examples = Array(Set(unusualHands)).prefix(2).joined(separator: ", ")
            return TiltCoachMessage(
                type: .danger,
                headline: L10n.s(.tiltStyleDepartH, language),
                detail: String(format: L10n.s(.tiltStyleDepartD, language), examples)
            )
        }

        if unusualHands.count >= 2 {
            return TiltCoachMessage(
                type: .warning,
                headline: L10n.s(.tiltStylePatternH, language),
                detail: L10n.s(.tiltStylePatternD, language)
            )
        }

        // Also check progressive loosening as a style drift signal
        if hasProgressiveLoosening {
            return TiltCoachMessage(
                type: .warning,
                headline: L10n.s(.tiltStyleWidenedH, language),
                detail: L10n.s(.tiltStyleWidenedD, language)
            )
        }

        return nil
    }

    // MARK: - Cooldown System

    /// Called after every hand record (fold or VPIP) to check phase transitions
    func checkTiltPhaseTransition() {
        switch tiltPhase {
        case .normal:
            guard cooldownModeEnabled else { return }
            // If a coach message fired, enter observation
            if sessionHands >= 15 {
                // Detect which alert type triggered, to tailor cooldown exit conditions
                if lossChaseAlert != nil {
                    cooldownTrigger = .lossBased
                } else if winTiltAlert != nil {
                    cooldownTrigger = .winBased
                } else if activeCoachMessage != nil {
                    cooldownTrigger = .driftBased
                } else {
                    return // No alert, stay normal
                }
                tiltPhase = .observing
                phaseStartHandCount = sessionHands
            }

        case .observing:
            let handsSinceWarning = sessionHands - phaseStartHandCount
            guard handsSinceWarning >= observationWindowSize else { return }

            // Check if behavior improved (using trigger-specific logic)
            if isStillDeviating(for: cooldownTrigger) {
                // Upgrade to cooldown
                tiltPhase = .cooldown
                cooldownTotal = initialCooldownHands
                cooldownRemaining = initialCooldownHands
                phaseStartHandCount = sessionHands
            } else {
                // Behavior improved, back to normal
                tiltPhase = .normal
                phaseStartHandCount = 0
            }

        case .cooldown:
            cooldownRemaining = max(0, cooldownTotal - (sessionHands - phaseStartHandCount))

            if cooldownRemaining <= 0 {
                // Cooldown complete
                tiltPhase = .normal
                phaseStartHandCount = 0
                cooldownTotal = 0
                cooldownRemaining = 0
            } else if isStillDeviating(for: cooldownTrigger) && cooldownTotal < maxCooldownHands {
                // Extend cooldown (+5, gentler for win-tilt)
                let extension_ = cooldownTrigger == .winBased ? 3 : 5
                let newTotal = min(cooldownTotal + extension_, maxCooldownHands)
                cooldownRemaining += (newTotal - cooldownTotal)
                cooldownTotal = newTotal
            }
        }
    }

    /// Check if the user is still deviating, with trigger-specific exit conditions
    ///
    /// - lossBased: VPIP elevated OR weak hands OR losses + wide range
    /// - winBased: VPIP elevated OR weak hands (losses don't count — user is winning)
    /// - driftBased: VPIP elevated OR weak hands OR losses + wide range
    private func isStillDeviating(for trigger: CooldownTrigger) -> Bool {
        let recentHands = Array(currentHandRecords.suffix(5))
        guard recentHands.count >= 3 else { return false }

        // Shared signal: VPIP rate still elevated
        let recentVPIPCount = recentHands.filter { $0.didVPIP }.count
        let recentVPIPRate = Int(Double(recentVPIPCount) / Double(recentHands.count) * 100)
        let vpipElevated = recentVPIPRate - lifetimeVPIP >= 10

        // Shared signal: Weak hands / GTO deviations still present
        let weakHandCount = recentHands.filter { hand in
            // Use recorded GTO deviation if available
            if let deviation = hand.isGTODeviation { return deviation }
            guard hand.didVPIP, let ht = hand.handType else { return false }
            return isActuallyWeakHand(ht)
        }.count
        let weakHandsPresent = weakHandCount >= 2

        // Shared signal: High GTO deviation rate in recent hands
        let gtoDeviations = recentHands.filter { $0.isGTODeviation == true }.count
        let highDeviationRate = gtoDeviations >= 3

        switch trigger {
        case .winBased:
            return vpipElevated || weakHandsPresent || highDeviationRate

        case .lossBased, .driftBased:
            let recentVPIP = recentHands.filter { $0.didVPIP }
            let lossCount = recentVPIP.filter { $0.result == .notWin }.count
            let negativeAndLoose = lossCount >= 2 && recentVPIPCount >= 3
            return vpipElevated || weakHandsPresent || negativeAndLoose || highDeviationRate
        }
    }

    /// Reset cooldown state (called when session ends or starts)
    func resetTiltPhase() {
        tiltPhase = .normal
        phaseStartHandCount = 0
        cooldownRemaining = 0
        cooldownTotal = 0
        cooldownTrigger = .driftBased
    }

    // MARK: - Aggregated Status & Alerts

    /// Returns the most severe coach message, or nil
    var activeCoachMessage: TiltCoachMessage? {
        guard tiltAlertsEnabled else { return nil }
        // Priority: loss-chase > style-drift > win-tilt > vpip-drift
        // (loss-chase is most urgent, vpip-drift is most generic)
        guard sessionHands >= 15 else { return nil }

        if let msg = lossChaseAlert { return msg }
        if let msg = styleDriftAlert, msg.type == .danger { return msg }
        if let msg = winTiltAlert { return msg }
        if let msg = styleDriftAlert { return msg }
        if let msg = vpipDriftAlert { return msg }
        return nil
    }

    var currentStatus: GlowStatus {
        if tiltPhase == .cooldown { return .danger }
        if tiltPhase == .observing { return .warning }

        guard sessionHands >= 15 else { return .normal }
        guard thirtyMinHandCount >= 8 else { return .normal }

        if let msg = activeCoachMessage {
            switch msg.type {
            case .danger: return sessionHands >= 20 ? .danger : .warning
            case .warning: return .warning
            }
        }

        return .normal
    }

    var currentAlert: TiltAlert? {
        guard let msg = activeCoachMessage else { return nil }
        return TiltAlert(
            type: msg.type == .danger ? .danger : .warning,
            message: msg.headline
        )
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
           isActuallyWeakHand(handType),
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
