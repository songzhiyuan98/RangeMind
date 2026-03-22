# TiltGuard Design System v1.3

> Professional Analytics Tool with Premium Apple-Style Design
> 中文优先 · 跟随系统深浅色 · 视觉张力升级

---

## 设计理念

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃                                                             ┃
┃   "Poker behavior analytics designed like Apple Health"    ┃
┃                                                             ┃
┃   内核：专业工具                                             ┃
┃   外壳：惊艳 UI                                              ┃
┃                                                             ┃
┃   视觉记忆点：Edge Glow 状态系统                             ┃
┃                                                             ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

---

## v1.3 升级内容

| 项目 | v1.2 | v1.3 | 原因 |
|------|------|------|------|
| Hero 数字 | 80pt | **96pt** | 像 Apple Fitness，越大越好 |
| Edge Glow | 基础呼吸 | **强化动画** | 品牌记忆点 |
| Hero 背景 | 无 | **径向光晕** | HUD 感 |
| 玩家类型 | 文字 | **视觉徽章** | 更突出 |
| 牌组合 | 手动 | **自动识别** | 符合扑克心智 |

---

## 语言与本地化

### 界面文案对照表

| 英文 | 中文 | 场景 |
|------|------|------|
| Session VPIP | 本场入池率 | 主数据标签 |
| Lifetime VPIP | 终身入池率 | Home 页面 |
| 30min VPIP | 30分钟 | 副统计 |
| Hands | 手数 | 统计 |
| Start Session | 开始牌局 | 主按钮 |
| End | 结束 | 导航 |
| FOLD | 弃牌 | 主按钮 |
| VPIP | 入池 | 主按钮 |
| WIN | 赢 | 结果按钮 |
| NOT WIN | 未赢 | 结果按钮 |
| Suited | 同花 | 花色选择 |
| Offsuit | 杂色 | 花色选择 |
| Your Hand | 你的手牌 | 输入页标题 |
| Recent | 最近 | 列表标题 |
| Standard Player | 标准玩家 | 玩家类型 |

---

## 深浅色模式

### 色彩系统

```swift
extension Color {
    // 背景
    static let bgPrimary = Color("BgPrimary")
    // Dark: #0A0A0A  |  Light: #FFFFFF

    static let bgSecondary = Color("BgSecondary")
    // Dark: #1C1C1E  |  Light: #F2F2F7

    // 主色 (不变)
    static let pokerGreen = Color(hex: "#00C853")
    static let pokerGreenLight = Color(hex: "#00E676")

    // 语义色 (不变)
    static let warning = Color(hex: "#FF9100")
    static let danger = Color(hex: "#FF1744")

    // 文字
    static let textPrimary = Color("TextPrimary")
    // Dark: #FFFFFF  |  Light: #000000

    static let textSecondary = Color("TextSecondary")
    // Dark: 60% 白  |  Light: 60% 黑

    static let textTertiary = Color("TextTertiary")
    // Dark: 40% 白  |  Light: 40% 黑
}
```

---

## 核心视觉系统

### 1. Hero Data（核心数据巨显）⭐ 升级

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                     ░░░░░░░░░░░░░                           │
│                  ░░░░           ░░░░                        │
│                ░░░      23%       ░░░    ← 径向光晕         │
│                  ░░░░           ░░░░                        │
│                     ░░░░░░░░░░░░░                           │
│                                                             │
│                       本场入池率                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘

规格：
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
字号      96pt (从 80pt 升级) ⭐
字体      SF Pro Rounded Bold
颜色      .textPrimary
特性      Monospaced Digit

背景光晕 (新增)：
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
类型      RadialGradient
颜色      当前状态色 (绿/橙/红)
透明度    0.15 (深色) / 0.10 (浅色)
半径      180pt
效果      HUD 战术感
```

```swift
// Hero Data 组件 (带光晕)
struct HeroVPIP: View {
    let value: Int
    let status: GlowStatus

    @Environment(\.colorScheme) var colorScheme

    var glowOpacity: Double {
        colorScheme == .dark ? 0.15 : 0.10
    }

