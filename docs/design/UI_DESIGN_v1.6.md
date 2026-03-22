# VPCT Design System v1.6

> MVP 实战版 · 极快记录 · 智能提醒 · 冷静期

---

## 设计原则

```
核心三件事：

1. 记录 — 极快完成 (≤4 次点击)
2. 提醒 — 事件驱动 Tilt 检测
3. 冷静 — 升级式行为干预

这不是 PokerTracker，这是 VPIP Controller
```

---

## 页面结构

**4 个 Tab：**

```
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│   VT    │  │  Live   │  │  Stats  │  │   Me    │
│  首页   │  │  牌局   │  │  统计   │  │  设置   │
└─────────┘  └─────────┘  └─────────┘  └─────────┘
```

---

## 色彩系统

```swift
// 背景
vtBlack    // #0A0A0A
vtSurface  // #1C1C1E

// 主色
vtAccent   // Purple — 品牌色，按钮、logo、选中态
vtGreen    // 正面：胜利、盈利
vtAmber    // 警告：观察中、轻度偏离
vtRed      // 危险：冷静期、严重偏离

// 文字
vtText     // 100% — 主内容
vtMuted    // 60%  — 二级信息
vtDim      // 40%  — 标签、辅助

// 边框
vtBorder   // 分隔线、卡片边框
```

---

## 品牌标识

```
名称: VPCT
全称: VPIP CONTROLLER
特征: 紫色竖条 + 等宽字体
规则: 名称和全称不被翻译 (中英文相同)
```

HomeView Header:
```
┃ VPCT
┃ VPIP CONTROLLER
```
紫色 4x20 竖条 + monospaced text

---

## 1. 首页 (Home / VT Tab)

### 内容

```
┌─────────────────────────────────────────┐
│  ┃ VPCT                    [Standard]  │  ← Logo + 玩家类型
│  ┃ VPIP CONTROLLER                     │
│                                         │
│                  21                     │  ← Hero VPIP (96pt)
│                   %                     │
│            LIFETIME VPIP               │
│                                         │
│   ┌─────┬───────┬──────┬────────┐      │  ← Quick Stats
│   │ 234 │  12   │  +45 │  2.3  │      │
│   │HANDS│SESSIONS│  BB  │BB/100 │      │
│   └─────┴───────┴──────┴────────┘      │
│                                         │
│   → 5 sessions +127BB                  │  ← Insights (≥30 hands)
│                                         │
│   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓       │
│   ┃      START SESSION    ▶   ┃       │  ← 品牌紫色按钮
│   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛       │
│                                         │
│   RECENT                          ALL →│
│   ┌───────────────────────────────────┐ │
│   │ Today · 45 hands · 1h 23m  +12 24%│ │  ← 整行可点击，长按删除
│   ├───────────────────────────────────┤ │
│   │ Yesterday · 78 hands · 2h  -8  19%│ │
│   └───────────────────────────────────┘ │
│                                         │
│   ┌─ Guest Mode Banner ─────────────┐  │  ← 仅游客显示
│   │ 👤 Playing as Guest       →     │  │
│   │    Sign in to save sessions      │  │
│   └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### 新用户 (< 10 hands)
- Hero 显示 "—"
- 标签: "BUILDING PROFILE"
- 进度: "X / 10 hands"

---

## 2. 牌局页面 (Session / Live Tab)

### 状态机驱动的 Hero 区域

Session 页面的 Hero 区域由 tilt 状态机控制，共 6 种显示状态：

#### State 1: Warm-up (< 10 hands)
```
     ESTABLISHING BASELINE

           ╭─────╮
           │  7  │      ← 进度环
           │ /10 │
           ╰─────╯

      3 more to unlock VPIP
```

#### State 2: Normal (VPIP unlocked, no alert)
```
        SESSION VPIP

            23
             %

       ↑3% vs lifetime
         Hand #46
```

#### State 3: Warning (30min VPIP elevated)
```
        30MIN VPIP            ← 切换显示 30min

            34                ← 琥珀色
             %

       ↑11% vs session
      ┌──● WATCH──┐          ← 状态徽章
      └───────────┘
```

#### State 4: Observing (警告后观察窗口)
```
         OBSERVING            ← 琥珀色标签

           ╭─────╮
           │  3  │            ← 琥珀色进度环
           │ / 5 │
           ╰─────╯

  Checking behavior over next 5 hands
          23% VPIP
```

#### State 5: Cooldown (冷静期)
```
        COOLDOWN MODE         ← 红色标签

           ╭─────╮
           │  7  │            ← 红色倒计时环
           │ /10 │
           ╰─────╯

  Tighten your range for the next 10 hands

      ┌── TIGHTEN RANGE ──┐  ← 红色虚线框
      └────────────────────┘
