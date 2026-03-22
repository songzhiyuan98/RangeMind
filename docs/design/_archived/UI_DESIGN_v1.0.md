# TiltGuard UI Design System v1.0

> iOS 26 Liquid Glass · Native API · One-Page Input

---

## 设计哲学

### 三大原则

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   1. 一触即达                                                │
│      Every action within thumb's reach                      │
│      单手操作，最少点击                                      │
│                                                             │
│   2. 信息层次                                                │
│      Glanceable hierarchy                                   │
│      核心数据一眼可见，次要信息渐进展示                        │
│                                                             │
│   3. 沉浸美学                                                │
│      Immersive elegance                                     │
│      深色环境 + 液态玻璃 + 扑克氛围                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## iOS 26 原生液态玻璃 API

### 核心修饰符

```swift
import SwiftUI

// ✅ 使用 iOS 26 原生 API
struct CardView: View {
    var body: some View {
        content
            .glassEffect()                    // 主要玻璃效果
            .glassEffect(.regular.tinted)     // 带色调的玻璃
            .glassEffect(.thin)               // 轻薄玻璃
            .glassEffect(.thick)              // 厚重玻璃
    }
}

// 容器玻璃效果
.containerBackground(.glass, for: .widget)

// TabBar 原生玻璃
TabView {
    // tabs
}
.tabViewStyle(.sidebarAdaptable)  // iOS 26 新样式
```

### 材质层级

| 层级 | API | 用途 |
|------|-----|------|
| 背景层 | `Color.black` | App 底层背景 |
| 环境层 | 渐变 + 微光 | 营造扑克厅氛围 |
| 玻璃层 | `.glassEffect()` | 卡片、按钮容器 |
| 内容层 | 文字/图标 | 实际信息 |
| 浮层 | `.glassEffect(.thick)` | 弹窗、Alert |

---

## 色彩系统

### 环境背景

```swift
// 扑克厅深色氛围背景
struct PokerAmbientBackground: View {
    var body: some View {
        ZStack {
            // 基础深色
            Color(hex: "#0A0D14")

            // 左上角微光（模拟赌场灯光）
            RadialGradient(
                colors: [
                    Color(hex: "#1E3A5F").opacity(0.4),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 400
            )

            // 右下角暖光
            RadialGradient(
                colors: [
                    Color(hex: "#2D1B4E").opacity(0.3),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 350
            )
        }
        .ignoresSafeArea()
    }
}
```

### 强调色

```
Primary Green (扑克绿)
━━━━━━━━━━━━━━━━━━━━━━
#00E676  亮态 - 用于主按钮、胜利状态
#00C853  标准 - 用于选中态、强调
#00A844  暗态 - 用于按压态

Accent Gold (点缀金)
━━━━━━━━━━━━━━━━━━━━━━
#FFD54F  用于高亮数据、特殊提示

Alert Colors (警告色)
━━━━━━━━━━━━━━━━━━━━━━
Warning:  #FF9100 → #FFAB40
Danger:   #FF5252 → #FF1744
```

### 文字色彩

```swift
extension Color {
    static let textPrimary = Color.white                    // 100%
    static let textSecondary = Color.white.opacity(0.7)     // 70%
    static let textTertiary = Color.white.opacity(0.45)     // 45%
    static let textDisabled = Color.white.opacity(0.25)     // 25%
}
```

---

## 排版系统

### 字体规范

```swift
extension Font {
    // 超大数字显示 (VPIP 百分比)
    static let displayLarge = Font.system(
        size: 72,
        weight: .bold,
        design: .rounded
    )

    // 大数字 (次要统计)
    static let displayMedium = Font.system(
        size: 32,
        weight: .semibold,
        design: .rounded
    )

    // 卡牌等级显示
    static let cardRank = Font.system(
        size: 28,
        weight: .bold,
        design: .rounded
    )

    // 标签 (全大写)
    static let label = Font.system(
        size: 11,
        weight: .semibold
    ).uppercaseSmallCaps()

    // 正文
    static let body = Font.system(size: 16, weight: .regular)

    // 按钮
    static let button = Font.system(size: 18, weight: .semibold)
}
```

### 数字显示特殊处理

```swift
// VPIP 数字使用等宽数字，防止布局跳动
Text("23%")
    .font(.displayLarge)
    .monospacedDigit()
    .contentTransition(.numericText())  // 数字变化动画
```