    var body: some View {
        ZStack {
            // 背景光晕
            RadialGradient(
                colors: [
                    status.color.opacity(glowOpacity),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 180
            )

            // 主数字
            VStack(spacing: 8) {
                Text("\(value)%")
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.textPrimary)
                    .contentTransition(.numericText())

                Text("本场入池率")
                    .font(.system(size: 13, weight: .semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.textTertiary)
            }
        }
    }
}
```

### 2. Edge Glow（状态氛围光）⭐ 强化

**品牌视觉记忆点 - 像战术 HUD**

```
状态           动画参数                    视觉效果
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

正常状态       opacity: 0.2 → 0.4          轻柔绿色呼吸
(Normal)       duration: 3s                沉稳、专业
               easeInOut


警告状态       opacity: 0.3 → 0.6          橙色脉冲
(Warning)      duration: 1.5s              引起注意
               easeInOut                   不打断操作


危险状态       opacity: 0.4 → 0.7          红色快速闪烁
(Danger)       duration: 0.5s              + 屏幕轻微震动
               + screen shake              强制关注
```

```swift
enum GlowStatus {
    case normal, warning, danger

    var color: Color {
        switch self {
        case .normal: return .pokerGreen
        case .warning: return .warning
        case .danger: return .danger
        }
    }

    var animationDuration: Double {
        switch self {
        case .normal: return 3.0
        case .warning: return 1.5
        case .danger: return 0.5
        }
    }

    var opacityRange: (min: Double, max: Double) {
        switch self {
        case .normal: return (0.2, 0.4)
        case .warning: return (0.3, 0.6)
        case .danger: return (0.4, 0.7)
        }
    }
}

struct EdgeGlow: View {
    let status: GlowStatus
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(status.color, lineWidth: 2)
            .blur(radius: 10)
            .opacity(isAnimating ? status.opacityRange.max : status.opacityRange.min)
            .animation(
                .easeInOut(duration: status.animationDuration)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
    }
}

// 危险状态屏幕震动
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 3
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0)
        )
    }
}
```

### 3. 玩家类型徽章 ⭐ 新增

**从普通文字升级为视觉徽章**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                          21%                                │
│                       终身入池率                             │
│                                                             │
│                    ┌─────────────┐                          │
│                    │ ○ 标准玩家  │  ← 徽章样式              │
│                    └─────────────┘                          │
│                                                             │
│                    1,247 手已记录                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘

徽章规格：
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
背景      Glass 材质
边框      1pt 状态色 (20% 透明度)
圆角      12pt
内边距    水平 16pt, 垂直 8pt
图标      圆点, 状态色
文字      14pt Medium
```

```swift
struct PlayerTypeBadge: View {
    let type: PlayerType

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(type.color)
                .frame(width: 8, height: 8)

            Text(type.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .glassEffect()
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(type.color.opacity(0.2), lineWidth: 1)
        )
    }
}

enum PlayerType {
    case nit, tight, standard, loose, veryLoose

    var displayName: String {
        switch self {
        case .nit: return "极紧玩家"
        case .tight: return "紧凶玩家"
        case .standard: return "标准玩家"
        case .loose: return "松凶玩家"
        case .veryLoose: return "极松玩家"
        }
    }

    var color: Color {
        switch self {
        case .nit: return .blue
        case .tight: return .cyan
        case .standard: return .pokerGreen
        case .loose: return .orange
        case .veryLoose: return .red
        }
    }

    var vpipRange: ClosedRange<Int> {
        switch self {
        case .nit: return 0...14
        case .tight: return 15...19
        case .standard: return 20...24
        case .loose: return 25...29
        case .veryLoose: return 30...100
        }
    }
}
```

---

## Session 页面（核心）

### 完整布局

```
┌─────────────────────────────────────────────────────────────┐
│                         9:41                                │
│                                                 结束 ■      │
│                                                             │
│                                                             │
│                     ░░░░░░░░░░░░░                           │
│                  ░░░░           ░░░░    ← 状态光晕          │
│                ░░░                 ░░░                      │
│              ░░░       23%          ░░░                     │
│                ░░░                 ░░░                      │
│                  ░░░░           ░░░░                        │
│                     ░░░░░░░░░░░░░                           │
│                                                             │
│                       本场入池率                             │
│                                                             │
│                                                             │
│   ▓░━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━░▓    │
│   ┃                                                    ┃    │
│   ┃        34%            21%            45            ┃    │
│   ┃       30分钟           终身          手数           ┃    │
│   ┃                                                    ┃    │
│   ▓░━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━░▓    │
│         ↑                                                   │
│     Edge Glow 包裹                                          │
│                                                             │
│                                                             │
│                                                             │
│    ┏━━━━━━━━━━━━━━━━━━━┓    ┏━━━━━━━━━━━━━━━━━━━┓          │
│    ┃                   ┃    ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃          │
│    ┃                   ┃    ┃▓▓               ▓▓┃          │
│    ┃       弃牌        ┃    ┃▓▓     入池      ▓▓┃          │
│    ┃                   ┃    ┃▓▓               ▓▓┃          │
│    ┃                   ┃    ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃          │
│    ┗━━━━━━━━━━━━━━━━━━━┛    ┗━━━━━━━━━━━━━━━━━━━┛          │
│                                                             │
│                          ───                                │
└─────────────────────────────────────────────────────────────┘
```