```

#### State 6: Abnormal (danger, 30min reliable)
```
        30MIN VPIP

            42                ← 红色
             %

       ↑19% vs session
      ┌──● ADJUST──┐         ← 红色状态徽章
      └────────────┘
```

### Stats Strip

```
┌──────────┬──────────┬──────────┐
│   34%    │   21%    │    46    │
│  30MIN   │ LIFETIME │  HANDS   │
└──────────┴──────────┴──────────┘
```
- 边框颜色跟随状态 (normal: border, warning: amber, danger: red)
- Fold 按下时闪烁紫色光晕 (0.15s)

### Coach Message Card

```
┌─────────────────────────────────────┐
│ 追损中 — 大底池后 VPIP 飙升         │  ← headline (amber/red)
│ 重大损失后入池率激增。建议休息 5 分钟。│  ← detail (dim)
└─────────────────────────────────────┘
背景: amber/red 6% opacity
边框: amber/red 20% opacity
```

### Action Buttons

```
┏━━━━━━━━━━━━━━━┓  ┏━━━━━━━━━━━━━━━┓
┃     FOLD      ┃  ┃▓▓▓  VPIP  ▓▓▓┃
┃  (secondary)  ┃  ┃  (primary)    ┃
┗━━━━━━━━━━━━━━━┛  ┗━━━━━━━━━━━━━━━┛
```
- FOLD: vtSurface 背景 + vtBorder 边框, medium haptic + visual flash
- VPIP: vtAccent 背景 (品牌紫)

### Hand Records List

```
ENTRIES (5)
┌───────────────────────────────────┐
│ #5  AKs                   WIN +15│  ← 长按显示删除菜单
├───────────────────────────────────┤
│ #4  KQo                  LOSS -8 │
├───────────────────────────────────┤
│ #3  JTs                   WIN +5 │
└───────────────────────────────────┘
```

### Guest Mode Indicator
```
● Guest Session · Data will not be saved
```
显示在 stats strip 上方，小字，琥珀色圆点

---

## 3. 输入页面 (VPIP Input Sheet)

```
┌─────────────────────────────────────┐
│ ✕                                   │
│                                     │
│             YOUR HAND               │
│                                     │
│         ┌─────┐  ┌─────┐          │
│         │  K  │  │  9  │          │
│         └─────┘  └─────┘          │
│                                     │
│   A K Q J T 9 8 7 6 5 4 3 2       │  ← Rank selector
│                                     │
│   ┌──────────┐  ┏━━━━━━━━━━┓      │
│   │  SUITED  │  ┃ OFFSUIT  ┃      │  ← 品牌紫选中态
│   └──────────┘  ┗━━━━━━━━━━┛      │
│                                     │
│   BB AMOUNT                         │
│   ┌──────────────────┐  BB         │  ← 可选
│   │ 0                │             │
│   └──────────────────┘             │
│                                     │
│   ┏━━━━━━━━━━━┓  ┌───────────┐    │
│   ┃    WIN    ┃  │   LOSS    │    │  ← WIN: primary (紫), LOSS: secondary
│   ┗━━━━━━━━━━━┛  └───────────┘    │
│                                     │
│   K9o  ×3  W2/L1                   │  ← 历史记录 (if exists)
│   ┌───────────────────────────┐    │
│   │                    +15  W │    │
│   │                     -8  L │    │
│   └───────────────────────────┘    │
└─────────────────────────────────────┘
```

### 口袋对处理
选择 K + K → suited/offsuit 自动禁用 + 降低透明度

---

## 4. 统计页面 (Stats Tab)

### Guest Mode → Locked
```
┌─────────────────────────────────────┐
│                                     │
│          📊 (ultraLight)            │
│                                     │
│    Sign in to view statistics       │
│                                     │
│   ┏━━━━━━━━━━━━━━━━━━━━━━━━━┓      │
│   ┃  SIGN IN WITH APPLE    ┃      │
│   ┗━━━━━━━━━━━━━━━━━━━━━━━━━┛      │
│                                     │
└─────────────────────────────────────┘
```

### Not Enough Data (< 10 hands)
```
        📊
    No data yet
 Play more hands to see statistics
```

### Full Stats (logged in, ≥ 10 hands)

```
STATISTICS
Standard · 21% · 234 hands
Balanced playing style...

BB STATS
┌──────────────┬──────────────┐
│    +45.0     │     +2.3     │
│   TOTAL BB   │    BB/100    │
└──────────────┴──────────────┘