---

## 核心页面设计

### 1. Session 主页面（最重要）

```
┌─────────────────────────────────────────────────────────────┐
│                        9:41                                 │
│  ← Session                                 End ■            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                                                     │    │
│  │                                                     │    │
│  │                      23%                            │    │
│  │                   ──────────                        │    │
│  │                  SESSION VPIP                       │    │
│  │                                                     │    │
│  │         ┌─────────────────────────────┐             │    │
│  │         │ ⚠️  Playing Looser          │             │    │
│  │         └─────────────────────────────┘             │    │
│  │                                                     │    │
│  │    ╭───────╮    ╭───────╮    ╭───────╮             │    │
│  │    │  34%  │    │  21%  │    │  45   │             │    │
│  │    │ 30MIN │    │  LIFE │    │ HANDS │             │    │
│  │    ╰───────╯    ╰───────╯    ╰───────╯             │    │
│  │                                                     │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│    ┌───────────────────┐    ┌───────────────────┐          │
│    │                   │    │                   │          │
│    │                   │    │                   │          │
│    │       FOLD        │    │       VPIP        │          │
│    │                   │    │     ● ● ● ●       │          │
│    │                   │    │                   │          │
│    │                   │    │                   │          │
│    └───────────────────┘    └───────────────────┘          │
│                                                             │
│                         ───                                 │
└─────────────────────────────────────────────────────────────┘
```

**设计细节：**

| 元素 | 规格 |
|------|------|
| 主 VPIP 数字 | 72pt Bold Rounded, 纯白色 |
| 标签文字 | 11pt Semibold Uppercase, 45% 白 |
| 状态提示条 | 橙色渐变边框玻璃卡片，8pt 圆角 |
| 副统计卡片 | 48x48pt 玻璃小卡片，无边框 |
| FOLD 按钮 | `.glassEffect(.regular)`, 28pt 圆角 |
| VPIP 按钮 | 绿色渐变 + 外发光 + 28pt 圆角 |
| 按钮高度 | 100pt (方便单手拇指操作) |
| 按钮间距 | 16pt |

**VPIP 按钮特殊效果：**

```swift
// VPIP 按钮 - 视觉焦点
ZStack {
    // 外发光
    RoundedRectangle(cornerRadius: 28, style: .continuous)
        .fill(Color.green)
        .blur(radius: 20)
        .opacity(0.4)

    // 主按钮
    RoundedRectangle(cornerRadius: 28, style: .continuous)
        .fill(
            LinearGradient(
                colors: [Color(hex: "#00E676"), Color(hex: "#00C853")],
                startPoint: .top,
                endPoint: .bottom
            )
        )

    // 顶部高光
    RoundedRectangle(cornerRadius: 28, style: .continuous)
        .fill(
            LinearGradient(
                colors: [Color.white.opacity(0.3), Color.clear],
                startPoint: .top,
                endPoint: .center
            )
        )

    // 四个点装饰（代表花色）
    HStack(spacing: 6) {
        ForEach(0..<4) { _ in
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 6, height: 6)
        }
    }
    .offset(y: 20)

    Text("VPIP")
        .font(.system(size: 22, weight: .bold))
        .foregroundColor(.white)
        .offset(y: -8)
}
```

---

### 2. VPIP 输入页面（单页完成）⭐

**核心设计：所有输入在一个页面完成**

```
┌─────────────────────────────────────────────────────────────┐
│                        9:41                                 │
│  ✕                                                          │
│                                                             │
│                                                             │
│    ┌───────────────────────────────────────────────────┐    │
│    │                                                   │    │
│    │              YOUR HAND                            │    │
│    │                                                   │    │
│    │         ┌───────┐    ┌───────┐                   │    │
│    │         │       │    │       │                   │    │
│    │         │   K   │    │   9   │                   │    │
│    │         │       │    │       │                   │    │
│    │         └───────┘    └───────┘                   │    │
│    │                                                   │    │
│    │              ┌───────────┐                       │    │
│    │              │  SUITED   │                       │    │
│    │              └───────────┘                       │    │
│    │                                                   │    │
│    └───────────────────────────────────────────────────┘    │
│                                                             │
│    ┌───────────────────────────────────────────────────┐    │
│    │                                                   │    │
│    │  A   K   Q   J   T   9   8   7   6   5   4   3   2│    │
│    │  ○   ●   ○   ○   ○   ●   ○   ○   ○   ○   ○   ○   ○│    │
│    │                                                   │    │
│    └───────────────────────────────────────────────────┘    │
│                                                             │
│    ┌─────────────────────┐  ┌─────────────────────┐        │
│    │   ♠♣  SUITED  ♦♥   │  │   ♠♦  OFFSUIT ♣♥   │        │
│    └─────────────────────┘  └─────────────────────┘        │
│                                                             │
│                                                             │
│    ┌───────────────────┐    ┌───────────────────┐          │
│    │                   │    │                   │          │
│    │       WIN ✓       │    │    NOT WIN ✗     │          │
│    │                   │    │                   │          │
│    └───────────────────┘    └───────────────────┘          │
│                                                             │
│                         ───                                 │
└─────────────────────────────────────────────────────────────┘
```

