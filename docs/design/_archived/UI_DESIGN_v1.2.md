# TiltGuard Design System v1.2

> Professional Analytics Tool with Premium Apple-Style Design
> 中文优先 · 跟随系统深浅色

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
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### 气质定位

```
✅ 参考                          ❌ 避免
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Apple Health                    扑克游戏 UI
Tesla Dashboard                 赌场/娱乐风格
Arc Browser                     花哨卡通
Linear                          密集数据 Excel 风格
Flighty                         旧扑克软件
```

### 四个关键词

```
DARK/LIGHT     GLASS        MINIMAL        PRECISION
系统适配        液态玻璃      信息克制        数据精准
```

---

## 语言与本地化

### MVP 阶段

```
默认语言: 简体中文
后续支持: 设置中切换 / 跟随系统
```

### 界面文案对照表

| 英文 | 中文 | 场景 |
|------|------|------|
| Session VPIP | 本场入池率 | 主数据标签 |
| Lifetime VPIP | 终身入池率 | Home 页面 |
| 30min VPIP | 30分钟入池率 | 副统计 |
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
| History | 历史 | Tab 标签 |
| Analysis | 分析 | Tab 标签 |
| Profile | 我的 | Tab 标签 |
| Home | 首页 | Tab 标签 |
| Standard Player | 标准玩家 | 玩家类型 |
| Tight | 紧凶 | 玩家类型 |
| Loose | 松凶 | 玩家类型 |
| Nit | 极紧 | 玩家类型 |
| Very Loose | 极松 | 玩家类型 |
| VPIP Alert | 入池率警告 | 警告标题 |
| hands tracked | 手已记录 | 统计描述 |

---

## 深浅色模式

### 系统适配

```swift
// 跟随系统颜色模式
@main
struct TiltGuardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            // 不设置 .preferredColorScheme，自动跟随系统
        }
    }
}
```

### 色彩系统

```swift
extension Color {
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 背景
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    static let bgPrimary = Color("BgPrimary")
    // Dark:  #0A0A0A
    // Light: #FFFFFF

    static let bgSecondary = Color("BgSecondary")
    // Dark:  #1C1C1E
    // Light: #F2F2F7

    static let bgTertiary = Color("BgTertiary")
    // Dark:  #2C2C2E
    // Light: #E5E5EA

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 主色 (不变)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    static let pokerGreen = Color(hex: "#00C853")
    static let pokerGreenLight = Color(hex: "#00E676")

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 语义色 (不变)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    static let warning = Color(hex: "#FF9100")
    static let danger = Color(hex: "#FF1744")

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 文字
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    static let textPrimary = Color("TextPrimary")
    // Dark:  #FFFFFF
    // Light: #000000

    static let textSecondary = Color("TextSecondary")
    // Dark:  rgba(255,255,255,0.6)
    // Light: rgba(0,0,0,0.6)

    static let textTertiary = Color("TextTertiary")
    // Dark:  rgba(255,255,255,0.4)
    // Light: rgba(0,0,0,0.4)
}
```

### Assets.xcassets 配置

```
Assets.xcassets/
├── Colors/
│   ├── BgPrimary.colorset/
│   │   └── Contents.json
│   │       ├── Any: #FFFFFF
│   │       └── Dark: #0A0A0A
│   ├── BgSecondary.colorset/
│   │   └── Contents.json
│   │       ├── Any: #F2F2F7
│   │       └── Dark: #1C1C1E
│   ├── TextPrimary.colorset/
│   │   └── Contents.json
│   │       ├── Any: #000000
│   │       └── Dark: #FFFFFF
│   └── ...
```

### 视觉对比

```
深色模式 (Dark)                      浅色模式 (Light)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌─────────────────────────┐          ┌─────────────────────────┐
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│          │░░░░░░░░░░░░░░░░░░░░░░░░░│
│▓▓                     ▓▓│          │░░                     ░░│
│▓▓        23%          ▓▓│          │░░        23%          ░░│
│▓▓      本场入池率      ▓▓│          │░░      本场入池率      ░░│
│▓▓                     ▓▓│          │░░                     ░░│
│▓▓  ┌───────────────┐  ▓▓│          │░░  ┌───────────────┐  ░░│
│▓▓  │ Glass Card    │  ▓▓│          │░░  │ Glass Card    │  ░░│
│▓▓  └───────────────┘  ▓▓│          │░░  └───────────────┘  ░░│
│▓▓                     ▓▓│          │░░                     ░░│
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│          │░░░░░░░░░░░░░░░░░░░░░░░░░│
└─────────────────────────┘          └─────────────────────────┘

背景: #0A0A0A                        背景: #FFFFFF
卡片: #1C1C1E + Glass                卡片: #F2F2F7 + Glass
文字: 白色                           文字: 黑色
```

