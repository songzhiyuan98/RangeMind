# VPCT – VPIP Controller

## MVP Implementation Plan

> A real-time poker behavior analyzer that tracks VPIP and detects tilt during live sessions.

---

## Product Overview

**VPCT (VPIP Controller)** is a mobile poker assistant that helps players:
- Track their VPIP (Voluntarily Put $ In Pot) in real-time
- Detect tilt patterns through event-driven behavioral analysis
- Escalate to cooldown mode when behavior doesn't self-correct
- Analyze session and lifetime statistics
- Understand their playing style

---

## App Architecture

### Pages & Navigation

```
4 个 Tab：
├── VT (Home)      — 首页，VPIP 概览 + 最近 session
├── Live (Session)  — 牌局中，实时记录 + tilt 检测
├── Stats           — 统计分析（仅登录用户）
└── Me (Settings)   — 设置，账户，语言，外观
```

### Tech Stack

| Layer | Technology |
|-------|------------|
| UI Framework | SwiftUI |
| Architecture | @Observable + DataService (centralized) |
| Local Storage | SwiftData |
| Authentication | Sign in with Apple (planned) |
| State Management | @Observable |
| Localization | In-app L10n enum (English/Chinese) |

---

## Account System

### Guest Mode (当前默认)

- 无需登录即可使用所有 session 功能
- Guest 数据**不持久化**：app 重启后清除已完成的 session
- Lifetime 统计在 guest 模式下不累积
- 关键时刻提示登录：session 结束时、首页 banner

### Logged-in Mode (planned)

- Sign in with Apple
- 数据持久化，lifetime 统计累积
- Stats 页面完整开放

### Data Models

**PlayerData**
| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Unique identifier |
| `createdAt` | Date | Account creation |
| `lifetimeHands` | Int | Total hands played |
| `lifetimeVPIPHands` | Int | Total VPIP hands |

**SessionData**
| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Unique identifier |
| `startTime` | Date | Session start |
| `endTime` | Date? | Session end (nil = active) |
| `totalHands` | Int | Hands this session |
| `vpipHands` | Int | VPIP hands this session |
| `totalBBResult` | Double? | BB profit/loss |
| `handRecords` | [HandRecordData] | Cascade delete relationship |

**HandRecordData**
| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Unique identifier |
| `timestamp` | Date | Hand timestamp |
| `didVPIP` | Bool | Whether player VPIPed |
| `card1Rank` | String? | First card rank |
| `card2Rank` | String? | Second card rank |
| `isSuited` | Bool? | Suited or offsuit |
| `resultRaw` | String? | WIN / NOT_WIN |
| `bbResult` | Double? | BB result (optional) |
| `positionRaw` | String? | Reserved for Pro |
| `actionTypeRaw` | String? | Reserved for Pro |
| `session` | SessionData? | Parent session |

---

## Hand Recording

### Input Flow (≤ 4 clicks)

```
1. Tap card 1 (rank: A-2)
2. Tap card 2 (rank: A-2, same = pocket pair)
3. (Optional) Toggle suited/offsuit (auto-disabled for pocket pairs)
4. (Optional) Enter BB amount
5. Tap WIN or LOSS → auto dismiss
```

### Fold Recording
- Single tap FOLD button
- Haptic feedback (medium impact) + visual flash on stats strip
- `totalHands += 1`, no further input

### Data Management
- Session 内手牌支持**长按删除**（context menu）
- 首页和全部 session 列表支持**长按删除 session**
- 删除 session 时自动反向扣减 lifetime 统计并重新计算

---

## Real-Time Statistics

### Session Screen Metrics

| State | Display |
|-------|---------|
| Warm-up (< 10 hands) | Progress ring countdown, hand count |
| Normal | Session VPIP (hero), 30min / lifetime / hands strip |
| Warning | 30min VPIP (hero, amber), session / lifetime strip |
| Danger | 30min VPIP (hero, red), shake animation |
| Observing | Amber progress ring (X/5 hands), watching behavior |
| Cooldown | Red countdown ring (remaining/total), tighten range |

### Player Type Classification

| VPIP Range | Type | Description |
|------------|------|-------------|
| < 15% | Nit | Only premium hands |
| 15-19% | Tight | Selective entry |
| 20-24% | Standard | Balanced style |
| 25-29% | Loose | Wide range |
| ≥ 30% | Very Loose | Too many entries |

---

## Tilt Detection System (Core Feature)

### Architecture: Event-Driven Behavioral Analysis

4 个独立检测器，按优先级排序：

#### 1. Loss-Chase (逆风追损) — Priority: Highest
- **Trigger**: 最近 8 手 VPIP 中 60%+ 输了，且 VPIP 比 baseline 高 8%+
- **Severe**: Big loss revenge — 大底池输后入池率激增到 40%+
- **Message**: "追损中 — 大底池后 VPIP 飙升"

#### 2. Style Drift (风格失真) — Priority: High (danger only)
- **Trigger**: 近期手牌包含从未/很少打过的弱牌
- **Severe**: 3+ 不在常规范围内的弱牌
- **Also checks**: Progressive loosening (后半段 VPIP 比前半段高 10%+)

