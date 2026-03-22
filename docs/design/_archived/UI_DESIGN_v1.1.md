# TiltGuard Design System v1.1

> Professional Analytics Tool with Premium Apple-Style Design

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
Trading Analytics
```

### 四个关键词

```
DARK        GLASS        MINIMAL        PRECISION
深邃专业     液态玻璃      信息克制        数据精准
```

---

## 核心视觉系统

### 1. Hero Data（核心数据巨显）

**设计原则：用户打开 App 第一眼就知道「我今天打得紧还是松」**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                                                             │
│                                                             │
│                          23%                                │
│                                                             │
│                      SESSION VPIP                           │
│                                                             │
│                                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘

数字规格：
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
字体      SF Pro Rounded
字重      Bold
字号      80pt (Session 页面主数据)
          56pt (Home 页面主数据)
颜色      #FFFFFF 100%
特性      Monospaced Digit (防止布局跳动)
动画      .contentTransition(.numericText())
```

```swift
// Hero 数字组件
Text("23%")
    .font(.system(size: 80, weight: .bold, design: .rounded))
    .monospacedDigit()
    .foregroundStyle(.white)
    .contentTransition(.numericText())
    .animation(.snappy, value: vpip)
```

### 2. Glass Cards（液态玻璃卡片）

**使用 iOS 26 原生 API，极简克制**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   │
│   ┃░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░┃   │
│   ┃░░                                                ░░┃   │
│   ┃░░              GLASS CARD                        ░░┃   │
│   ┃░░                                                ░░┃   │
│   ┃░░   背景: .glassEffect()                         ░░┃   │
│   ┃░░   圆角: 20pt continuous                        ░░┃   │
│   ┃░░   内边距: 20pt                                 ░░┃   │
│   ┃░░   无边框 (干净)                                ░░┃   │
│   ┃░░                                                ░░┃   │
│   ┃░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░┃   │
│   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

```swift
// Glass Card 组件
struct GlassCard<Content: View>: View {
    let content: Content

    var body: some View {
        content
            .padding(20)
            .background(.ultraThinMaterial)
            .glassEffect()
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
```

### 3. Edge Glow（状态氛围光）

**科技感的核心视觉元素 - 像战术 HUD**

```
状态                 氛围效果
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

正常状态             边缘微弱绿色呼吸光
                    opacity: 0.3 → 0.5 循环
                    duration: 3s

┌─────────────────────────────────────────┐
│ ▓░                                   ░▓ │  ← 绿色微光
│                  23%                    │
│              SESSION VPIP               │
│ ▓░                                   ░▓ │
└─────────────────────────────────────────┘


警告状态             边缘橙色光晕
                    opacity: 0.5
                    轻微脉冲

┌─────────────────────────────────────────┐
│ ▓▓░                                 ░▓▓ │  ← 橙色警告光
│                  34%                    │
│              SESSION VPIP               │
│ ▓▓░                                 ░▓▓ │
└─────────────────────────────────────────┘


危险状态             边缘红色闪烁
                    opacity: 0.6
                    shake + pulse

┌─────────────────────────────────────────┐
│ ▓▓▓░                               ░▓▓▓ │  ← 红色危险光
│                  42%                    │
│              SESSION VPIP               │
│ ▓▓▓░                               ░▓▓▓ │
└─────────────────────────────────────────┘
```

```swift
// Edge Glow 实现
struct EdgeGlow: View {
    enum Status {
        case normal, warning, danger
    }

    let status: Status
    @State private var isAnimating = false

    var glowColor: Color {
        switch status {
        case .normal: return Color(hex: "#00C853")
        case .warning: return Color(hex: "#FF9100")
        case .danger: return Color(hex: "#FF1744")
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(glowColor, lineWidth: 2)
            .blur(radius: 8)
            .opacity(isAnimating ? 0.6 : 0.3)
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

## 色彩系统

### 精确色值

```swift
extension Color {
    // 背景层级
    static let bgPrimary = Color(hex: "#0A0A0A")      // 最深背景
    static let bgSecondary = Color(hex: "#1C1C1E")    // 卡片/元素背景

    // 主色
    static let pokerGreen = Color(hex: "#00C853")     // 标准绿
    static let pokerGreenLight = Color(hex: "#00E676") // 亮绿

    // 语义色
    static let warning = Color(hex: "#FF9100")
    static let danger = Color(hex: "#FF1744")