### Glass 效果适配

```swift
// iOS 26 原生 Glass 自动适配深浅色
struct GlassCard<Content: View>: View {
    let content: Content

    var body: some View {
        content
            .padding(20)
            .background(.regularMaterial)  // 自动适配
            .glassEffect()
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
```

---

## 核心视觉系统

### 1. Hero Data（核心数据巨显）

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                                                             │
│                          23%                                │
│                                                             │
│                       本场入池率                             │
│                                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘

数字规格：
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
字体      SF Pro Rounded
字重      Bold
字号      80pt (Session 页面)
          56pt (Home 页面)
颜色      .textPrimary (自动适配)
特性      Monospaced Digit
动画      .contentTransition(.numericText())
```

### 2. Edge Glow（状态氛围光）

```
状态                 效果
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

正常状态             绿色微弱呼吸光
                    深色: opacity 0.3 → 0.5
                    浅色: opacity 0.2 → 0.4

警告状态             橙色光晕
                    opacity 0.5, 轻微脉冲

危险状态             红色闪烁
                    opacity 0.6, shake + pulse
```

```swift
struct EdgeGlow: View {
    enum Status { case normal, warning, danger }

    let status: Status
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating = false

    var glowColor: Color {
        switch status {
        case .normal: return .pokerGreen
        case .warning: return .warning
        case .danger: return .danger
        }
    }