**交互流程：**

```
1. 点击两个牌 (从横向滚动列表中选择)
   ↓ 自动
2. 花色默认选中 "Offsuit"，可点击切换
   ↓ 自动
3. 点击 WIN 或 NOT WIN → 完成记录，自动返回
```

**完整设计规格：**

```swift
struct VPIPInputView: View {
    @State private var card1: String? = nil
    @State private var card2: String? = nil
    @State private var isSuited: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // 顶部关闭按钮
            closeButton

            Spacer()

            // 手牌预览卡片
            handPreviewCard

            Spacer().frame(height: 32)

            // 牌等级选择器 (横向滚动)
            rankSelector

            Spacer().frame(height: 24)

            // 花色选择器
            suitSelector

            Spacer().frame(height: 32)

            // 结果按钮
            resultButtons

            Spacer()
        }
        .background(PokerAmbientBackground())
    }
}
```

**牌等级选择器设计：**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  ← 可滑动                                          可滑动 → │
│                                                             │
│    ╭─────╮ ╭─────╮ ╭─────╮ ╭─────╮ ╭─────╮ ╭─────╮ ╭─────╮  │
│    │     │ │ ███ │ │     │ │     │ │     │ │ ███ │ │     │  │
│    │  A  │ │  K  │ │  Q  │ │  J  │ │  T  │ │  9  │ │  8  │  │
│    │     │ │ ███ │ │     │ │     │ │     │ │ ███ │ │     │  │
│    ╰─────╯ ╰─────╯ ╰─────╯ ╰─────╯ ╰─────╯ ╰─────╯ ╰─────╯  │
│                                                             │
│    未选中: 玻璃背景, 70% 白色文字                            │
│    已选中: 绿色背景, 白色文字, 放大 1.05x                    │
│                                                             │
│    卡片尺寸: 52 x 68 pt                                     │
│    圆角: 12pt                                               │
│    间距: 10pt                                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

```swift
// 单个牌等级卡片
struct RankCard: View {
    let rank: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(rank)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 52, height: 68)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                colors: [Color(hex: "#00E676"), Color(hex: "#00C853")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        } else {
                            Color.clear
                        }
                    }
                )
                .glassEffect(isSelected ? .thin : .regular)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}
```

**手牌预览卡片：**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                                                     │   │
│   │                    YOUR HAND                        │   │
│   │                                                     │   │
│   │            ╭─────────╮    ╭─────────╮              │   │
│   │            │         │    │         │              │   │
│   │            │    K    │    │    9    │              │   │
│   │            │    ♠    │    │    ♠    │              │   │
│   │            │         │    │         │              │   │
│   │            ╰─────────╯    ╰─────────╯              │   │
│   │                                                     │   │
│   │                 ╭─────────────╮                    │   │
│   │                 │   SUITED    │                    │   │
│   │                 ╰─────────────╯                    │   │
│   │                                                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   卡片背景: .glassEffect(.regular)                          │
│   内部手牌: 白色背景, 深色文字 (真实扑克牌样式)              │
│   手牌尺寸: 64 x 88 pt                                      │
│   手牌间距: 16pt, 轻微旋转 ±3°                              │
│   花色标签: 小玻璃胶囊, 绿色边框表示 Suited                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

```swift
// 预览中的扑克牌
struct PokerCard: View {
    let rank: String
    let suitSymbol: String  // ♠ ♥ ♦ ♣
    let rotation: Double

    var body: some View {
        VStack(spacing: 4) {
            Text(rank)
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text(suitSymbol)
                .font(.system(size: 20))
        }
        .foregroundColor(suitSymbol == "♥" || suitSymbol == "♦" ? .red : .black)
        .frame(width: 64, height: 88)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        .rotationEffect(.degrees(rotation))
    }
}
```