    // 文字
    static let textPrimary = Color.white              // 100%
    static let textSecondary = Color.white.opacity(0.6)
    static let textTertiary = Color.white.opacity(0.4)
}
```

### 背景设计

```swift
// 纯净深色背景 - 不要花哨渐变
struct AppBackground: View {
    var body: some View {
        Color(hex: "#0A0A0A")
            .ignoresSafeArea()
    }
}
```

---

## Session 页面设计（核心）

**用户 80% 时间在这个页面，必须极致打磨**

### 信息层级

```
一个页面最多：
━━━━━━━━━━━━━━━━━━━━━━
3 个数据
2 个按钮
━━━━━━━━━━━━━━━━━━━━━━
```

### 完整布局

```
┌─────────────────────────────────────────────────────────────┐
│                         9:41                                │
│                                                 End ■       │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                          23%                                │
│                                                             │
│                      SESSION VPIP                           │
│                                                             │
│                                                             │
│          ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓           │
│          ┃                                      ┃           │
│          ┃      34%          21%          45    ┃           │
│          ┃     30MIN        LIFE        HANDS   ┃           │
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
│    ┃       FOLD        ┃    ┃       VPIP        ┃          │
│    ┃                   ┃    ┃                   ┃          │
│    ┃                   ┃    ┃                   ┃          │
│    ┃                   ┃    ┃                   ┃          │
│    ┗━━━━━━━━━━━━━━━━━━━┛    ┗━━━━━━━━━━━━━━━━━━━┛          │
│                                                             │
│                          ───                                │
└─────────────────────────────────────────────────────────────┘
```

### 详细规格

```
布局结构：
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

顶部区域
    高度: 44pt
    右侧: "End" 文字按钮 (16pt Medium, 60% 白)

Hero 数据区
    VPIP 数字: 80pt Bold Rounded
    标签: 13pt Semibold Uppercase, 40% 白
    垂直居中偏上

副统计卡片
    整体: 单个 Glass Card
    内部: 3 列均分
    数字: 28pt Semibold Rounded
    标签: 10pt Semibold Uppercase, 40% 白

按钮区域
    按钮高度: 120pt (牌桌上单手操作)
    按钮间距: 16pt
    圆角: 28pt
    底部距离: Safe Area + 16pt
```

### 按钮设计

```
FOLD 按钮                              VPIP 按钮
━━━━━━━━━━━━━━━━━━━━                   ━━━━━━━━━━━━━━━━━━━━

┏━━━━━━━━━━━━━━━━━━━┓                  ┏━━━━━━━━━━━━━━━━━━━┓
┃░░░░░░░░░░░░░░░░░░░┃                  ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃
┃░░               ░░┃                  ┃▓▓               ▓▓┃
┃░░               ░░┃                  ┃▓▓               ▓▓┃
┃░░     FOLD      ░░┃                  ┃▓▓     VPIP      ▓▓┃
┃░░               ░░┃                  ┃▓▓               ▓▓┃
┃░░               ░░┃                  ┃▓▓               ▓▓┃
┃░░░░░░░░░░░░░░░░░░░┃                  ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃
┗━━━━━━━━━━━━━━━━━━━┛                  ┗━━━━━━━━━━━━━━━━━━━┛
       ↑                                       ↑
   Glass 背景                              绿色渐变
   #1C1C1E                              #00E676 → #00C853
   无发光                                   外发光


FOLD 按钮:
- 背景: .glassEffect() 或 #1C1C1E
- 文字: 20pt Semibold, 白色
- 无额外效果

VPIP 按钮:
- 背景: 绿色渐变
- 文字: 20pt Semibold, 白色
- 外发光: 绿色 blur 20pt, opacity 0.4
- 视觉权重更高，引导用户注意
```

```swift
// FOLD 按钮
struct FoldButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("FOLD")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color(hex: "#1C1C1E"))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .buttonStyle(ScaleButtonStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: /* tap */)
    }
}

// VPIP 按钮
struct VPIPButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("VPIP")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
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
                            colors: [Color(hex: "#00E676"), Color(hex: "#00C853")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    }
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: /* tap */)
    }
}

// 按压缩放效果
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
```

---

## VPIP 输入页面（单页完成）

**极简：选牌 → 花色 → 结果，一页搞定**

```
┌─────────────────────────────────────────────────────────────┐
│                         9:41                                │
│  ✕                                                          │
│                                                             │
│                                                             │
│                                                             │
│                      YOUR HAND                              │
│                                                             │
│               ┌─────────┐  ┌─────────┐                     │
│               │         │  │         │                     │
│               │    K    │  │    9    │                     │
│               │         │  │         │                     │
│               └─────────┘  └─────────┘                     │
│                                                             │
│                       SUITED                                │
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
│    ┃     SUITED        ┃    ┃     OFFSUIT       ┃          │
│    ┗━━━━━━━━━━━━━━━━━━━┛    ┗━━━━━━━━━━━━━━━━━━━┛          │
│                                                             │
│    ┏━━━━━━━━━━━━━━━━━━━┓    ┏━━━━━━━━━━━━━━━━━━━┓          │
│    ┃                   ┃    ┃                   ┃          │
│    ┃       WIN         ┃    ┃     NOT WIN       ┃          │
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

