import Foundation

// Centralized localization strings
// Usage: L10n.s(.tabHome, lang)
enum L10n {
    enum Key {
        // Tab bar
        case tabHome, tabLive, tabStats, tabMe

        // Home
        case vpipTracker, lifetimeVPIP, buildingProfile, handsProgress
        case hands, sessions, startSession, continueSession
        case recent, viewAll

        // Session
        case end, establishingBaseline, moreToUnlockVPIP
        case sessionVPIP, thirtyMinVPIP, lifetime
        case entries, fold, vpip
        case noActiveSession, startFromHome

        // Stats
        case statistics, bbStats, totalBB, bb100
        case position, actionType, gtoCompliance
        case inRange, common_deviations, tightenRange
        case tiltAnalysis, rate, avgDur
        case highTiltFrequency
        case playerProfileUnlocks, noDataYet

        // Settings / Me
        case account, settings, about
        case appearance, language, notifications
        case signInWithApple, guest, signInToSync
        case guestDataLocal, connected, signOut, signOutConfirm
        case editProfile, displayName, chooseAvatar, uploadPhoto, removePhoto, cropPhotoTitle
        case version, privacyPolicy, termsOfUse
        case feedback, feedbackSubject, feedbackBody

        // Language settings
        case languageTitle, languageDescription

        // Appearance settings
        case mode, system, light, dark

        // Notification settings
        case notificationTitle, sessionReminder, tiltAlert
        case sessionReminderDesc, tiltAlertDesc
        case gtoAdviceToggle, gtoAdviceToggleDesc

        // Tilt category toggles (user-facing)
        case lossTiltToggle, lossTiltToggleDesc
        case winTiltToggle, winTiltToggleDesc
        case techTiltToggle, techTiltToggleDesc
        case bigPotToggle, bigPotToggleDesc

        // Alert intensity
        case alertIntensity
        case intensityLight, intensityLightDesc
        case intensityStandard, intensityStandardDesc
        case intensityStrict, intensityStrictDesc

        // Advanced settings
        case advanced, advancedDesc
        case alertCategories
        case advancedCustom, advancedCustomDesc, advancedCustomPro
        // 5 internal detectors (Pro custom mode)
        case detectorLossChase, detectorLossChaseDesc
        case detectorWinTilt, detectorWinTiltDesc
        case detectorStyleDrift, detectorStyleDriftDesc
        case detectorVpipDrift, detectorVpipDriftDesc
        case detectorBigPot, detectorBigPotDesc
        case detectorPriority

        // Onboarding
        case welcomeTitle, welcomeSubtitle
        case welcomeFeature1, welcomeFeature2, welcomeFeature3
        case continueAsGuest
        case onboardingSkip, onboardingContinue
        case onboardingDetectTitle, onboardingDetectBody
        case onboardingDisciplineTitle, onboardingDisciplineBody
        case onboardingProTitle, onboardingProBody
        case onboardingProFeature1, onboardingProFeature2, onboardingProFeature3, onboardingProFeature4
        case onboardingProMonthly, onboardingProYearly, onboardingProOr
        case onboardingProTrial, onboardingProFree, onboardingProEarly
        case onboardingSignInTitle, onboardingSignInBody

        // Guest mode
        case guestSession, guestDataNotSaved
        case saveThisSession, signInToKeepStats
        case guestBannerTitle, guestBannerSubtitle

        // Input view
        case suited, offsuit, history
        case quickFold, foldWithCards, recordFold

        // Session/Home row labels
        case today, yesterday, handsCount, duration
        case hourShort, minuteShort
        case winRate, vpipHands, date

        // Stats view extras
        case std, dev
        case todayPerformance, playStyle
        case disciplineScore, netResult, resultTrackingDisabled
        case tiltWarnings, tiltDangers, cooldownCompleted
        case baselineVPIP, deviationHands, deviationHandsDesc
        case weakHandEntries, weakHandEntriesDesc

        // Session view extras
        case vsSession, vsLifetime, eqLifetime
        case handNumber, handNumberSuffix
        case adjust, watch

        // Summary view
        case premiumRate, luck, bigSwings, premiumHands
        case goodLuck, normalLuck, belowAvg, unlucky
        case sessionOverview, vpipControl, tiltEvents, sessionInsight
        case handsPlayed, vpipDeviation
        case controlRating, excellent, good, loose, veryLoose
        case tiltAlertsTriggered, cooldownActivated
        case recoveryTime, recoveryHands
        case rangeDiscipline, weakEntries, weakEntriesCooling
        case sessionRating
        case insightNormal, insightTilted, insightRecovered
        case comparedToAvg

        // All sessions
        case allSessions

        // App name
        case appName, appFullName

        // General
        case cancel, done, save, delete, optional
        case win, loss
        case sessionComplete
        case yourHand, positionLabel, action, bbAmount

        // Tilt Coach — simplified 4-category messages
        case lossTiltH, lossTiltWarnD, lossTiltDangerD
        case winTiltH, winTiltD
        case techTiltH, techTiltWarnD, techTiltDangerD
        case bigPotH, bigPotHugeH, bigPotMassiveH
        case bigPotWinStrongD, bigPotWinStrongHugeD, bigPotWinStrongMassiveD
        case bigPotLossStrongD, bigPotLossStrongHugeD, bigPotLossStrongMassiveD
        case bigPotWinWeakD, bigPotWinWeakHugeD, bigPotWinWeakMassiveD
        case bigPotLossWeakD, bigPotLossWeakHugeD, bigPotLossWeakMassiveD
        case sessionBB
        case statsLocked, statsLockedDesc
        case playMoreHands