GTO COMPLIANCE
┌─────────────────────────────┐
│  78%   IN RANGE             │
│  12 std   4 dev             │
│  ─────────────              │
│  COMMON DEVIATIONS          │
│  [KTo] [Q9o] [J8s]         │
│  → Tighten preflop range   │
└─────────────────────────────┘

TILT ANALYSIS
┌──────────┬──────────┬──────────┐
│   4/20   │   20%    │   45m    │
│ SESSIONS │   RATE   │ AVG DUR  │
└──────────┴──────────┴──────────┘
```

---

## 5. 设置页面 (Me Tab)

```
┌─────────────────────────────────────┐
│         ┌──────┐                    │
│         │  👤  │                    │  ← 头像 (登录后显示首字母)
│         └──────┘                    │
│         Guest                       │
│     Sign in to sync your data       │
│                                     │
│ ACCOUNT                             │
│ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓     │
│ ┃    SIGN IN WITH APPLE     ┃     │
│ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛     │
│                                     │
│ SETTINGS                            │
│ ┌───────────────────────────────┐   │
│ │ 🌙 Appearance      Dark    → │   │  ← NavigationLink
│ ├───────────────────────────────┤   │
│ │ 🌐 Language      English   → │   │
│ ├───────────────────────────────┤   │
│ │ 🔔 Notifications            → │   │  ← Tilt + Cooldown toggles
│ └───────────────────────────────┘   │
│                                     │
│ ABOUT                               │
│ ┌───────────────────────────────┐   │
│ │ ℹ️ Version            1.0.0  │   │
│ ├───────────────────────────────┤   │
│ │ 🛡 Privacy Policy           → │   │
│ ├───────────────────────────────┤   │
│ │ 📄 Terms of Use             → │   │
│ └───────────────────────────────┘   │
│                                     │
│             VPCT                    │
│        VPIP CONTROLLER             │
└─────────────────────────────────────┘
```

### Notification Settings (子页面)

| Toggle | Default | Function |
|--------|---------|----------|
| Tilt Alert (⚠️) | ON | 控制 tilt 检测是否启用 |
| Cooldown Mode (⏱) | ON | 控制冷静期升级系统是否启用 |

---

## 组件规格

| Component | Height | Corner Radius |
|-----------|--------|---------------|
| Action buttons (FOLD/VPIP) | 52pt | 6pt |
| Start session button | 48pt | 6pt |
| Result buttons (WIN/LOSS) | 52pt | 6pt |
| Suit buttons | 40pt | 6pt |
| Card slot | 76pt | 8pt |
| Stats strip | auto | 8pt |
| Card (section wrapper) | auto | 8pt |
| Session list row | auto | — (inside card) |
| Coach message card | auto | 6pt |
| Alert banner | 44pt | 12pt |

---

## 触感反馈

| Action | Haptic |
|--------|--------|
| Fold | `.impact(.medium)` + visual flash |
| VPIP (open input) | — |
| Select card | `.selection` |
| WIN result | `.notification(.success)` |
| LOSS result | `.notification(.warning)` |
| Warning appears | `.notification(.warning)` |
| Danger (shake) | Shake animation (6x, 3pt) |

---

## 动画（克制）

```
保留：
✅ 数字变化 (.contentTransition(.numericText()))
✅ 按钮按压 (scale 0.97)
✅ 危险震动 (shake 6x, 0.1s each)
✅ Fold flash (0.15s fade in, 0.2s fade out)
✅ 进度环动画 (.easeOut 0.3s)
✅ 页面切换

删除：
❌ 常驻呼吸动画
❌ 复杂光晕效果
❌ 装饰性动画
```

---

## 版本历史

| Version | Date | Changes |
|---------|------|---------|
| v1.0-1.4 | 2026-03-06 | 迭代设计 (已归档) |
| v1.5 | 2026-03-06 | MVP 精简版: 3 页面, 删除复杂统计/Pro UI |
| v1.5.1 | 2026-03-06 | Logo 改为导航栏标题, "第 X 手", 趋势条形图 |
| v1.6 | 2026-03-12 | **重大更新**: 品牌改名 VPCT, 4 Tab 结构, 冷静期系统 (observing + cooldown + trigger-specific exit), 事件驱动 tilt 检测 (4 检测器), 中英文本地化, Guest 模式, 统计页 guest 锁定, Fold 触觉+视觉反馈, 手牌/session 长按删除, 设置页功能开关 (tilt alert / cooldown mode), WIN 按钮改为品牌紫色 |

---

*VPCT Design System v1.6*
*极简 MVP · 极快记录 · 智能提醒 · 冷静期*