1. 点击第一张牌    →  选中高亮, 预览更新
2. 点击第二张牌    →  选中高亮, 预览更新, 花色默认 Offsuit
3. (可选) 切换花色 →  点击 SUITED 切换
4. 点击 WIN/NOT WIN → 记录完成, 自动返回, 统计更新
```

### 牌选择器

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  ← 可横向滚动                                      滚动 →   │
│                                                             │
│    ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐        │
│    │     │ │█████│ │     │ │     │ │     │ │█████│        │
│    │  A  │ │  K  │ │  Q  │ │  J  │ │  T  │ │  9  │  ...   │
│    │     │ │█████│ │     │ │     │ │     │ │█████│        │
│    └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘        │
│      ↑        ↑                              ↑             │
│    未选中   已选中                          已选中          │
│                                                             │
│  未选中: 背景 #1C1C1E, 文字 60% 白                         │
│  已选中: 绿色渐变背景, 文字 100% 白, scale 1.05            │
│                                                             │
│  卡片尺寸: 48 x 64 pt                                      │
│  圆角: 12pt                                                │
│  间距: 8pt                                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 花色选择器

```
┌───────────────────────────────────────┐
│                                       │
│  ┌─────────────────┐ ┌─────────────────┐
│  │                 │ │                 │
│  │     SUITED      │ │    OFFSUIT      │
│  │                 │ │                 │
│  └─────────────────┘ └─────────────────┘
│                                       │
│  选中态: 绿色边框 2pt + 内部绿色微光   │
│  未选中: Glass 背景, 无边框           │
│                                       │
│  高度: 48pt                           │
│  圆角: 14pt                           │
│                                       │
└───────────────────────────────────────┘
```

### 结果按钮

```
┌───────────────────────────────────────────────────────────┐
│                                                           │
│  ┌─────────────────────┐    ┌─────────────────────┐      │
│  │                     │    │                     │      │
│  │         WIN         │    │      NOT WIN        │      │
│  │                     │    │                     │      │
│  └─────────────────────┘    └─────────────────────┘      │
│                                                           │
│  WIN:                                                     │
│    背景: 绿色渐变                                         │
│    触感: .notification(.success)                          │
│    动画: 轻微放大 → 弹回 → 页面关闭                        │
│                                                           │
│  NOT WIN:                                                 │
│    背景: #1C1C1E                                         │
│    触感: .impact(.light)                                  │
│    动画: 页面关闭                                         │
│                                                           │
│  高度: 72pt                                               │
│  圆角: 18pt                                               │
│  禁用态 (未选完牌): opacity 0.4, 不可点击                 │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

---

## Home 首页

**简洁大气，突出终身数据**

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
│                      LIFETIME VPIP                          │
│                                                             │
│                    Standard Player                          │
│                   1,247 hands tracked                       │
│                                                             │
│                                                             │
│                                                             │
│   RECENT                                                    │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  Today                                       24% → │   │
│   │  45 hands  ·  1h 20m                               │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  Yesterday                                   19% → │   │
│   │  78 hands  ·  2h 15m                               │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│                                                             │
│            ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓               │
│            ┃       Start Session   ▶       ┃               │
│            ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛               │
│                                                             │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│       ●           ○           ○           ○                 │
│      Home      History     Analysis     Profile             │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Logo 设计

```
T I L T G U A R D

字体: SF Pro Display
字重: Semibold
字号: 16pt
字间距: 6pt (宽松)
颜色: 60% 白
位置: 页面顶部居中
```

### 玩家类型显示

```swift
enum PlayerType: String {
    case nit = "Nit"
    case tight = "Tight"
    case standard = "Standard"
    case loose = "Loose"
    case veryLoose = "Very Loose"

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

// 显示
Text("Standard Player")
    .font(.system(size: 16, weight: .medium))
    .foregroundStyle(.white.opacity(0.8))

Text("1,247 hands tracked")
    .font(.system(size: 14))
    .foregroundStyle(.white.opacity(0.4))
```

---

## Tilt 警告系统

### 警告出现动画

```
触发 → 屏幕轻微震动 → 警告卡片从底部滑入 → Edge Glow 变色

shake:     offset x: -3, 0, 3, 0  (0.1s)
slideIn:   从 y: 100 到 y: 0     (0.35s spring)
glow:      渐变到警告色          (0.3s)
```