#### 3. Win-Tilt (顺风膨胀) — Priority: Medium
- **Trigger**: 胜率 60%+ 且 VPIP 扩张 8%+，弱牌开始出现
- **Message**: "连赢后范围扩大" / "势头可能正在扩大你的范围"

#### 4. VPIP Drift (基础漂移) — Priority: Lowest
- **Trigger**: 30min VPIP 比 lifetime 高 10-15%+
- **Message**: "范围略宽于你的常规" / "入池范围明显偏宽"

### Status Levels

```
Normal  → No glow, no alerts
Warning → Amber border glow, coach message card
Danger  → Red border glow, shake animation, coach message
```

---

## Cooldown Escalation System

### State Machine

```
normal → observing → cooldown → normal
                  ↘ normal (if behavior improves)
```

### Phase Details

| Phase | Duration | Exit Condition |
|-------|----------|---------------|
| Normal | — | Coach message fires → enter Observing |
| Observing | 5 hands | Behavior improved → Normal; Still deviating → Cooldown |
| Cooldown | 10 hands (initial) | Countdown to 0 → Normal; Still deviating → extend +3/+5 (max 20) |

### Trigger-Specific Exit Conditions

冷静期的退出条件根据触发原因不同而不同：

| Trigger Type | Deviation Check | Extension |
|-------------|----------------|-----------|
| `lossBased` (追损) | VPIP elevated OR weak hands OR losses + wide range | +5 hands |
| `winBased` (顺风) | VPIP elevated OR weak hands (不检查 loss 信号) | +3 hands (更温和) |
| `driftBased` (漂移) | Same as lossBased | +5 hands |

**核心逻辑**: Win-tilt 的冷静期不判断"亏损后继续宽范围"信号，因为用户本来在赢，问题是过度自信而非追损。延长也更温和。

### Deviation Check (`isStillDeviating`)

```
Signal A: VPIP rate in last 5 hands still ≥ baseline + 10%
Signal B: 2+ weak hands played in last 5 hands
Signal C: (lossBased/driftBased only) 2+ losses + 3+ VPIP entries in last 5

Any signal = still deviating
```

### UI Presentation

- **Observing**: Amber progress ring (X/5), "观察中" label
- **Cooldown**: Red countdown ring (remaining/total), "冷静模式" label, "收紧范围" badge

---

## Settings & Feature Toggles

### Notification Settings Page

| Toggle | Key | Default | Controls |
|--------|-----|---------|----------|
| Tilt Alert | `vt_tilt_enabled` | ON | Whether tilt detection & coach messages are shown |
| Cooldown Mode | `vt_cooldown_enabled` | ON | Whether cooldown escalation system is active |

### Other Settings

- **Appearance**: System / Light / Dark
- **Language**: English (default) / Chinese
- **About**: Version, Privacy Policy, Terms of Use

---

## Localization System

### Architecture

- In-app localization via `L10n` enum (not iOS `.strings` files)
- `LanguageManager` (@Observable) stores language preference in UserDefaults
- `L10n.s(.key, lang)` pattern throughout all views
- 80+ keys covering all UI text
- App name "VPCT" / "VPIP CONTROLLER" is **NOT translated**

### Supported Languages

| Language | Code | Label |
|----------|------|-------|
| English | `.english` | English |
| Chinese | `.chinese` | 中文 |

---

## Stats Page

### Access Control

| User State | Stats Access |
|------------|-------------|
| Guest | Locked — shows sign-in prompt |
| Logged in, < 10 hands | Empty state — "Play more hands" |
| Logged in, ≥ 10 hands | Full stats |

### Content (for logged-in users)

1. **Header**: Player type badge, lifetime VPIP, total hands
2. **BB Stats**: Total BB, BB/100
3. **GTO Compliance**: In-range %, common deviations, suggestions
4. **Tilt Analysis**: Tilt sessions count, rate, average duration

---

## Implementation Status

### ✅ Completed
- [x] SwiftData models (Player, Session, HandRecord)
- [x] Session system (start, end, active session tracking)
- [x] Hand recording (fold + VPIP with card selection)
- [x] VPIP calculation (session, 30-min rolling, lifetime)
- [x] Player type classification
- [x] 4-detector tilt detection system
- [x] Cooldown escalation system with trigger-specific logic
- [x] In-app localization (English/Chinese)
- [x] Guest mode architecture
- [x] Custom tab bar navigation (4 tabs)
- [x] Settings (appearance, language, feature toggles)
- [x] Session/hand delete with stats recalculation
- [x] Haptic feedback system

### 🔲 Pending
- [ ] Sign in with Apple authentication
- [ ] Cloud data sync
- [ ] Privacy policy & terms
- [ ] App Store submission
- [ ] TestFlight beta testing

---

## Weak Hand Reference

**Hands tracked for tilt detection:**

| Category | Examples |
|----------|----------|
| Weak Broadway | `KTo`, `QTo`, `JTo` |
| Weak Suited | `K9s`, `Q9s`, `J8s` |
| Gap Hands | `K7s`, `Q8s`, `J7s` |
| Marginal | `A9o`, `K8o`, `Q7o` |
| Connectors | `T9o`, `98o`, `87o` |

---

*Document Version: 2.0*
*Last Updated: 2026-03-12*