### 布局规格

```
Hero 区域
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VPIP 数字:     96pt Bold Rounded
标签:          13pt Semibold Uppercase
光晕:          RadialGradient, 180pt 半径

副统计卡片
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
容器:          Glass Card + Edge Glow
数字:          28pt Semibold Rounded
标签:          10pt Semibold Uppercase
间距:          3 列均分

按钮区域
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
高度:          120pt
圆角:          28pt
间距:          16pt
```

```swift
struct SessionView: View {
    @StateObject var viewModel: SessionViewModel
    @State private var shakeAmount: CGFloat = 0

    var currentStatus: GlowStatus {
        // 根据 VPIP 偏差计算状态
        viewModel.calculateStatus()
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部导航
                HStack {
                    Spacer()
                    Button("结束") {
                        viewModel.endSession()
                    }
                    .foregroundStyle(.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()

                // Hero VPIP (带光晕)
                HeroVPIP(value: viewModel.sessionVPIP, status: currentStatus)

                Spacer().frame(height: 32)

                // 副统计卡片 (带 Edge Glow)
                StatsCard(
                    thirtyMinVPIP: viewModel.thirtyMinVPIP,
                    lifetimeVPIP: viewModel.lifetimeVPIP,
                    hands: viewModel.totalHands
                )
                .overlay(EdgeGlow(status: currentStatus))

                Spacer()

                // 主按钮
                HStack(spacing: 16) {
                    FoldButton { viewModel.recordFold() }
                    VPIPButton { viewModel.showHandInput = true }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .modifier(ShakeEffect(animatableData: shakeAmount))
        .onChange(of: currentStatus) { _, newStatus in
            if newStatus == .danger {
                withAnimation(.easeInOut(duration: 0.1).repeatCount(3)) {
                    shakeAmount = 1
                }
                shakeAmount = 0
            }
        }
    }
}
```

---

## VPIP 输入页面 ⭐ 交互升级

### 牌组合自动识别

**支持三种牌型：**
1. **口袋对 (Pocket Pairs)**: AA, KK, QQ... 22
2. **同花 (Suited)**: AKs, KQs, T9s...
3. **杂色 (Offsuit)**: AKo, KQo, T9o...

```
用户操作                    系统响应
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

【场景1: 非口袋对】

选择 K                →    预览: [K] [?]

选择 9                →    预览: [K] [9]
                           自动显示: K9o (默认杂色)
                           花色按钮: [同花] [杂色✓] 均可点击

点击 同花             →    预览更新: K9s
                           花色按钮: [同花✓] [杂色]

点击 赢               →    记录完成，返回


【场景2: 口袋对】

选择 K                →    预览: [K] [?]

选择 K (再次)         →    预览: [K] [K]
                           自动显示: KK (无后缀)
                           花色按钮: [同花] [杂色] 均禁用 ⚠️
                           (口袋对不可能同花)

点击 赢               →    记录完成，返回
```

**口袋对特殊处理：**
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                       你的手牌                               │
│                                                             │
│               ┌─────────┐  ┌─────────┐                     │
│               │         │  │         │                     │
│               │    K    │  │    K    │                     │
│               │         │  │         │                     │
│               └─────────┘  └─────────┘                     │
│                                                             │
│                         KK              ← 无 s/o 后缀       │
│                                                             │
│    ┌───────────────────┐    ┌───────────────────┐          │
│    │      同花         │    │       杂色        │          │
│    │     (禁用)        │    │      (禁用)       │  ← 灰色  │
│    └───────────────────┘    └───────────────────┘          │
│                                                             │
│    结果按钮直接可用，无需选择花色                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 完整布局

