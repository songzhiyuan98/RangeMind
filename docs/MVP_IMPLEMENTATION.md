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

> 详细文档见 [TILT_DETECTION.md](./TILT_DETECTION.md)

### 三层架构

5 个独立检测器，分三层按优先级排列：

```
Layer 1: 情绪驱动层 (最高优先级)
  Loss Chase danger → Style Drift danger

Layer 2: 事件 + 情绪层
  Big Pot danger → Loss Chase warning → Win Tilt → Big Pot warning

Layer 3: 行为偏移层 (最低优先级)
  Style Drift warning → VPIP Drift danger → VPIP Drift warning
```

### 设计原则

- **danger 保守**: 门槛高，不容易触发，触发即严重
- **warning 敏感**: 门槛适中，早期提醒，不触发冷静期
- **只有 danger 才进入冷静期**: warning 只显示消息
- **VPIP Drift = 数量偏移**: 入池率整体变高
- **Style Drift = 质量偏移**: 牌型质量变差

### 5 个检测器

| # | 检测器 | 层级 | 触发条件 | 级别 |
|---|--------|------|----------|------|
| 1 | **Loss Chase** (追损) | 情绪 | 输率≥60% + VPIP飙升≥8% | warning / danger |
| 2 | **Style Drift** (风格失真) | 行为 | 近期≥2/4手异常牌型 | warning / danger |
| 3 | **Big Pot** (大底池) | 事件 | 单手\|BB\|≥100，按强弱牌+输赢分4场景 | warning / danger |
| 4 | **Win Tilt** (顺风膨胀) | 情绪 | 胜率≥60% + VPIP扩大≥8% | warning only |
| 5 | **VPIP Drift** (入池漂移) | 行为 | 30min VPIP比生涯高≥10/18% | warning / danger |

### Status Levels

```
Normal  → No alerts
Warning → Coach message card (flat border style)
Danger  → Coach message card + shake animation
```

---

## Cooldown Escalation System

### 核心规则

**只有 danger 级别才触发冷静期**。warning 只显示提醒消息，不升级。

### State Machine

```
normal → danger触发 → observing (5手) → 未改善 → cooldown (10手) → normal
                                      → 改善 → normal
```

### 冷静期触发映射

| 检测器 | 级别 | 冷静期触发类型 |
|--------|------|----------------|
| Loss Chase | danger | lossBased (+5手延长) |
| Style Drift | danger | driftBased (+5手延长) |
| Big Pot (弱牌输) | danger | lossBased (+5手延长) |
| VPIP Drift | danger | driftBased (+5手延长) |
| Win Tilt | warning | 不触发 |
| Big Pot (其他) | warning | 不触发 |

### Deviation Check (`isStillDeviating`)

```
Signal A: VPIP rate in last 5 hands still ≥ baseline + 10%
Signal B: 2+ weak hands / GTO deviations in last 5 hands
Signal C: (lossBased/driftBased only) 2+ losses + 3+ VPIP entries

Any signal = still deviating → extend cooldown (max 25 hands)
```

### UI Presentation

- **Observing**: Amber progress ring (X/5), "观察中" label
- **Cooldown**: Red countdown ring (remaining/total), "冷静模式" label, "收紧范围" badge

---

## Settings & Feature Toggles

### Notification Settings Page

**主开关:**

| Toggle | Key | Default | Controls |
|--------|-----|---------|----------|
| Tilt Alert | `vt_tilt_enabled` | ON | 总开关，关闭后所有检测器停用 |
| Cooldown Mode | `vt_cooldown_enabled` | ON | 冷静期升级系统 |
| GTO Advice | `vt_gto_advice_enabled` | ON | 选牌时显示翻前策略建议 |

**检测器开关** (仅在 Tilt Alert 开启时显示):

| Toggle | Key | Default | Controls |
|--------|-----|---------|----------|
| Big Pot Alert | `vt_bigpot_enabled` | ON | 大底池警报 (单手≥100BB) |
| Loss Chase | `vt_losschase_enabled` | ON | 追损检测 |
| Win Tilt | `vt_wintilt_enabled` | ON | 顺风膨胀检测 |
| Style Drift | `vt_styledrift_enabled` | ON | 风格偏离检测 |
| VPIP Drift | `vt_vpipdrift_enabled` | ON | 入池漂移检测 |

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
- [x] 5-detector tilt detection system (三层架构)
- [x] Cooldown escalation system (danger-only, trigger-specific)
- [x] Big Pot alert (单手≥100BB, 4场景)
- [x] Individual detector toggles in settings
- [x] In-app localization (English/Chinese, 90+ keys)
- [x] Guest mode architecture
- [x] Welcome / onboarding page with Sign in with Apple
- [x] Custom flat tab bar navigation (4 tabs)
- [x] Flat iOS 18 style UI design
- [x] Settings (appearance, language, feature toggles)
- [x] Session/hand delete with stats recalculation
- [x] Haptic feedback system

### 🔲 Pending
- [ ] Sign in with Apple authentication (backend)
- [ ] Cloud data sync
- [ ] Privacy policy & terms
- [ ] App Store submission
- [ ] TestFlight beta testing

---

## Weak Hand Reference

**Hands tracked for tilt detection (Style Drift):**

| Category | Examples |
|----------|----------|
| Weak Broadway | `KTo`, `QTo`, `JTo` |
| Weak Suited | `K9s`, `Q9s`, `J8s` |
| Gap Hands | `K7s`, `Q8s`, `J7s` |
| Marginal | `A9o`, `K8o`, `Q7o` |
| Connectors | `T9o`, `98o`, `87o` |

**强牌定义 (Big Pot Alert):**

| Category | Examples |
|----------|----------|
| Premium Pairs | `AA`, `KK`, `QQ`, `JJ`, `TT`, `99` |
| Premium Suited | `AKs`, `AQs`, `AJs`, `ATs`, `KQs`, `KJs` |
| Premium Offsuit | `AKo`, `AQo` |

如果某弱牌历史盈利 (≥ 2 次记录且总 BB > 0)，则不算弱牌。

---

*Document Version: 3.0*
*Last Updated: 2026-03-22*