**花色选择器：**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│    ┌─────────────────────┐    ┌─────────────────────┐      │
│    │                     │    │                     │      │
│    │   ♠ ♣   SUITED      │    │   ♠ ♦   OFFSUIT    │      │
│    │                     │    │                     │      │
│    └─────────────────────┘    └─────────────────────┘      │
│                                                             │
│    选中态:                                                  │
│    - 绿色边框 2pt                                           │
│    - 内部绿色微光                                           │
│    - 文字 100% 白                                           │
│                                                             │
│    未选中态:                                                │
│    - 无边框                                                 │
│    - 纯玻璃背景                                             │
│    - 文字 70% 白                                            │
│                                                             │
│    按钮高度: 56pt                                           │
│    圆角: 16pt                                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**结果按钮（终止操作）：**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│    ┌───────────────────┐    ┌───────────────────┐          │
│    │                   │    │                   │          │
│    │        ✓          │    │        ✗          │          │
│    │       WIN         │    │     NOT WIN       │          │
│    │                   │    │                   │          │
│    └───────────────────┘    └───────────────────┘          │
│                                                             │
│    WIN 按钮:                                                │
│    - 绿色渐变填充                                           │
│    - 绿色外发光                                             │
│    - 点击后: 成功触感 + 缩放动画 + 自动返回                 │
│                                                             │
│    NOT WIN 按钮:                                            │
│    - 玻璃背景                                               │
│    - 红色图标                                               │
│    - 点击后: 轻触感 + 自动返回                              │
│                                                             │
│    按钮高度: 80pt                                           │
│    圆角: 20pt                                               │
│    禁用态: 未选完两张牌时, opacity 0.4                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**完整交互时序：**

```
用户操作                    系统响应
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
点击 VPIP 按钮       →     半透明遮罩 + 输入面板从底部弹出
                           触感: .impact(.medium)
                           动画: spring(response: 0.35)

点击第一张牌 K       →     K 卡片高亮, 预览区显示 K
                           触感: .selection

点击第二张牌 9       →     9 卡片高亮, 预览区显示 K 9
                           自动判断是否可以 Suited
                           如果两张牌相同: Suited 按钮禁用
                           触感: .selection

点击 SUITED          →     花色切换, 预览区显示花色符号
(可选操作)                  触感: .selection

点击 WIN             →     按钮放大缩小动画
                           预览卡片飞向顶部消失
                           触感: .notification(.success)
                           面板收起, 返回 Session 页
                           统计数据更新动画
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

总点击次数: 4 次 (最少路径)
总耗时预估: 2-3 秒
```

---

### 3. Home 首页

```
┌─────────────────────────────────────────────────────────────┐
│                        9:41                                 │
│                                                             │
│                                                             │
│             T I L T G U A R D                               │
│            ─────────────────                                │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                                                     │   │
│   │                                                     │   │
│   │                      21%                            │   │
│   │                 LIFETIME VPIP                       │   │
│   │                                                     │   │
│   │   ─────────────────────────────────────────────    │   │
│   │                                                     │   │
│   │           Standard Player                           │   │
│   │           1,247 hands tracked                       │   │
│   │                                                     │   │
│   │                                                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   RECENT SESSIONS                                           │
│   ───────────────                                           │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  Today, 2:30 PM                            24% →   │   │
│   │  45 hands  ·  1h 20m                               │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  Yesterday                                  19% →   │   │
│   │  78 hands  ·  2h 15m                               │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│                                                             │
│            ╭───────────────────────────────╮                │
│            │                               │                │
│            │       Start Session  ▶        │                │
│            │                               │                │
│            ╰───────────────────────────────╯                │
│                                                             │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│       🏠          📋          📊          👤                │
│      Home       History     Analysis     Profile            │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Logo 设计：**

```
T I L T G U A R D
─────────────────