```
┌─────────────────────────────────────────────────────────────┐
│                         9:41                                │
│  ✕                                                          │
│                                                             │
│                                                             │
│                       你的手牌                               │
│                                                             │
│               ┌─────────┐  ┌─────────┐                     │
│               │         │  │         │                     │
│               │    K    │  │    9    │                     │
│               │         │  │         │                     │
│               └─────────┘  └─────────┘                     │
│                                                             │
│                        K9o              ← 自动生成          │
│                                                             │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                                                     │    │
│  │   A   K   Q   J   T   9   8   7   6   5   4   3   2 │    │
│  │   ○   ●   ○   ○   ○   ●   ○   ○   ○   ○   ○   ○   ○ │    │
│  │                                                     │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│    ┌───────────────────┐    ┏━━━━━━━━━━━━━━━━━━━┓          │
│    │       同花        │    ┃       杂色        ┃  ← 默认  │
│    └───────────────────┘    ┗━━━━━━━━━━━━━━━━━━━┛          │
│                                                             │
│    ┏━━━━━━━━━━━━━━━━━━━┓    ┌───────────────────┐          │
│    ┃                   ┃    │                   │          │
│    ┃        赢         ┃    │       未赢        │          │
│    ┃                   ┃    │                   │          │
│    ┗━━━━━━━━━━━━━━━━━━━┛    └───────────────────┘          │
│                                                             │
│                          ───                                │
└─────────────────────────────────────────────────────────────┘
```

### 牌组合显示

```swift
struct HandPreview: View {
    let card1: String?
    let card2: String?
    let isSuited: Bool

    // 是否是口袋对
    var isPocketPair: Bool {
        guard let c1 = card1, let c2 = card2 else { return false }
        return c1 == c2
    }

    var handNotation: String? {
        guard let c1 = card1, let c2 = card2 else { return nil }

        // 按牌力排序 (A > K > Q > ... > 2)
        let ranks = ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]
        let sorted = [c1, c2].sorted { ranks.firstIndex(of: $0)! < ranks.firstIndex(of: $1)! }

        // 口袋对 - 无后缀
        if isPocketPair {
            return "\(c1)\(c2)"  // AA, KK, QQ...
        }

        // 非口袋对 - 有后缀
        let suffix = isSuited ? "s" : "o"
        return "\(sorted[0])\(sorted[1])\(suffix)"  // AKs, AKo...
    }

    var body: some View {
        VStack(spacing: 16) {
            // 卡牌预览
            HStack(spacing: 16) {
                CardSlot(rank: card1)
                CardSlot(rank: card2)
            }

            // 组合标记
            if let notation = handNotation {
                Text(notation)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.textSecondary)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

// 花色选择器 - 口袋对时禁用
struct SuitSelector: View {
    @Binding var isSuited: Bool
    let isPocketPair: Bool  // 口袋对时禁用

    var body: some View {
        HStack(spacing: 12) {
            SuitButton(
                title: "同花",
                isSelected: isSuited && !isPocketPair,
                isDisabled: isPocketPair
            ) {
                isSuited = true
            }

            SuitButton(
                title: "杂色",
                isSelected: !isSuited && !isPocketPair,
                isDisabled: isPocketPair
            ) {
                isSuited = false
            }
        }
        .opacity(isPocketPair ? 0.4 : 1.0)  // 口袋对时整体变灰
        .allowsHitTesting(!isPocketPair)     // 口袋对时禁止点击
    }
}

struct CardSlot: View {
    let rank: String?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.bgSecondary)
                .frame(width: 64, height: 88)

            if let rank = rank {
                Text(rank)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.textPrimary)
            } else {
                Text("?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.textTertiary)
            }
        }
    }
}
```

### 牌选择器

**选择逻辑：**
- 可以选择同一张牌两次（口袋对，如 KK）
- 第一次点击：选中第一张牌
- 第二次点击同一张牌：选中为第二张牌（形成口袋对）
- 点击不同的牌：选中为第二张牌（形成非口袋对）
- 再次点击已选中的牌：取消选择

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  ← 可横向滚动                                      滚动 →   │
│                                                             │
│    ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐        │
│    │     │ │▓▓▓▓▓│ │     │ │     │ │     │ │▓▓▓▓▓│        │
│    │  A  │ │  K  │ │  Q  │ │  J  │ │  T  │ │  9  │  ...   │
│    │     │ │▓▓▓▓▓│ │     │ │     │ │     │ │▓▓▓▓▓│        │
│    └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘        │
│       ↑       ↑                               ↑            │
│      可选   选中×1                           选中×1         │
│             (如果再点一次K，变成 KK 口袋对)                   │
│                                                             │
│  未选中: bgSecondary, 文字 60%                              │
│  选中1次: 绿色渐变, 白色文字, scale 1.05                    │
│  选中2次 (口袋对): 绿色渐变 + 「×2」角标                    │
│                                                             │
│  卡片尺寸: 48 x 64 pt                                      │
│  圆角: 12pt                                                │
│  间距: 8pt                                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘

