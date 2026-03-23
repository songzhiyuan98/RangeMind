# Tilt Detection & Alert System

## Overview

5 个独立后台检测器，映射为 4 种用户可理解的提醒类型 + 冷静期升级系统。

用户看到的只有 4 种提醒：**输后上头、赢后膨胀、技术上头、大底池**。

同时只显示一条最高优先级的提醒。总开关 (Tilt Alert) 关闭后所有检测停用。

---

## 用户提醒体系（UI 层）

| 用户看到的 | 后台检测器 | 说明 |
|---|---|---|
| 输后上头 (Loss Tilt) | Loss Chase | 连输后 VPIP 飙升，可能在追损 |
| 赢后膨胀 (Win Tilt) | Win Tilt | 连赢后范围扩大，过度自信 |
| 技术上头 (Technical Tilt) | Style Drift + VPIP Drift | 入池范围偏离常规打法 |
| 大底池 (Big Pot) | Big Pot | 单手 ≥100BB 事件提醒 |

每条提醒 = **类型名（标题）+ 一句人话（详情）**，不暴露技术术语。

---

## 三层优先级架构

```
Layer 1: 情绪驱动层 (最高优先级)
  Loss Tilt danger → Tech Tilt danger (Style Drift)

Layer 2: 事件 + 情绪层
  Big Pot danger → Loss Tilt warning → Win Tilt → Big Pot warning

Layer 3: 行为偏移层 (最低优先级)
  Tech Tilt warning (Style Drift) → Tech Tilt (VPIP Drift)
```

### 设计原则

- **danger 保守**: 门槛较高，不容易触发，一旦触发说明问题严重
- **warning 敏感**: 门槛适中，用于早期提醒，不会触发冷静期
- **只有 danger 才进入冷静期流程**: warning 只显示提醒消息，不升级
- **用户只看到类型名**: 技术分析在后台完成，UI 只呈现心理状态

---

## 提醒强度系统 (Alert Intensity)

用户可在 **设置 → 通知 → 高级** 中选择提醒强度，影响检测灵敏度和显示行为。

### 三种强度模式

| 模式 | 说明 | Warning 显示 | Danger 显示 |
|------|------|-------------|-------------|
| **轻度** (Light) | 仅关键提醒 | ❌ 不显示 | ✅ 显示 |
| **标准** (Standard) | 均衡提醒（默认） | ✅ 显示 | ✅ 显示 |
| **严格** (Strict) | 更敏感检测 + 更低阈值 | ✅ 显示 | ✅ 显示 |

### 各检测器在不同强度下的阈值差异

#### Loss Chase (→ 输后上头)

| 参数 | 轻度/标准 | 严格 |
|------|-----------|------|
| 最低手数 | 15 | **10** |
| VPIP 飙升阈值 | ≥ 8% | **≥ 6%** |
| Warning 显示 | 标准显示 / 轻度不显示 | 显示 |
| Danger 显示 | 显示 | 显示 |

#### Win Tilt (→ 赢后膨胀)

| 参数 | 轻度/标准 | 严格 |
|------|-----------|------|
| 最低手数 | 15 | **10** |
| VPIP 扩大阈值 | ≥ 8% | **≥ 6%** |
| Warning 显示 | 标准显示 / 轻度不显示 | 显示 |

> Win Tilt 只有 warning 级别，不触发冷静期。轻度模式下不显示。

#### Style Drift (→ 技术上头)

| 参数 | 轻度/标准 | 严格 |
|------|-----------|------|
| 最低手数 | 15 | **10** |
| Danger 异常牌型数 | ≥ 4 手 | **≥ 3 手** |
| Warning 异常牌型数 | ≥ 2 手 | ≥ 2 手 |
| Warning 显示 | 标准显示 / 轻度不显示 | 显示 |
| Danger 显示 | 显示 | 显示 |

#### VPIP Drift (→ 技术上头)

| 参数 | 轻度/标准 | 严格 |
|------|-----------|------|
| 30min 最低手数 | ≥ 8 | ≥ 8 |
| Danger 偏差 | ≥ 18% | **≥ 14%** |
| Warning 偏差 | ≥ 10% | **≥ 8%** |
| Warning 显示 | 标准显示 / 轻度不显示 | 显示 |
| Danger 显示 | 显示 | 显示 |

#### Big Pot (→ 大底池)

| 参数 | 轻度/标准/严格 |
|------|----------------|
| 触发条件 | 最近一手 \|BB\| ≥ 100 |
| 最低手数 | 无限制 |
| 强度影响 | 仅影响 warning 是否显示 |