    var maxOpacity: Double {
        colorScheme == .dark ? 0.5 : 0.4
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(glowColor, lineWidth: 2)
            .blur(radius: 8)
            .opacity(isAnimating ? maxOpacity : maxOpacity - 0.2)
            .animation(
                .easeInOut(duration: status == .danger ? 0.5 : 3)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
    }
}
```

---

## Session 页面设计（核心）

### 完整布局（中文）

```
┌─────────────────────────────────────────────────────────────┐
│                         9:41                                │
│                                                 结束 ■      │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                          23%                                │
│                                                             │
│                       本场入池率                             │
│                                                             │
│                                                             │
│          ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓           │
│          ┃                                      ┃           │
│          ┃      34%         21%          45     ┃           │
│          ┃    30分钟        终身         手数    ┃           │
│          ┃                                      ┃           │
│          ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛           │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│    ┏━━━━━━━━━━━━━━━━━━━┓    ┏━━━━━━━━━━━━━━━━━━━┓          │
│    ┃                   ┃    ┃                   ┃          │
│    ┃                   ┃    ┃                   ┃          │
│    ┃                   ┃    ┃                   ┃          │
│    ┃       弃牌        ┃    ┃       入池        ┃          │
│    ┃                   ┃    ┃                   ┃          │
│    ┃                   ┃    ┃                   ┃          │
│    ┃                   ┃    ┃                   ┃          │
│    ┗━━━━━━━━━━━━━━━━━━━┛    ┗━━━━━━━━━━━━━━━━━━━┛          │
│                                                             │
│                          ───                                │
└─────────────────────────────────────────────────────────────┘
```

### 按钮设计

```swift
// 弃牌按钮
struct FoldButton: View {
    @Environment(\.colorScheme) var colorScheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("弃牌")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color.bgSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// 入池按钮 (绿色，两种模式一样)
struct VPIPButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("入池")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)  // 绿色背景始终白字
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(
                    ZStack {
                        // 外发光
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.pokerGreen)
                            .blur(radius: 20)
                            .opacity(0.4)

                        // 主体渐变
                        LinearGradient(
                            colors: [.pokerGreenLight, .pokerGreen],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    }
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
```

---

## VPIP 输入页面（单页完成）

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
│                        同花                                 │
│                                                             │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                                                     │    │
│  │   A   K   Q   J   T   9   8   7   6   5   4   3   2 │    │
│  │   ○   ●   ○   ○   ○   ●   ○   ○   ○   ○   ○   ○   ○ │    │
│  │                                                     │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│    ┏━━━━━━━━━━━━━━━━━━━┓    ┏━━━━━━━━━━━━━━━━━━━┓          │
│    ┃       同花        ┃    ┃       杂色        ┃          │
│    ┗━━━━━━━━━━━━━━━━━━━┛    ┗━━━━━━━━━━━━━━━━━━━┛          │
│                                                             │
│    ┏━━━━━━━━━━━━━━━━━━━┓    ┏━━━━━━━━━━━━━━━━━━━┓          │
│    ┃                   ┃    ┃                   ┃          │
│    ┃        赢         ┃    ┃       未赢        ┃          │
│    ┃                   ┃    ┃                   ┃          │
│    ┗━━━━━━━━━━━━━━━━━━━┛    ┗━━━━━━━━━━━━━━━━━━━┛          │
│                                                             │
│                          ───                                │
└─────────────────────────────────────────────────────────────┘
```

### 交互流程

```
点击次数: 4 次 (最优路径)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. 点击第一张牌    →  选中高亮
2. 点击第二张牌    →  选中高亮, 默认杂色
3. (可选) 点击同花 →  切换花色
4. 点击 赢/未赢    →  记录完成, 自动返回
```

---

## Home 首页

```
┌─────────────────────────────────────────────────────────────┐
│                         9:41                                │
│                                                             │
│                                                             │
│                                                             │
│                      T I L T G U A R D                      │
│                                                             │
│                                                             │
│                                                             │
│                          21%                                │
│                                                             │
│                       终身入池率                             │
│                                                             │
│                      标准玩家                                │
│                    1,247 手已记录                            │
│                                                             │
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

---

## Tilt 警告（中文）

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
└─────────────────────────────────────────────────────────────┘
```

### 警告文案

| 类型 | 标题 | 内容 |
|------|------|------|
| VPIP 偏高 | 入池率警告 | 你的入池比平时更松了 |
| 弱牌扩展 | 范围警告 | 你在玩边缘牌，检查状态 |
| 连续输 | 情绪警告 | 连续未赢，建议休息一下 |
| 越打越松 | 范围扩大 | 入池率正在上升 |

---

## 组件规格总结

| 组件 | 高度 | 圆角 | 深色背景 | 浅色背景 |
|------|------|------|----------|----------|
| GlassCard | auto | 20pt | .regularMaterial | .regularMaterial |
| 主按钮 (弃牌/入池) | 120pt | 28pt | #1C1C1E | #F2F2F7 |
| 结果按钮 (赢/未赢) | 72pt | 18pt | — | — |
| 花色按钮 | 48pt | 14pt | — | — |
| 牌选择卡片 | 64pt | 12pt | #1C1C1E | #F2F2F7 |
| 副统计卡片 | 64pt | 12pt | Glass | Glass |
| Session 列表项 | 72pt | 16pt | #1C1C1E | #F2F2F7 |

---

## 动画系统

```swift
extension Animation {
    static let numeric = Animation.spring(response: 0.4, dampingFraction: 0.9)
    static let press = Animation.easeOut(duration: 0.1)
    static let sheet = Animation.spring(response: 0.35, dampingFraction: 0.85)
    static let breathe = Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)
}
```

### 触感反馈

| 操作 | 触感 |
|------|------|
| 弃牌 | `.impact(.light)` |
| 入池 | `.impact(.medium)` |
| 选牌 | `.selection` |
| 赢 | `.notification(.success)` |
| 未赢 | `.impact(.light)` |
| 警告 | `.notification(.warning)` |

---

## 设计检查清单

### 专业感
- [ ] 无游戏/娱乐元素
- [ ] 信息克制 (≤3 数据/页面)
- [ ] 中文文案自然
- [ ] 字体层级清晰

### 视觉惊艳
- [ ] Hero 数据足够大
- [ ] Glass 效果正确
- [ ] Edge Glow 状态
- [ ] 深浅色都好看

### 系统适配
- [ ] 跟随系统深浅色
- [ ] 颜色定义在 Assets
- [ ] Glass 自动适配

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v0.9 | 2026-03-06 | 初始设计 |
| v1.0 | 2026-03-06 | 单页输入 |
| v1.1 | 2026-03-06 | 专业分析工具风格 |
| v1.2 | 2026-03-06 | **中文优先** + **跟随系统深浅色** |

---

*TiltGuard Design System v1.2*
*专业分析 · Apple 级设计 · 中文优先*
