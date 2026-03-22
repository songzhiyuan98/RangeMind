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
        case guestDataLocal, connected
        case version, privacyPolicy, termsOfUse

        // Language settings
        case languageTitle, languageDescription

        // Appearance settings
        case mode, system, light, dark

        // Notification settings
        case notificationTitle, sessionReminder, tiltAlert
        case sessionReminderDesc, tiltAlertDesc
        case gtoAdviceToggle, gtoAdviceToggleDesc

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
        case cancel, done, save, delete
        case win, loss
        case sessionComplete
        case yourHand, positionLabel, action, bbAmount

        // Tilt Coach
        case tiltVpipDriftDangerH, tiltVpipDriftDangerD
        case tiltVpipDriftWarnH, tiltVpipDriftWarnD
        case tiltWinStreakH, tiltWinStreakD
        case tiltWinMomentumH, tiltWinMomentumD
        case tiltLossChaseH, tiltLossChaseD
        case tiltLossRisingH, tiltLossRisingD
        case tiltStyleDepartH, tiltStyleDepartD
        case tiltStylePatternH, tiltStylePatternD
        case tiltStyleWidenedH, tiltStyleWidenedD
        case sessionBB
        case statsLocked, statsLockedDesc
        case playMoreHands

        // GTO Advice
        case gtoAdvice, gtoOpenRaise, gtoNotInRange
        case gtoAllPositions, gtoMidLate, gtoLateOnly, gtoBtnOnly
        case gtoPremium, gtoFoldPre
        case positionGuide, sixMax, nineMax, tapForGuide
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
        case .highTiltFrequency: return "High tilt frequency. Consider breaks after losses."
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
        case .version: return "Version"
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfUse: return "Terms of Use"

        case .languageTitle: return "Language"
        case .languageDescription: return "Choose your preferred language"

        case .mode: return "MODE"
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"

        case .notificationTitle: return "Notifications"
        case .sessionReminder: return "Session Reminder"
        case .tiltAlert: return "Tilt Alert"
        case .sessionReminderDesc: return "Remind to log hands during active session"
        case .tiltAlertDesc: return "Alert when tilt behavior is detected"
        case .gtoAdviceToggle: return "GTO Advice"
        case .gtoAdviceToggleDesc: return "Show preflop strategy tips when selecting hands"

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
        case .insightNormal: return "Your VPIP stayed close to your usual style. Good discipline this session."
        case .insightTilted: return "Your range widened after a rough stretch. Watch for tilt patterns in future sessions."
        case .insightRecovered: return "A tilt pattern was detected mid-session, but your play stabilized after the cooling phase."
        case .comparedToAvg: return "vs average"

        case .allSessions: return "All Sessions"

        case .appName: return "RangeMind"
        case .appFullName: return "VPIP TRACKER"

        case .cancel: return "Cancel"
        case .done: return "Done"
        case .save: return "Save"
        case .delete: return "Delete"
        case .win: return "WIN"
        case .loss: return "LOSS"
        case .sessionComplete: return "SESSION COMPLETE"
        case .yourHand: return "YOUR HAND"
        case .positionLabel: return "POSITION"
        case .action: return "ACTION"
        case .bbAmount: return "BB AMOUNT"

        // Tilt Coach
        case .tiltVpipDriftDangerH: return "Playing significantly wider than usual"
        case .tiltVpipDriftDangerD: return "Your recent VPIP is %d%% above your baseline. Check if each hand meets your standard."
        case .tiltVpipDriftWarnH: return "Range slightly wider than your norm"
        case .tiltVpipDriftWarnD: return "Recent VPIP trending above baseline. Stay aware of your hand selection."
        case .tiltWinStreakH: return "Hot streak expanding your range"
        case .tiltWinStreakD: return "You're running well and starting to play hands outside your usual style. Stay disciplined."
        case .tiltWinMomentumH: return "Momentum may be widening your range"
        case .tiltWinMomentumD: return "After recent wins your VPIP is %d%% above baseline. Lock in the gains."
        case .tiltLossChaseH: return "Chasing losses — VPIP spiking after big pot"
        case .tiltLossChaseD: return "Your entry rate jumped after a significant loss. Consider taking a 5-minute break."
        case .tiltLossRisingH: return "VPIP rising after recent losses"
        case .tiltLossRisingD: return "After a rough stretch your play is getting looser. Take a breath before the next hand."
        case .tiltStyleDepartH: return "Significant departure from your usual style"
        case .tiltStyleDepartD: return "Hands like %@ are outside your normal range. Pause and refocus."
        case .tiltStylePatternH: return "Some hands outside your usual pattern"
        case .tiltStylePatternD: return "Recent entries include hands you don't normally play. Check if deliberate."
        case .tiltStyleWidenedH: return "Your range has widened since session start"
        case .tiltStyleWidenedD: return "Second half VPIP is notably higher than the first half. Consider whether intentional."
        case .sessionBB: return "Session %@BB"
        case .statsLocked: return "Sign in to view statistics"
        case .statsLockedDesc: return "Your playing data will be analyzed after signing in"
        case .playMoreHands: return "Play more hands to see statistics"

        // GTO Advice
        case .gtoAdvice: return "GTO PREFLOP"
        case .gtoOpenRaise: return "OPEN"
        case .gtoNotInRange: return "—"
        case .gtoAllPositions: return "Open raise from any position. Strong hand."
        case .gtoMidLate: return "Open from MP+. Fold in early position."
        case .gtoLateOnly: return "Only open from CO or later. Fold EP/MP."
        case .gtoBtnOnly: return "Marginal — only open on BTN or SB."
        case .gtoPremium: return "Always raise or 3-bet. Top of range."
        case .gtoFoldPre: return "Weak hand — fold preflop."
        case .positionGuide: return "POSITION GUIDE"
        case .sixMax: return "6-MAX"
        case .nineMax: return "9-MAX"
        case .tapForGuide: return "Tap for position guide"
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
        case .strategyTightDesc: return "Conservative play for tough tables. Focus on premium hands only."
        case .strategyBalancedDesc: return "Optimal for 6-max balanced strategy range."
        case .strategyLooseDesc: return "Aggressive play for passive tables. Wider range selection."

        // Cooldown
        case .cooldownMode: return "COOLDOWN MODE"
        case .cooldownSuggestion: return "Tighten your range for the next %d hands"
        case .cooldownRemaining: return "%d hands remaining"
        case .cooldownExtended: return "Cooldown extended — still deviating"
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
        case .highTiltFrequency: return "上头频率偏高，建议输牌后休息"
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
        case .version: return "版本"
        case .privacyPolicy: return "隐私政策"
        case .termsOfUse: return "使用条款"

        case .languageTitle: return "语言"
        case .languageDescription: return "选择你偏好的语言"

        case .mode: return "模式"
        case .system: return "跟随系统"
        case .light: return "浅色"
        case .dark: return "深色"

        case .notificationTitle: return "通知"
        case .sessionReminder: return "牌局提醒"
        case .tiltAlert: return "上头警报"
        case .sessionReminderDesc: return "牌局进行中提醒记录手牌"
        case .tiltAlertDesc: return "检测到上头行为时发出警报"
        case .gtoAdviceToggle: return "GTO 建议"
        case .gtoAdviceToggleDesc: return "选牌时显示翻前策略建议"

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
        case .insightNormal: return "你的 VPIP 保持在常规范围内，本场纪律良好。"
        case .insightTilted: return "逆风后范围扩大，注意未来牌局的上头模式。"
        case .insightRecovered: return "本场中段检测到上头模式，但冷静期后打法趋于稳定。"
        case .comparedToAvg: return "vs 平均"

        case .allSessions: return "所有牌局"

        case .appName: return "RangeMind"
        case .appFullName: return "VPIP TRACKER"

        case .cancel: return "取消"
        case .done: return "完成"
        case .save: return "保存"
        case .delete: return "删除"
        case .win: return "赢"
        case .loss: return "输"
        case .sessionComplete: return "牌局结束"
        case .yourHand: return "你的手牌"
        case .positionLabel: return "位置"
        case .action: return "行动"
        case .bbAmount: return "BB 数额"

        // Tilt Coach
        case .tiltVpipDriftDangerH: return "入池范围明显偏宽"
        case .tiltVpipDriftDangerD: return "近期 VPIP 比基准高出 %d%%，检查每手牌是否符合你的标准。"
        case .tiltVpipDriftWarnH: return "范围略宽于你的常规"
        case .tiltVpipDriftWarnD: return "近期 VPIP 高于基准，注意你的手牌选择。"
        case .tiltWinStreakH: return "连赢后范围扩大"
        case .tiltWinStreakD: return "你打得顺风顺水，正开始玩常规范围外的牌。保持纪律。"
        case .tiltWinMomentumH: return "势头可能正在扩大你的范围"
        case .tiltWinMomentumD: return "近期连赢后 VPIP 比基准高 %d%%。锁住收益。"
        case .tiltLossChaseH: return "追损中 — 大底池后 VPIP 飙升"
        case .tiltLossChaseD: return "重大损失后入池率激增。建议休息 5 分钟。"
        case .tiltLossRisingH: return "连输后 VPIP 上升"
        case .tiltLossRisingD: return "逆风局后打法变松。下一手前先深呼吸。"
        case .tiltStyleDepartH: return "明显偏离你的常规风格"
        case .tiltStyleDepartD: return "%@ 等牌型不在你的常规范围内。暂停并重新集中注意力。"
        case .tiltStylePatternH: return "部分手牌超出常规模式"
        case .tiltStylePatternD: return "近期记录包含你通常不玩的牌型。确认是否有意为之。"
        case .tiltStyleWidenedH: return "你的范围从开局起一直在扩大"
        case .tiltStyleWidenedD: return "后半段 VPIP 明显高于前半段。考虑是否有意为之。"
        case .sessionBB: return "本场 %@BB"
        case .statsLocked: return "登录后查看统计数据"
        case .statsLockedDesc: return "登录后你的牌局数据将被分析"
        case .playMoreHands: return "多打几手查看统计"

        // GTO Advice
        case .gtoAdvice: return "GTO 翻前建议"
        case .gtoOpenRaise: return "开池"
        case .gtoNotInRange: return "—"
        case .gtoAllPositions: return "任何位置都可以开池加注，强牌。"
        case .gtoMidLate: return "中位以后可开池，前位弃牌。"
        case .gtoLateOnly: return "仅 CO 及以后位置开池，前中位弃牌。"
        case .gtoBtnOnly: return "边缘牌 — 仅 BTN 或 SB 可开池。"
        case .gtoPremium: return "顶级牌 — 任何位置加注或 3-bet。"
        case .gtoFoldPre: return "弱牌 — 翻前弃牌。"
        case .positionGuide: return "位置指南"
        case .sixMax: return "6人桌"
        case .nineMax: return "9人桌"
        case .tapForGuide: return "点击查看位置指南"
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
        case .strategyTightDesc: return "保守打法，专注于优质手牌。适合强对手牌桌。"
        case .strategyBalancedDesc: return "适用于 6-max 桌的平衡策略范围。"
        case .strategyLooseDesc: return "激进打法，范围更宽。适合被动型牌桌。"

        // Cooldown
        case .cooldownMode: return "冷静模式"
        case .cooldownSuggestion: return "接下来 %d 手建议收紧范围"
        case .cooldownRemaining: return "还剩 %d 手"
        case .cooldownExtended: return "冷静期延长 — 仍在偏离"
        case .cooldownObserving: return "观察中"
        case .cooldownObservingDesc: return "观察接下来 %d 手的行为"
        case .cooldownModeDesc: return "反复偏离后建议收紧范围"
        case .tightenRange2: return "收紧范围"
        }
    }
}