> Big Pot 的触发条件不受强度影响，但轻度模式下 warning 级别（强牌赢/弱牌赢/强牌输）不显示，仅 danger（弱牌输大底池）显示。

### 冷静期触发与强度

| 参数 | 轻度/标准 | 严格 |
|------|-----------|------|
| 冷静期进入最低手数 | 15 | **10** |

---

## 后台检测器详情

### 1. Loss Chase (逆风追损)

**映射**: → 输后上头 (Loss Tilt)

**触发条件** (全部满足):
- 总手数 ≥ 15 (严格: 10)
- 最近 8 手 VPIP 手牌中输率 ≥ 60%
- 最近 8 手总 VPIP 率比生涯高 ≥ 8% (严格: 6%)

| 场景 | 级别 | UI 提醒 |
|------|------|---------|
| 大底池输 + 之后 VPIP ≥ 40% | danger | 输后上头：输牌后入池率明显飙升，建议休息 5 分钟 |
| 一般连输后 VPIP 上升 | warning | 输后上头：连输后入池率上升了，注意保持冷静 |

---

### 2. Win Tilt (顺风膨胀)

**映射**: → 赢后膨胀 (Win Tilt)

**触发条件** (全部满足):
- 总手数 ≥ 15 (严格: 10), VPIP 手数 ≥ 5
- 最近 10 手 VPIP 手牌胜率 ≥ 60%
- 最近 8 手 VPIP 率比生涯高 ≥ 8% (严格: 6%)

| 场景 | 级别 | UI 提醒 |
|------|------|---------|
| 连赢 + VPIP 扩大 | warning | 赢后膨胀：连赢后范围在扩大，注意保持纪律 |

> 只有 warning 级别，不触发冷静期。

---

### 3. Style Drift (风格失真)

**映射**: → 技术上头 (Technical Tilt)

**触发条件** (全部满足):
- 总手数 ≥ 15 (严格: 10), VPIP 手数 ≥ 5
- 生涯手牌类型 ≥ 8 种

| 场景 | 级别 | UI 提醒 |
|------|------|---------|
| 最近 8 手中 ≥ 4 手异常 (严格: 3) | danger | 技术上头：明显偏离常规打法，收紧范围 |
| 最近 8 手中 ≥ 2 手异常 | warning | 技术上头：入池范围比平时宽，检查选牌 |

**异常牌型判定**: GTO 偏差标记为 true，或不在生涯基线中且属于理论弱牌。

---

### 4. VPIP Drift (入池漂移)

**映射**: → 技术上头 (Technical Tilt)

**触发条件**:
- 30 分钟内手数 ≥ 8

| 场景 | 级别 | UI 提醒 |
|------|------|---------|
| 30min VPIP 比生涯高 ≥ 18% (严格: 14%) | danger | 技术上头：明显偏离常规打法，收紧范围 |
| 30min VPIP 比生涯高 ≥ 10% (严格: 8%) | warning | 技术上头：入池范围比平时宽，检查选牌 |

---

### 5. Big Pot (大底池)

**映射**: → 大底池 (Big Pot)

**触发**: 最近一手 VPIP 手牌的 |BB| ≥ 100，不受手数门槛限制

| 场景 | 级别 | UI 提醒 |
|------|------|---------|
| 弱牌输大底池 | danger | 大底池：这手牌不应该打这么大的底池，收紧范围 |
| 强牌赢大底池 | warning | 大底池：好结果，别让势头带你扩大范围 |
| 弱牌赢大底池 | warning | 大底池：边缘牌运气好，不代表可以继续打松 |
| 强牌输大底池 | warning | 大底池：强牌正常波动，冷静继续 |

**强牌**: AA-99, AKs-ATs, KQs-KJs, AKo-AQo

---

## 冷静期升级系统

**核心规则**: 只有 danger 级别的提醒才会触发冷静期。warning 只显示消息，不升级。

```
正常 (normal)
  ↓ danger 级别检测器触发 (≥ 15 手, 严格: ≥ 10 手)
观察期 (observing) — 观察 5 手
  ↓ 行为改善 → 恢复正常
  ↓ 行为未改善 →
冷静期 (cooldown) — 初始 10 手
  ↓ 完成 → 恢复正常
  ↓ 仍偏离 → 延长 (+5 或 +3 手, 最多 25 手)
```

### 冷静期触发映射