### 警告卡片设计

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   │
│   ┃                                                     ┃   │
│   ┃                    ⚠️                               ┃   │
│   ┃                                                     ┃   │
│   ┃               VPIP ALERT                            ┃   │
│   ┃                                                     ┃   │
│   ┃     You are playing looser than usual.              ┃   │
│   ┃                                                     ┃   │
│   ┃          34%    →    21%                            ┃   │
│   ┃         30min       Lifetime                        ┃   │
│   ┃                                                     ┃   │
│   ┃      ┌──────────────────────────────┐              ┃   │
│   ┃      │       I Understand           │              ┃   │
│   ┃      └──────────────────────────────┘              ┃   │
│   ┃                                                     ┃   │
│   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   │
│                                                             │
│   背景: Glass + 橙色边框                                    │
│   图标: SF Symbol, 40pt                                     │
│   标题: 22pt Bold                                          │
│   内容: 15pt Regular, 70% 白                                │
│   按钮: 橙色填充                                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 动画系统

### 动画原则

```
克制但精致
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 使用                    ❌ 避免
─────────────────────────────────
数字变化动画              页面翻转
按钮按压缩放              弹跳过度
警告震动                  装饰动画
状态色渐变                卡片旋转
```

### 核心动画

```swift
extension Animation {
    // 数字变化
    static let numeric = Animation.spring(response: 0.4, dampingFraction: 0.9)

    // 按钮按压
    static let press = Animation.easeOut(duration: 0.1)

    // 弹窗/面板
    static let sheet = Animation.spring(response: 0.35, dampingFraction: 0.85)

    // Edge Glow 呼吸
    static let breathe = Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)

    // 警告震动
    static let shake = Animation.easeInOut(duration: 0.1)
}
```

### 触感反馈

```swift
// 触感映射
enum HapticFeedback {
    static func fold() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func vpip() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func select() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
```

---

## Analysis 页面（专业分析）

### 雷达图

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                      YOUR PLAY STYLE                        │
│                                                             │
│                         Tight                               │
│                           │                                 │
│                           │                                 │
│              Passive ─────┼───── Aggressive                 │
│                           │                                 │
│                           │                                 │
│                         Loose                               │
│                                                             │
│                    ┌──────────────┐                         │
│                    │    TIGHT     │                         │
│                    │  AGGRESSIVE  │                         │
│                    └──────────────┘                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘

实现: Swift Charts RadialPlot
数据: VPIP (Tight/Loose), PFR (Passive/Aggressive)
```

### 手牌统计

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   MOST PLAYED                                               │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  AKs                                      47 plays  │   │
│   │  ████████████████████████░░░░░░░░░░░░░░           │   │
│   │                                           Win: 62%  │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  KQs                                      35 plays  │   │
│   │  ██████████████████░░░░░░░░░░░░░░░░░░░░           │   │
│   │                                           Win: 54%  │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘

进度条: 绿色渐变
背景: #1C1C1E
```

---

## 组件库总结

| 组件 | 高度 | 圆角 | 用途 |
|------|------|------|------|
| GlassCard | auto | 20pt | 数据展示卡片 |
| ActionButton (Large) | 120pt | 28pt | FOLD / VPIP |
| ActionButton (Medium) | 72pt | 18pt | WIN / NOT WIN |
| ActionButton (Small) | 48pt | 14pt | SUITED / OFFSUIT |
| RankCard | 64pt | 12pt | 牌选择器 |
| StatBadge | 64pt | 12pt | 小数据展示 |
| SessionRow | 72pt | 16pt | Session 列表项 |

---

## 设计检查清单

### 专业感
- [ ] 无游戏/娱乐元素
- [ ] 信息克制 (≤3 数据 / 页面)
- [ ] 颜色使用克制
- [ ] 字体层级清晰

### 视觉惊艳
- [ ] Hero 数据足够大
- [ ] Glass 效果正确使用
- [ ] Edge Glow 状态氛围
- [ ] 按钮有质感

### 交互体验
- [ ] 按钮够大 (牌桌可用)
- [ ] VPIP 输入 ≤4 次点击
- [ ] 每个操作有触感
- [ ] 动画克制但精致

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v0.9 | 2026-03-06 | 初始设计 |
| v1.0 | 2026-03-06 | 单页输入, 原生 API |
| v1.1 | 2026-03-06 | **重新定位**: 专业分析工具风格, 参考 Apple Health / Linear, 精简视觉, 加入 Edge Glow 状态系统 |

---

*TiltGuard Design System v1.1*
*Professional Analytics · Apple-Level Design*