        // GTO Advice
        case gtoAdvice, gtoOpenRaise, gtoNotInRange
        case gtoAllPositions, gtoMidLate, gtoLateOnly, gtoBtnOnly
        case gtoPremium, gtoFoldPre
        case positionGuide, sixMax, nineMax, tapForGuide
        case gameModeCash, gameModeTournament
        case gameModeLabel, tableSizeLabel, tableStyleLabel
        case tableSizeHU, tableSizeSixMax, tableSizeNineMax, tableSizeFullRing
        case tableStyleStandard, tableStyleLoose, tableStyleFriendly
        case sessionTitleLabel, sessionTitlePlaceholder
        case vpipOptionalHint
        case emotionSignalLabel, emotionBadBeat, emotionCooler, emotionTilt
        case posUtgDesc, posMpDesc, posCoDesc, posBtnDesc, posSbDesc, posBbDesc
        case posUtg1Desc, posUtg2Desc, posLjDesc, posHjDesc

        // Strategy (Home dial)
        case strategyTight, strategyBalanced, strategyLoose
        case strategyInsight, strategyInsightTitle
        case targetVPIP, currentVPIP
        case strategyTightDesc, strategyBalancedDesc, strategyLooseDesc

        // Cooldown
        case cooldownMode, cooldownSuggestion
        case cooldownRemaining, cooldownExtended
        case cooldownObserving, cooldownObservingDesc
        case cooldownModeDesc
        case tightenRange2
    }

    static func s(_ key: Key, _ lang: AppLanguage) -> String {
        switch lang {
        case .english: return en(key)
        case .chinese: return zh(key)
        }
    }

    static func gameModeName(_ mode: GameMode, _ lang: AppLanguage) -> String {
        switch mode {
        case .cash: return s(.gameModeCash, lang)
        case .tournament: return s(.gameModeTournament, lang)
        }
    }

    static func tableSizeName(_ size: TableSize, _ lang: AppLanguage) -> String {
        switch size {
        case .headsUp: return s(.tableSizeHU, lang)
        case .sixMax: return s(.tableSizeSixMax, lang)
        case .nineMax: return s(.tableSizeNineMax, lang)
        case .fullRing: return s(.tableSizeFullRing, lang)
        }
    }

    static func tableStyleName(_ style: PokerTableStyle, _ lang: AppLanguage) -> String {
        switch style {
        case .standard: return s(.tableStyleStandard, lang)
        case .loose: return s(.tableStyleLoose, lang)
        case .friendly: return s(.tableStyleFriendly, lang)
        }
    }

    // MARK: - English