字体: SF Pro Display, Semibold
字间距: 8pt (极宽)
大小: 18pt
颜色: 白色 85%
效果: 底部细线装饰
```

**Start Session 按钮：**

```swift
// 主 CTA 按钮
struct StartSessionButton: View {
    var body: some View {
        HStack(spacing: 12) {
            Text("Start Session")
                .font(.system(size: 18, weight: .semibold))

            Image(systemName: "play.fill")
                .font(.system(size: 14))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            LinearGradient(
                colors: [Color(hex: "#00E676"), Color(hex: "#00C853")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.green.opacity(0.4), radius: 16, y: 4)
    }
}
```

---

### 4. Tilt 警告设计

**警告等级视觉系统：**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Level 1: Info (蓝色)                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ℹ️  You've been playing for 2 hours                │   │
│  │      Consider taking a short break.                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Level 2: Warning (橙色)                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ⚠️  VPIP Alert                                     │   │
│  │      You are playing looser than usual.             │   │
│  │      30min: 34%  →  Lifetime: 21%                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Level 3: Danger (红色)                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  🚨  Possible Tilt Detected                         │   │
│  │      4 consecutive losses with weak hands.          │   │
│  │      Strongly consider taking a break.              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**警告弹窗动画：**

```swift
// 警告弹出效果
struct TiltAlertView: View {
    @State private var isPresented = false

    var body: some View {
        VStack(spacing: 16) {
            // 图标 (带脉冲动画)
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
                .symbolEffect(.pulse, options: .repeating)

            Text("VPIP Alert")
                .font(.system(size: 22, weight: .bold))

            Text("You are playing looser than usual.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // 数据对比
            HStack(spacing: 24) {
                VStack {
                    Text("34%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.orange)
                    Text("30 MIN")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)

                VStack {
                    Text("21%")
                        .font(.system(size: 24, weight: .bold))
                    Text("LIFETIME")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)

            Button("I Understand") {
                // dismiss
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .padding(24)
        .glassEffect(.thick)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
        )
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .sensoryFeedback(.warning, trigger: isPresented)
    }
}
```

---

## 动画系统

### 核心动画曲线

```swift
extension Animation {
    // 标准交互
    static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.7)

    // 弹窗/面板
    static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.8)

    // 微交互
    static let quick = Animation.easeOut(duration: 0.15)

    // 数字变化
    static let numeric = Animation.spring(response: 0.5, dampingFraction: 0.9)
}
```

### 触感反馈映射

| 操作 | 触感 | 场景 |
|------|------|------|
| 按钮点击 | `.impact(.light)` | FOLD, 导航 |
| 重要操作 | `.impact(.medium)` | VPIP, 提交 |
| 选择切换 | `.selection` | 卡牌选择, 花色切换 |
| 成功完成 | `.notification(.success)` | 手牌记录完成 |
| 警告提示 | `.notification(.warning)` | Tilt Alert |
| 错误 | `.notification(.error)` | 输入错误 |

---

## 组件库

### GlassCard

```swift
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity)
            .glassEffect()
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
```

### StatBadge

```swift
struct StatBadge: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .monospacedDigit()

            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(width: 72, height: 64)
        .glassEffect(.thin)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
```

### ActionButton

```swift
struct ActionButton: View {
    enum Style {
        case primary    // 绿色渐变
        case secondary  // 玻璃
        case danger     // 红色
    }

    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(backgroundView)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            LinearGradient(
                colors: [Color(hex: "#00E676"), Color(hex: "#00C853")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .secondary:
            Color.clear.glassEffect()
        case .danger:
            LinearGradient(
                colors: [Color(hex: "#FF5252"), Color(hex: "#FF1744")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
```

---

## 设计检查清单

### 视觉一致性
- [ ] 所有玻璃效果使用原生 `.glassEffect()` API
- [ ] 圆角统一: 小元素 8-12pt, 卡片 16-20pt, 按钮 16-28pt
- [ ] 间距遵循 4pt 基础单位
- [ ] 文字层级清晰: Display → Title → Body → Caption

### 交互体验
- [ ] 所有可点击元素有触感反馈
- [ ] 按钮有按压态 (scale 0.96)
- [ ] 数字变化有动画过渡
- [ ] 页面切换流畅

### 可用性
- [ ] 主要操作在拇指热区内
- [ ] VPIP 输入控制在 4 次点击内
- [ ] 关键数据一眼可见
- [ ] 警告信息醒目但不干扰

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v0.9 | 2026-03-06 | 初始设计 (已归档) |
| v1.0 | 2026-03-06 | 重构输入流程为单页面, 优化视觉细节, 使用原生 Liquid Glass API |

---

*TiltGuard Design System v1.0*
*iOS 26 Liquid Glass · Native API*