| 检测器 | 级别 | 冷静期触发类型 |
|--------|------|----------------|
| Loss Chase | danger | lossBased (+5 手延长) |
| Style Drift | danger | driftBased (+5 手延长) |
| Big Pot (弱牌输) | danger | lossBased (+5 手延长) |
| VPIP Drift | danger | driftBased (+5 手延长) |
| Win Tilt | warning only | 不触发 |
| Big Pot (其他) | warning only | 不触发 |

### 退出条件 (`isStillDeviating`)

检查最近 5 手:
- **共享信号**: VPIP 率仍比生涯高 ≥ 10%
- **共享信号**: 弱牌/GTO偏差 ≥ 2 手
- **共享信号**: GTO 偏差 ≥ 3 手
- **lossBased/driftBased 额外**: 亏损 ≥ 2 手 + VPIP ≥ 3 手

---

## 辅助信号

| 信号 | 描述 | 用于 |
|------|------|------|
| `hasConsecutiveLosses` | 最近 4 手 VPIP 全输 | 多检测器参考 |
| `hasWeakRangeExpansion` | 最近 5 手中 ≥ 3 手弱牌 | 多检测器参考 |
| `hasBigLossRevengeTilt` | 大亏损后 VPIP ≥ 40% | Loss Chase danger |
| `consecutiveBigLosses` | 连续亏损 ≥ 10BB 手数 | 冷静期退出判定 |

---

## 弱牌列表

```
KTo, QTo, JTo, K9o, Q9o, J9o,
K9s, Q9s, J8s, K7s, Q8s, J7s,
A9o, K8o, Q7o, T9o, 98o, 87o
```

如果某手牌历史盈利 (≥ 2 次记录且总 BB > 0)，则不算弱牌。

---

## 设置项

### 一级设置 (通知页面)

| UserDefaults Key | 默认 | 控制 |
|-----------------|------|------|
| `vt_tilt_enabled` | true | 总开关，关闭后所有检测停用 |
| `vt_cooldown_enabled` | true | 冷静期开关 |
| `vt_gto_advice_enabled` | true | GTO 翻前建议 |

### 二级设置 (高级页面，仅总开关打开时可进入)

| UserDefaults Key | 默认 | 控制 |
|-----------------|------|------|
| `vt_tilt_intensity` | "standard" | 提醒强度: light / standard / strict |
| `vt_loss_tilt_enabled` | true | 输后上头 (Loss Chase) |
| `vt_win_tilt_enabled` | true | 赢后膨胀 (Win Tilt) |
| `vt_tech_tilt_enabled` | true | 技术上头 (Style Drift + VPIP Drift) |
| `vt_bigpot_tilt_enabled` | true | 大底池 (Big Pot) |

---

## 强度对照表 (完整)

| 检测器 | 参数 | 轻度 | 标准 | 严格 |
|--------|------|------|------|------|
| **Loss Chase** | 最低手数 | 15 | 15 | 10 |
| | VPIP 飙升阈值 | ≥ 8% | ≥ 8% | ≥ 6% |
| | Warning 显示 | ❌ | ✅ | ✅ |
| | Danger 显示 | ✅ | ✅ | ✅ |
| **Win Tilt** | 最低手数 | 15 | 15 | 10 |
| | VPIP 扩大阈值 | ≥ 8% | ≥ 8% | ≥ 6% |
| | Warning 显示 | ❌ | ✅ | ✅ |
| **Style Drift** | 最低手数 | 15 | 15 | 10 |
| | Danger 异常数 | ≥ 4 | ≥ 4 | ≥ 3 |
| | Warning 异常数 | ≥ 2 | ≥ 2 | ≥ 2 |
| | Warning 显示 | ❌ | ✅ | ✅ |
| | Danger 显示 | ✅ | ✅ | ✅ |
| **VPIP Drift** | 30min 最低手数 | ≥ 8 | ≥ 8 | ≥ 8 |
| | Danger 偏差 | ≥ 18% | ≥ 18% | ≥ 14% |
| | Warning 偏差 | ≥ 10% | ≥ 10% | ≥ 8% |
| | Warning 显示 | ❌ | ✅ | ✅ |
| | Danger 显示 | ✅ | ✅ | ✅ |
| **Big Pot** | 触发条件 | \|BB\| ≥ 100 | \|BB\| ≥ 100 | \|BB\| ≥ 100 |
| | Warning 显示 | ❌ | ✅ | ✅ |
| | Danger 显示 | ✅ | ✅ | ✅ |
| **冷静期** | 进入最低手数 | 15 | 15 | 10 |

---

*Document Version: 4.0*
*Last Updated: 2026-03-22*