口袋对选中态示例:
┌─────┐
│▓▓▓▓▓│
│  K  │ ②  ← 右上角小角标表示选了2次
│▓▓▓▓▓│
└─────┘
```

```swift
struct RankSelector: View {
    @Binding var card1: String?
    @Binding var card2: String?

    let ranks = ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]

    func selectionCount(for rank: String) -> Int {
        var count = 0
        if card1 == rank { count += 1 }
        if card2 == rank { count += 1 }
        return count
    }

    func selectRank(_ rank: String) {
        let count = selectionCount(for: rank)

        if count == 0 {
            // 未选中 → 选为第一张或第二张
            if card1 == nil {
                card1 = rank
            } else if card2 == nil {
                card2 = rank
            }
        } else if count == 1 {
            // 已选中1次
            if card1 == rank && card2 == nil {
                // 第一张是这个牌，第二张未选 → 形成口袋对
                card2 = rank
            } else {
                // 取消选择
                if card1 == rank { card1 = nil }
                if card2 == rank { card2 = nil }
            }
        } else {
            // 已选中2次 (口袋对) → 取消一张
            card2 = nil
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ranks, id: \.self) { rank in
                    RankCard(
                        rank: rank,
                        selectionCount: selectionCount(for: rank),
                        action: { selectRank(rank) }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct RankCard: View {
    let rank: String
    let selectionCount: Int  // 0, 1, 或 2
    let action: () -> Void

    var isSelected: Bool { selectionCount > 0 }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Text(rank)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : .textSecondary)
                    .frame(width: 48, height: 64)
                    .background(
                        Group {
                            if isSelected {
                                LinearGradient(
                                    colors: [.pokerGreenLight, .pokerGreen],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            } else {
                                Color.bgSecondary
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .scaleEffect(isSelected ? 1.05 : 1.0)

                // 口袋对角标
                if selectionCount == 2 {
                    Text("2")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                        .background(Color.pokerGreen)
                        .clipShape(Circle())
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectionCount)
    }
}
```

---

## Home 首页

### 完整布局

```
┌─────────────────────────────────────────────────────────────┐
│                         9:41                                │
│                                                             │
│                                                             │
│                                                             │
│                      T I L T G U A R D                      │
│                                                             │
│                                                             │
│                     ░░░░░░░░░░░░░                           │
│                  ░░░░           ░░░░                        │
│                ░░░      21%       ░░░                       │
│                  ░░░░           ░░░░                        │
│                     ░░░░░░░░░░░░░                           │
│                                                             │
│                       终身入池率                             │
│                                                             │
│                    ┌─────────────┐                          │
│                    │ ● 标准玩家  │  ← 玩家类型徽章          │
│                    └─────────────┘                          │
│                                                             │
│                    1,247 手已记录                            │
│                                                             │
│                                                             │
│   最近                                                       │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  今天                                        24% → │   │
│   │  45 手  ·  1小时20分                               │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  昨天                                        19% → │   │
│   │  78 手  ·  2小时15分                               │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│                                                             │
│            ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓               │
│            ┃        开始牌局    ▶          ┃               │
│            ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛               │
│                                                             │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│       ●           ○           ○           ○                 │
│      首页        历史         分析         我的              │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

```swift
struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Logo
                Text("T I L T G U A R D")
                    .font(.system(size: 16, weight: .semibold))
                    .tracking(6)
                    .foregroundStyle(.textSecondary)
                    .padding(.top, 20)

                // Hero VPIP (带光晕, 稍小 56pt)
                ZStack {
                    RadialGradient(
                        colors: [Color.pokerGreen.opacity(0.12), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 140
                    )

                    VStack(spacing: 8) {
                        Text("\(viewModel.lifetimeVPIP)%")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.textPrimary)

                        Text("终身入池率")
                            .font(.system(size: 13, weight: .semibold))
                            .textCase(.uppercase)
                            .foregroundStyle(.textTertiary)
                    }
                }

                // 玩家类型徽章
                PlayerTypeBadge(type: viewModel.playerType)

                // 手数
                Text("\(viewModel.lifetimeHands) 手已记录")
                    .font(.system(size: 14))
                    .foregroundStyle(.textTertiary)

                // 最近
                VStack(alignment: .leading, spacing: 12) {
                    Text("最近")
                        .font(.system(size: 13, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(.textTertiary)

                    ForEach(viewModel.recentSessions) { session in
                        SessionRow(session: session)
                    }
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 80)
            }
        }

        // 底部按钮
        .safeAreaInset(edge: .bottom) {
            StartSessionButton {
                viewModel.startSession()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }
}
```

---

## Tilt 警告

### 警告触发 + 动画

```
触发序列：
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. 检测到 Tilt
   ↓
2. Edge Glow 变色 (0.3s)
   ↓
3. 屏幕震动 (危险状态)
   ↓
4. 警告卡片从底部滑入 (0.35s spring)
   ↓
5. 触感反馈 .notification(.warning)
```

### 警告卡片

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   │
│   ┃                                                     ┃   │
│   ┃                    ⚠️                               ┃   │
│   ┃                                                     ┃   │
│   ┃               入池率警告                             ┃   │
│   ┃                                                     ┃   │
│   ┃         你的入池比平时更松了                         ┃   │
│   ┃                                                     ┃   │
│   ┃          34%    →    21%                            ┃   │
│   ┃        30分钟        终身                            ┃   │
│   ┃                                                     ┃   │
│   ┃      ┌──────────────────────────────┐              ┃   │
│   ┃      │          我知道了            │              ┃   │
│   ┃      └──────────────────────────────┘              ┃   │
│   ┃                                                     ┃   │
│   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   │
│                                                             │
│   背景: Glass + 橙色/红色边框光晕                           │
│   图标: 40pt                                                │
│   标题: 22pt Bold                                          │
│   按钮: 语义色填充                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 动画规范

### 保留的动画（克制）

```
✅ 使用                          ❌ 不使用
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
数字变化动画                      页面翻转
按钮按压 (scale 0.95)             弹跳过度
Edge Glow 呼吸                    装饰性动画
警告震动 (仅危险状态)             卡片旋转
状态色渐变                        复杂粒子效果
```

```swift
extension Animation {
    // 数字变化
    static let numeric = Animation.spring(response: 0.4, dampingFraction: 0.9)

    // 按钮按压
    static let press = Animation.easeOut(duration: 0.1)

    // 弹窗
    static let sheet = Animation.spring(response: 0.35, dampingFraction: 0.85)

    // Edge Glow 呼吸 (根据状态不同)
    static func glow(_ status: GlowStatus) -> Animation {
        .easeInOut(duration: status.animationDuration).repeatForever(autoreverses: true)
    }

    // 震动
    static let shake = Animation.easeInOut(duration: 0.1).repeatCount(3)
}
```

---

## 组件规格总结

| 组件 | 高度 | 圆角 | 特殊效果 |
|------|------|------|----------|
| Hero VPIP | - | - | 背景光晕 |
| GlassCard | auto | 20pt | Edge Glow |
| 主按钮 | 120pt | 28pt | 入池按钮外发光 |
| 结果按钮 | 72pt | 18pt | - |
| 花色按钮 | 48pt | 14pt | - |
| 牌选择卡片 | 64pt | 12pt | 选中 scale 1.05 |
| 玩家类型徽章 | 36pt | 12pt | 状态色边框 |
| Session 列表项 | 72pt | 16pt | - |

---

## 设计检查清单

### 专业感
- [ ] 无游戏/娱乐元素
- [ ] 信息克制 (≤3 数据/页面)
- [ ] 中文文案自然
- [ ] 字体层级清晰

### 视觉惊艳
- [ ] Hero 数据 96pt
- [ ] Hero 背景光晕
- [ ] Edge Glow 状态系统
- [ ] 玩家类型徽章
- [ ] 深浅色都好看

### 交互体验
- [ ] 按钮 120pt (牌桌可用)
- [ ] VPIP 输入 ≤4 次点击
- [ ] 牌组合自动识别
- [ ] 每个操作有触感
- [ ] 动画克制精致

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v0.9 | 2026-03-06 | 初始设计 |
| v1.0 | 2026-03-06 | 单页输入 |
| v1.1 | 2026-03-06 | 专业分析工具风格 |
| v1.2 | 2026-03-06 | 中文优先 + 深浅色 |
| v1.3 | 2026-03-06 | **视觉张力升级**: Hero 96pt + 背景光晕, Edge Glow 强化, 玩家类型徽章, 牌组合自动识别 |

---

*TiltGuard Design System v1.3*
*专业分析 · Apple 级设计 · 视觉惊艳*