    private static func en(_ key: Key) -> String {
        switch key {
        case .tabHome: return "Home"
        case .tabLive: return "Live"
        case .tabStats: return "Stats"
        case .tabMe: return "Me"

        case .vpipTracker: return "VPIP TRACKER"
        case .lifetimeVPIP: return "LIFETIME VPIP"
        case .buildingProfile: return "BUILDING PROFILE"
        case .handsProgress: return "hands"
        case .hands: return "HANDS"
        case .sessions: return "SESSIONS"
        case .startSession: return "START SESSION"
        case .continueSession: return "CONTINUE"
        case .recent: return "RECENT"
        case .viewAll: return "ALL →"

        case .end: return "END"
        case .establishingBaseline: return "ESTABLISHING BASELINE"
        case .moreToUnlockVPIP: return "more to unlock VPIP"
        case .sessionVPIP: return "SESSION VPIP"
        case .thirtyMinVPIP: return "30MIN VPIP"
        case .lifetime: return "LIFETIME"
        case .entries: return "ENTRIES"
        case .fold: return "FOLD"
        case .vpip: return "VPIP"
        case .noActiveSession: return "No active session"
        case .startFromHome: return "Start from the home tab"

        case .statistics: return "STATISTICS"
        case .bbStats: return "BB STATS"
        case .totalBB: return "TOTAL BB"
        case .bb100: return "BB/100"
        case .position: return "POSITION"
        case .actionType: return "ACTION TYPE"
        case .gtoCompliance: return "GTO COMPLIANCE"
        case .inRange: return "IN RANGE"
        case .common_deviations: return "COMMON DEVIATIONS"
        case .tightenRange: return "Tighten preflop range"
        case .tiltAnalysis: return "TILT ANALYSIS"
        case .rate: return "RATE"
        case .avgDur: return "AVG DUR"
        case .highTiltFrequency: return "Elevated tilt frequency. Build in breaks post-loss."
        case .playerProfileUnlocks: return "Player profile unlocks at 100 hands"
        case .noDataYet: return "No data yet"

        case .account: return "ACCOUNT"
        case .settings: return "SETTINGS"
        case .about: return "ABOUT"
        case .appearance: return "Appearance"
        case .language: return "Language"
        case .notifications: return "Notifications"
        case .signInWithApple: return "SIGN IN WITH APPLE"
        case .guest: return "Guest"
        case .signInToSync: return "Sign in to sync your data"
        case .guestDataLocal: return "Guest data is stored locally only"
        case .connected: return "CONNECTED"
        case .signOut: return "SIGN OUT"
        case .signOutConfirm: return "Are you sure you want to sign out?"
        case .editProfile: return "Edit Profile"
        case .displayName: return "Display Name"
        case .chooseAvatar: return "Choose Avatar"
        case .uploadPhoto: return "Upload Photo"
        case .removePhoto: return "Remove Photo"
        case .cropPhotoTitle: return "Move and Scale"
        case .version: return "Version"
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfUse: return "Terms of Use"
        case .feedback: return "Feedback & Bug Report"
        case .feedbackSubject: return "[TiltGuard Feedback] v"
        case .feedbackBody: return """
        \n\n\n--- System Info (do not delete) ---
        Please describe your issue above:
        • Tilt not detected? Describe what happened.
        • False alert? What were you doing?
        • Feature request? Tell us your idea.
        """

        case .languageTitle: return "Language"
        case .languageDescription: return "Choose your preferred language"

        case .mode: return "MODE"
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"

        case .notificationTitle: return "Notifications"
        case .sessionReminder: return "Session Reminder"
        case .tiltAlert: return "Tilt Alert"
        case .sessionReminderDesc: return "Prompt to log hands during live sessions"
        case .tiltAlertDesc: return "Notify when behavioral drift is detected"
        case .gtoAdviceToggle: return "GTO Advice"
        case .gtoAdviceToggleDesc: return "Display preflop range guidance during hand entry"

        case .lossTiltToggle: return "Loss Tilt"
        case .lossTiltToggleDesc: return "Detect VPIP spike following losses"
        case .winTiltToggle: return "Win Tilt"
        case .winTiltToggleDesc: return "Detect range expansion after winning streaks"
        case .techTiltToggle: return "Technical Tilt"
        case .techTiltToggleDesc: return "Detect deviation from your baseline style"
        case .bigPotToggle: return "Big Pot"
        case .bigPotToggleDesc: return "Flag single hands exceeding 100BB"
        case .alertIntensity: return "ALERT INTENSITY"
        case .intensityLight: return "Light"
        case .intensityLightDesc: return "Only critical alerts"
        case .intensityStandard: return "Standard"
        case .intensityStandardDesc: return "Balanced alerts"
        case .intensityStrict: return "Strict"
        case .intensityStrictDesc: return "More sensitive detection"
        case .advanced: return "Advanced"
        case .advancedDesc: return "Fine-tune alert categories and sensitivity"
        case .advancedCustom: return "Custom Mode"
        case .advancedCustomDesc: return "Full control over detectors and priority"
        case .advancedCustomPro: return "PRO"
        case .detectorLossChase: return "Loss Chase"
        case .detectorLossChaseDesc: return "Detects VPIP spike after consecutive losses"
        case .detectorWinTilt: return "Win Tilt"
        case .detectorWinTiltDesc: return "Detects range expansion after winning streak"
        case .detectorStyleDrift: return "Style Drift"
        case .detectorStyleDriftDesc: return "Detects unusual hand type selections"
        case .detectorVpipDrift: return "VPIP Drift"
        case .detectorVpipDriftDesc: return "Detects 30-min VPIP deviation from baseline"
        case .detectorBigPot: return "Big Pot"
        case .detectorBigPotDesc: return "Alerts after a ≥100BB single hand"
        case .detectorPriority: return "DETECTION PRIORITY"
        case .alertCategories: return "ALERT CATEGORIES"

        // Onboarding
        case .welcomeTitle: return "Welcome to TiltGuard"
        case .welcomeSubtitle: return "Stay disciplined at the poker table.\nTrack your play and detect tilt before it costs you."
        case .welcomeFeature1: return "Live VPIP tracking"
        case .welcomeFeature2: return "Intelligent tilt detection"
        case .welcomeFeature3: return "Player profile & insights"
        case .continueAsGuest: return "Continue as Guest"
        case .onboardingSkip: return "Skip"
        case .onboardingContinue: return "Continue"
        case .onboardingDetectTitle: return "Real-time Tilt Detection"
        case .onboardingDetectBody: return "The app monitors your play and alerts you when your decisions start drifting from your normal strategy."
        case .onboardingDisciplineTitle: return "Protect Your Edge"
        case .onboardingDisciplineBody: return "Eliminate emotional leaks.\nStabilize your strategy.\nDefend your bankroll."
        case .onboardingProTitle: return "TiltGuard Pro"
        case .onboardingProBody: return "Advanced behavioral analysis\nand deep session insights."
        case .onboardingProFeature1: return "5 detectors with custom priority"
        case .onboardingProFeature2: return "Adaptive cooldown system"
        case .onboardingProFeature3: return "Deep session analytics"
        case .onboardingProFeature4: return "Long-term behavioral trends"
        case .onboardingProMonthly: return "$2.99 / month"
        case .onboardingProYearly: return "$14.99 / year"
        case .onboardingProOr: return "or"
        case .onboardingProTrial: return "Start Free Trial"
        case .onboardingProFree: return "Continue with Free Version"
        case .onboardingProEarly: return "Early Supporter Price"
        case .onboardingSignInTitle: return "Get Started"
        case .onboardingSignInBody: return "Sign in to keep your stats across sessions.\nGuest mode stores data only on this device."

        case .guestSession: return "Guest Session"
        case .guestDataNotSaved: return "Data will not be saved"
        case .saveThisSession: return "Save your sessions and build your player profile."
        case .signInToKeepStats: return "Sign in to keep your stats"
        case .guestBannerTitle: return "Playing as Guest"
        case .guestBannerSubtitle: return "Sign in to save sessions and track your long-term VPIP"

        case .suited: return "SUITED"
        case .offsuit: return "OFFSUIT"
        case .history: return "HISTORY"
        case .quickFold: return "QUICK FOLD"
        case .foldWithCards: return "FOLD"
        case .recordFold: return "RECORD FOLD"

        case .today: return "Today"
        case .yesterday: return "Yesterday"
        case .handsCount: return "hands"
        case .duration: return "Duration"
        case .hourShort: return "h"
        case .minuteShort: return "m"
        case .winRate: return "Win Rate"
        case .vpipHands: return "VPIP Hands"
        case .date: return "Date"

        case .std: return "std"
        case .dev: return "dev"
        case .todayPerformance: return "TODAY"
        case .playStyle: return "PLAY STYLE"
        case .disciplineScore: return "Discipline"
        case .netResult: return "Net Result"
        case .resultTrackingDisabled: return "Result tracking disabled"
        case .tiltWarnings: return "Warnings"
        case .tiltDangers: return "Dangers"
        case .cooldownCompleted: return "Cooldown completed"
        case .baselineVPIP: return "Baseline"
        case .deviationHands: return "Deviation hands"
        case .deviationHandsDesc: return "Played outside normal range"
        case .weakHandEntries: return "Weak entries"
        case .weakHandEntriesDesc: return "Weak hand VPIP"

        case .vsSession: return "vs session"
        case .vsLifetime: return "vs lifetime"
        case .eqLifetime: return "= lifetime"
        case .handNumber: return "Hand"
        case .handNumberSuffix: return ""
        case .adjust: return "ADJUST"
        case .watch: return "WATCH"

        case .premiumRate: return "PREMIUM RATE"
        case .luck: return "LUCK"
        case .bigSwings: return "BIG SWINGS"
        case .premiumHands: return "PREMIUM HANDS"
        case .goodLuck: return "Good luck"
        case .normalLuck: return "Normal"
        case .belowAvg: return "Below avg"
        case .unlucky: return "Unlucky"
        case .sessionOverview: return "SESSION OVERVIEW"
        case .vpipControl: return "VPIP CONTROL"
        case .tiltEvents: return "TILT EVENTS"
        case .sessionInsight: return "SESSION INSIGHT"
        case .handsPlayed: return "Hands Played"
        case .vpipDeviation: return "VPIP Deviation"
        case .controlRating: return "Control Rating"
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .loose: return "Loose"
        case .veryLoose: return "Very Loose"
        case .tiltAlertsTriggered: return "Tilt alerts triggered"
        case .cooldownActivated: return "Cooldown activated"
        case .recoveryTime: return "Recovery"
        case .recoveryHands: return "%d hands to recover"
        case .rangeDiscipline: return "RANGE DISCIPLINE"
        case .weakEntries: return "Weak range entries"
        case .weakEntriesCooling: return "Weak entries during cooldown"
        case .sessionRating: return "SESSION DISCIPLINE"
        case .insightNormal: return "VPIP within baseline. Discipline held."
        case .insightTilted: return "Range widened under pressure. Review tilt triggers."
        case .insightRecovered: return "Tilt detected mid-session. Stabilized after cooldown."
        case .comparedToAvg: return "vs average"

        case .allSessions: return "All Sessions"

        case .appName: return "RangeMind"
        case .appFullName: return "VPIP TRACKER"

        case .cancel: return "Cancel"
        case .done: return "Done"
        case .save: return "Save"
        case .delete: return "Delete"
        case .optional: return "optional"
        case .win: return "WIN"
        case .loss: return "LOSS"
        case .sessionComplete: return "SESSION COMPLETE"
        case .yourHand: return "YOUR HAND"
        case .positionLabel: return "POSITION"
        case .action: return "ACTION"
        case .bbAmount: return "BB AMOUNT"

        // Tilt Coach — 4 categories
        case .lossTiltH: return "Loss Tilt"
        case .lossTiltWarnD: return "VPIP elevated post-loss. Narrow your range."
        case .lossTiltDangerD: return "Significant tilt detected. Step away for 5 minutes."
        case .winTiltH: return "Win Tilt"
        case .winTiltD: return "Range widening after wins. Lock in your edge — don't give it back."
        case .techTiltH: return "Technical Tilt"
        case .techTiltWarnD: return "Range drifting from baseline. Re-check hand selection."
        case .techTiltDangerD: return "Major style deviation. Return to your core range."
        case .bigPotH: return "Big Pot"
        case .bigPotHugeH: return "Huge Pot"
        case .bigPotMassiveH: return "Massive Pot"
        case .bigPotWinStrongD: return "Big win secured. Stay sharp — momentum can loosen your range."
        case .bigPotWinStrongHugeD: return "Huge pot won. Stabilize your rhythm before continuing."
        case .bigPotWinStrongMassiveD: return "Massive pot won. Emotional spike likely — observe your next few hands."
        case .bigPotLossStrongD: return "Correct play, wrong result. That's variance — stay the course."
        case .bigPotLossStrongHugeD: return "Huge pot lost with a strong hand. Even correct plays this size affect decisions."
        case .bigPotLossStrongMassiveD: return "Massive pot lost. Emotional impact is real — tighten up or take a break."
        case .bigPotWinWeakD: return "Marginal hand, lucky outcome. Don't let it expand your range."
        case .bigPotWinWeakHugeD: return "Marginal hand won a huge pot. Easy to overestimate your reads."
        case .bigPotWinWeakMassiveD: return "Marginal hand won a massive pot. Highest risk of range inflation."
        case .bigPotLossWeakD: return "Weak hand in a big pot. Tighten up immediately."
        case .bigPotLossWeakHugeD: return "Weak hand lost a huge pot. Clear discipline breach — reset now."
        case .bigPotLossWeakMassiveD: return "Weak hand lost a massive pot. Strongly recommend pausing."
        case .sessionBB: return "Session %@BB"
        case .statsLocked: return "Sign in to view statistics"
        case .statsLockedDesc: return "Your playing data will be analyzed after signing in"
        case .playMoreHands: return "Play more hands to see statistics"

        // GTO Advice
        case .gtoAdvice: return "GTO PREFLOP"
        case .gtoOpenRaise: return "OPEN"
        case .gtoNotInRange: return "—"
        case .gtoAllPositions: return "Open any position — solid equity hand."
        case .gtoMidLate: return "Open MP+. Fold early position."
        case .gtoLateOnly: return "CO+ only. Fold EP/MP."
        case .gtoBtnOnly: return "BTN/SB only — marginal open."
        case .gtoPremium: return "Premium. Raise or 3-bet any seat."
        case .gtoFoldPre: return "Below range — fold pre."
        case .positionGuide: return "POSITION GUIDE"
        case .sixMax: return "6-MAX"
        case .nineMax: return "9-MAX"
        case .tapForGuide: return "Tap for position guide"
        case .gameModeCash: return "Cash"
        case .gameModeTournament: return "Tournament"
        case .gameModeLabel: return "GAME MODE"
        case .tableSizeLabel: return "TABLE SIZE"
        case .tableStyleLabel: return "TABLE STYLE"
        case .tableSizeHU: return "Heads-Up"
        case .tableSizeSixMax: return "6-MAX"
        case .tableSizeNineMax: return "9-MAX"
        case .tableSizeFullRing: return "Full Ring"
        case .tableStyleStandard: return "Standard"
        case .tableStyleLoose: return "Loose"
        case .tableStyleFriendly: return "Friendly"
        case .sessionTitleLabel: return "LOCATION"
        case .sessionTitlePlaceholder: return "Bellagio, Home Game..."
        case .vpipOptionalHint: return "Optional — improves tilt detection accuracy"
        case .emotionSignalLabel: return "FEELING (OPTIONAL)"
        case .emotionBadBeat: return "Bad Beat"
        case .emotionCooler: return "Cooler"
        case .emotionTilt: return "Tilt"
        case .posUtgDesc: return "Under the Gun — first to act, tightest range"
        case .posMpDesc: return "Middle Position — slightly wider than UTG"
        case .posCoDesc: return "Cutoff — second-to-last, wide range"
        case .posBtnDesc: return "Button — last to act, widest range"
        case .posSbDesc: return "Small Blind — forced bet, act first postflop"
        case .posBbDesc: return "Big Blind — defend wide, close the action"
        case .posUtg1Desc: return "UTG+1 — second earliest, still tight"
        case .posUtg2Desc: return "UTG+2 — early-mid position"
        case .posLjDesc: return "Lojack — early-mid, similar to MP"
        case .posHjDesc: return "Hijack — one before CO, moderately wide"

        // Strategy
        case .strategyTight: return "Tight"
        case .strategyBalanced: return "Balanced"
        case .strategyLoose: return "Loose"
        case .strategyInsightTitle: return "Strategy Insight"
        case .strategyInsight: return ""
        case .targetVPIP: return "TARGET VPIP"
        case .currentVPIP: return "CURRENT VPIP"
        case .strategyTightDesc: return "Premium-only. Ideal for tough lineups."
        case .strategyBalancedDesc: return "Balanced 6-max range. Standard GTO approach."
        case .strategyLooseDesc: return "Wide range for passive tables. High aggression."

        // Cooldown
        case .cooldownMode: return "COOLDOWN MODE"
        case .cooldownSuggestion: return "Tighten range for the next %d hands"
        case .cooldownRemaining: return "%d hands remaining"
        case .cooldownExtended: return "Extended — deviation continues"
        case .cooldownObserving: return "OBSERVING"
        case .cooldownObservingDesc: return "Checking behavior over next %d hands"
        case .cooldownModeDesc: return "Suggest tightening range after repeated deviation"
        case .tightenRange2: return "TIGHTEN RANGE"
        }
    }

    // MARK: - Chinese

    private static func zh(_ key: Key) -> String {
        switch key {
        case .tabHome: return "首页"
        case .tabLive: return "牌局"
        case .tabStats: return "统计"
        case .tabMe: return "我的"

        case .vpipTracker: return "VPIP 追踪器"
        case .lifetimeVPIP: return "生涯 VPIP"
        case .buildingProfile: return "建立档案中"
        case .handsProgress: return "手"
        case .hands: return "手牌"
        case .sessions: return "场次"
        case .startSession: return "开始牌局"
        case .continueSession: return "继续"
        case .recent: return "最近"
        case .viewAll: return "全部 →"

        case .end: return "结束"
        case .establishingBaseline: return "建立基准中"
        case .moreToUnlockVPIP: return "手后解锁 VPIP"
        case .sessionVPIP: return "本场 VPIP"
        case .thirtyMinVPIP: return "30分钟 VPIP"
        case .lifetime: return "生涯"
        case .entries: return "记录"
        case .fold: return "弃牌"
        case .vpip: return "入池"
        case .noActiveSession: return "暂无进行中的牌局"
        case .startFromHome: return "从首页开始新牌局"

        case .statistics: return "数据统计"
        case .bbStats: return "BB 数据"
        case .totalBB: return "总 BB"
        case .bb100: return "BB/100"
        case .position: return "位置"
        case .actionType: return "行动类型"
        case .gtoCompliance: return "GTO 合规"
        case .inRange: return "范围内"
        case .common_deviations: return "常见偏差"
        case .tightenRange: return "收紧翻前范围"
        case .tiltAnalysis: return "上头分析"
        case .rate: return "概率"
        case .avgDur: return "平均时长"
        case .highTiltFrequency: return "上头频率偏高，建议连输后安排休息。"
        case .playerProfileUnlocks: return "100 手后解锁玩家画像"
        case .noDataYet: return "暂无数据"

        case .account: return "账户"
        case .settings: return "设置"
        case .about: return "关于"
        case .appearance: return "外观"
        case .language: return "语言"
        case .notifications: return "通知"
        case .signInWithApple: return "使用 APPLE 登录"
        case .guest: return "游客"
        case .signInToSync: return "登录以同步数据"
        case .guestDataLocal: return "游客数据仅存储在本地"
        case .connected: return "已连接"
        case .signOut: return "退出登录"
        case .signOutConfirm: return "确定要退出登录吗？"
        case .editProfile: return "编辑资料"
        case .displayName: return "显示名称"
        case .chooseAvatar: return "选择头像"
        case .uploadPhoto: return "上传照片"
        case .removePhoto: return "移除照片"
        case .cropPhotoTitle: return "移动和缩放"
        case .version: return "版本"
        case .privacyPolicy: return "隐私政策"
        case .termsOfUse: return "使用条款"
        case .feedback: return "反馈与问题报告"
        case .feedbackSubject: return "[TiltGuard 反馈] v"
        case .feedbackBody: return """
        \n\n\n--- 系统信息（请勿删除）---
        请在上方描述你的问题：
        • 上头了但系统没检测到？描述当时的情况。
        • 没上头却收到警报？你当时在做什么？
        • 功能建议？告诉我们你的想法。
        """

        case .languageTitle: return "语言"
        case .languageDescription: return "选择你偏好的语言"

        case .mode: return "模式"
        case .system: return "跟随系统"
        case .light: return "浅色"
        case .dark: return "深色"

        case .notificationTitle: return "通知"
        case .sessionReminder: return "牌局提醒"
        case .tiltAlert: return "上头警报"
        case .sessionReminderDesc: return "牌局进行中提示记录手牌"
        case .tiltAlertDesc: return "检测到行为偏移时通知"
        case .gtoAdviceToggle: return "GTO 建议"
        case .gtoAdviceToggleDesc: return "录入手牌时显示翻前范围指引"

        case .lossTiltToggle: return "输后上头"
        case .lossTiltToggleDesc: return "检测连输后入池率飙升"
        case .winTiltToggle: return "赢后膨胀"
        case .winTiltToggleDesc: return "检测连赢后范围扩大"
        case .techTiltToggle: return "技术上头"
        case .techTiltToggleDesc: return "检测偏离基线打法"
        case .bigPotToggle: return "大底池"
        case .bigPotToggleDesc: return "标记超过 100BB 的单手"
        case .alertIntensity: return "提醒强度"
        case .intensityLight: return "轻度"
        case .intensityLightDesc: return "仅关键提醒"
        case .intensityStandard: return "标准"
        case .intensityStandardDesc: return "均衡提醒"
        case .intensityStrict: return "严格"
        case .intensityStrictDesc: return "更敏感的检测"
        case .advanced: return "高级"
        case .advancedDesc: return "微调提醒类型和灵敏度"
        case .advancedCustom: return "自定义模式"
        case .advancedCustomDesc: return "完全控制检测器和优先级"
        case .advancedCustomPro: return "PRO"
        case .detectorLossChase: return "逆风追损"
        case .detectorLossChaseDesc: return "检测连输后入池率飙升"
        case .detectorWinTilt: return "顺风膨胀"
        case .detectorWinTiltDesc: return "检测连赢后范围扩大"
        case .detectorStyleDrift: return "风格失真"
        case .detectorStyleDriftDesc: return "检测异常牌型选择"
        case .detectorVpipDrift: return "入池漂移"
        case .detectorVpipDriftDesc: return "检测 30 分钟 VPIP 偏离基线"
        case .detectorBigPot: return "大底池"
        case .detectorBigPotDesc: return "单手 ≥100BB 事件提醒"
        case .detectorPriority: return "检测优先级"
        case .alertCategories: return "提醒类型"

        // Welcome
        case .welcomeTitle: return "欢迎使用 TiltGuard"
        case .welcomeSubtitle: return "在牌桌上保持纪律。\n追踪你的打法，在上头前及时发现。"
        case .welcomeFeature1: return "实时 VPIP 追踪"
        case .welcomeFeature2: return "智能上头检测"
        case .welcomeFeature3: return "玩家画像与洞察"
        case .continueAsGuest: return "以游客身份继续"
        case .onboardingSkip: return "跳过"
        case .onboardingContinue: return "继续"
        case .onboardingDetectTitle: return "实时上头检测"
        case .onboardingDetectBody: return "实时监控你的打法，当你的决策开始偏离正常策略时发出警报。"
        case .onboardingDisciplineTitle: return "守住你的优势"
        case .onboardingDisciplineBody: return "消除情绪漏洞。\n稳定你的策略。\n保护你的资金。"
        case .onboardingProTitle: return "TiltGuard Pro"
        case .onboardingProBody: return "高级行为分析\n与深度牌局洞察。"
        case .onboardingProFeature1: return "5 大检测器 + 自定义优先级"
        case .onboardingProFeature2: return "自适应冷静期系统"
        case .onboardingProFeature3: return "深度牌局分析"
        case .onboardingProFeature4: return "长期行为趋势"
        case .onboardingProMonthly: return "¥18 / 月"
        case .onboardingProYearly: return "¥98 / 年"
        case .onboardingProOr: return "或"
        case .onboardingProTrial: return "开始免费试用"
        case .onboardingProFree: return "继续使用免费版"
        case .onboardingProEarly: return "早期支持者价格"
        case .onboardingSignInTitle: return "开始使用"
        case .onboardingSignInBody: return "登录以保留你的统计数据。\n游客模式仅在本设备存储数据。"

        case .guestSession: return "游客牌局"
        case .guestDataNotSaved: return "数据不会被保存"
        case .saveThisSession: return "登录以保存牌局并建立你的玩家档案"
        case .signInToKeepStats: return "登录以保存你的数据"
        case .guestBannerTitle: return "游客模式"
        case .guestBannerSubtitle: return "登录以保存牌局和追踪长期 VPIP"

        case .suited: return "同花"
        case .offsuit: return "非同花"
        case .history: return "历史"
        case .quickFold: return "快速弃牌"
        case .foldWithCards: return "弃牌"
        case .recordFold: return "记录弃牌"

        case .today: return "今天"
        case .yesterday: return "昨天"
        case .handsCount: return "手"
        case .duration: return "时长"
        case .hourShort: return "时"
        case .minuteShort: return "分"
        case .winRate: return "胜率"
        case .vpipHands: return "入池手牌"
        case .date: return "日期"

        case .std: return "标准"
        case .dev: return "偏差"
        case .todayPerformance: return "今日表现"
        case .playStyle: return "打法分析"
        case .disciplineScore: return "纪律评分"
        case .netResult: return "净盈亏"
        case .resultTrackingDisabled: return "未记录盈亏"
        case .tiltWarnings: return "警告"
        case .tiltDangers: return "危险"
        case .cooldownCompleted: return "冷静期完成"
        case .baselineVPIP: return "基准"
        case .deviationHands: return "偏离手牌"
        case .deviationHandsDesc: return "超出正常范围入池"
        case .weakHandEntries: return "弱牌入池"
        case .weakHandEntriesDesc: return "弱牌主动入池"

        case .vsSession: return "vs 本场"
        case .vsLifetime: return "vs 生涯"
        case .eqLifetime: return "= 生涯"
        case .handNumber: return "第"
        case .handNumberSuffix: return "手"
        case .adjust: return "调整"
        case .watch: return "注意"

        case .premiumRate: return "优质率"
        case .luck: return "运气"
        case .bigSwings: return "大波动"
        case .premiumHands: return "优质手牌"
        case .goodLuck: return "好运"
        case .normalLuck: return "正常"
        case .belowAvg: return "低于均值"
        case .unlucky: return "不走运"
        case .sessionOverview: return "本场概览"
        case .vpipControl: return "VPIP 控制"
        case .tiltEvents: return "上头事件"
        case .sessionInsight: return "本场总结"
        case .handsPlayed: return "手牌数"
        case .vpipDeviation: return "VPIP 偏差"
        case .controlRating: return "控制评分"
        case .excellent: return "优秀"
        case .good: return "良好"
        case .loose: return "偏松"
        case .veryLoose: return "非常松"
        case .tiltAlertsTriggered: return "触发上头警报"
        case .cooldownActivated: return "启动冷静期"
        case .recoveryTime: return "恢复"
        case .recoveryHands: return "%d 手后恢复"
        case .rangeDiscipline: return "范围纪律"
        case .weakEntries: return "弱牌入池"
        case .weakEntriesCooling: return "冷静期内弱牌入池"
        case .sessionRating: return "本场纪律"
        case .insightNormal: return "VPIP 在基线范围内，纪律稳定。"
        case .insightTilted: return "逆风下范围扩大，复盘上头触发点。"
        case .insightRecovered: return "中段检测到上头，冷静期后趋于稳定。"
        case .comparedToAvg: return "vs 平均"

        case .allSessions: return "所有牌局"

        case .appName: return "RangeMind"
        case .appFullName: return "VPIP TRACKER"

        case .cancel: return "取消"
        case .done: return "完成"
        case .save: return "保存"
        case .delete: return "删除"
        case .optional: return "选填"
        case .win: return "赢"
        case .loss: return "输"
        case .sessionComplete: return "牌局结束"
        case .yourHand: return "你的手牌"
        case .positionLabel: return "位置"
        case .action: return "行动"
        case .bbAmount: return "BB 数额"

        // Tilt Coach — 4 categories
        case .lossTiltH: return "输后上头"
        case .lossTiltWarnD: return "连输后入池率上升，收紧范围。"
        case .lossTiltDangerD: return "检测到明显上头，建议离桌 5 分钟。"
        case .winTiltH: return "赢后膨胀"
        case .winTiltD: return "连赢后范围扩大，锁住优势，别还回去。"
        case .techTiltH: return "技术上头"
        case .techTiltWarnD: return "范围偏离基线，重新审视选牌。"
        case .techTiltDangerD: return "打法严重偏移，回归核心范围。"
        case .bigPotH: return "大底池"
        case .bigPotHugeH: return "超大底池"
        case .bigPotMassiveH: return "极端大底池"
        case .bigPotWinStrongD: return "大锅拿下。保持冷静，别让势头松了范围。"
        case .bigPotWinStrongHugeD: return "超大底池拿下，先稳住节奏再继续。"
        case .bigPotWinStrongMassiveD: return "极端大底池拿下，情绪波动可能很强，先观察几手。"
        case .bigPotLossStrongD: return "打法正确，结果是波动。保持节奏。"
        case .bigPotLossStrongHugeD: return "超大底池输了强牌，即使打法正确也会影响后续决策。"
        case .bigPotLossStrongMassiveD: return "极端大底池输了，情绪冲击很强，收紧范围或暂停。"
        case .bigPotWinWeakD: return "边缘牌侥幸获利，别让运气扩大你的范围。"
        case .bigPotWinWeakHugeD: return "边缘牌赢了超大底池，容易误判自己的读牌。"
        case .bigPotWinWeakMassiveD: return "边缘牌赢了极端大底池，最容易引发范围失控。"
        case .bigPotLossWeakD: return "弱牌进大底池，立刻收紧范围。"
        case .bigPotLossWeakHugeD: return "弱牌输了超大底池，明显偏离纪律，立刻重置。"
        case .bigPotLossWeakMassiveD: return "弱牌输掉极端大底池，强烈建议暂停几手。"
        case .sessionBB: return "本场 %@BB"
        case .statsLocked: return "登录后查看统计数据"
        case .statsLockedDesc: return "登录后你的牌局数据将被分析"
        case .playMoreHands: return "多打几手查看统计"

        // GTO Advice
        case .gtoAdvice: return "GTO 翻前建议"
        case .gtoOpenRaise: return "开池"
        case .gtoNotInRange: return "—"
        case .gtoAllPositions: return "全位置可开池，权益手牌。"
        case .gtoMidLate: return "中位+可开。前位弃牌。"
        case .gtoLateOnly: return "CO+ 可开。前中位弃牌。"
        case .gtoBtnOnly: return "BTN/SB 可开 — 边缘牌。"
        case .gtoPremium: return "顶级牌。任意位置加注或 3-bet。"
        case .gtoFoldPre: return "范围外 — 翻前弃牌。"
        case .positionGuide: return "位置指南"
        case .sixMax: return "6人桌"
        case .nineMax: return "9人桌"
        case .tapForGuide: return "点击查看位置指南"
        case .gameModeCash: return "现金桌"
        case .gameModeTournament: return "锦标赛"
        case .gameModeLabel: return "游戏模式"
        case .tableSizeLabel: return "桌型"
        case .tableStyleLabel: return "牌桌风格"
        case .tableSizeHU: return "单挑"
        case .tableSizeSixMax: return "6人桌"
        case .tableSizeNineMax: return "9人桌"
        case .tableSizeFullRing: return "满桌"
        case .tableStyleStandard: return "标准"
        case .tableStyleLoose: return "松桌"
        case .tableStyleFriendly: return "朋友局"
        case .sessionTitleLabel: return "地点"
        case .sessionTitlePlaceholder: return "百乐宫、朋友家..."
        case .vpipOptionalHint: return "选填 — 提升上头检测准确性"
        case .emotionSignalLabel: return "感觉（可选）"
        case .emotionBadBeat: return "Bad Beat"
        case .emotionCooler: return "Cooler"
        case .emotionTilt: return "Tilt"
        case .posUtgDesc: return "枪口位 — 最先行动，范围最紧"
        case .posMpDesc: return "中间位 — 比 UTG 略宽"
        case .posCoDesc: return "关煞位 — 倒数第二，范围较宽"
        case .posBtnDesc: return "庄位 — 最后行动，范围最宽"
        case .posSbDesc: return "小盲位 — 强制下注，翻后最先行动"
        case .posBbDesc: return "大盲位 — 宽防守，最后一个行动"
        case .posUtg1Desc: return "枪口+1 — 第二早行动，仍需紧范围"
        case .posUtg2Desc: return "枪口+2 — 前中位"
        case .posLjDesc: return "低位 — 前中位，类似 MP"
        case .posHjDesc: return "劫持位 — CO 前一位，范围适中"

        // Strategy
        case .strategyTight: return "紧凑"
        case .strategyBalanced: return "均衡"
        case .strategyLoose: return "激进"
        case .strategyInsightTitle: return "策略建议"
        case .strategyInsight: return ""
        case .targetVPIP: return "目标 VPIP"
        case .currentVPIP: return "当前 VPIP"
        case .strategyTightDesc: return "仅打优质牌，适合强阵容。"
        case .strategyBalancedDesc: return "标准 6-max 均衡范围。"
        case .strategyLooseDesc: return "宽范围高侵略性，适合被动桌。"

        // Cooldown
        case .cooldownMode: return "冷静模式"
        case .cooldownSuggestion: return "接下来 %d 手收紧范围"
        case .cooldownRemaining: return "剩余 %d 手"
        case .cooldownExtended: return "延长 — 偏移仍在继续"
        case .cooldownObserving: return "观察中"
        case .cooldownObservingDesc: return "观察接下来 %d 手的行为"
        case .cooldownModeDesc: return "反复偏离后建议收紧范围"
        case .tightenRange2: return "收紧范围"
        }
    }
}
