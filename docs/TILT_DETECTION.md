# Tilt Detection System V6

## Overview

V6 采用**衰减权重评分 + 4 状态机 + 正向反馈**，替代旧的等权重 + 2 状态系统。

核心改进：
- **快速检测上头** — 连续偏离行为 2-3 手内识别
- **自然感知恢复** — 玩家回归正常打法后分数自然回落
- **状态可见** — Normal / Watch / Tilt / Recovering 4 状态
- **恢复要稳** — 上头快抓到，恢复需稳确认
- **正向反馈** — 在高风险状态下做出正确决策时给予 UI 鼓励

---

## 评分系统

### 手牌分类

基于玩家 lifetime VPIP + 桌型修正 = `baselinePercent`，容忍线 = `baseline + 10%`

| 分类 | 条件 | 说明 |
|---|---|---|
| **baseline** | 手牌强度 ≤ baselinePercent | 正常范围内 |
| **edge** | baselinePercent < 手牌 ≤ tolerancePercent | 边缘，轻度偏离 |
| **deviation** | 手牌 > tolerancePercent | 明显偏离 |

### 衰减权重窗口

取最近 8 手牌（最少 5 手），按从新到旧赋权重：

```
位置:   1(最新)  2     3     4     5     6     7     8(最老)
权重:   1.00   0.85  0.72  0.60  0.50  0.40  0.32  0.25
```

### Risk Score (风险分)

每手牌计算 `riskContribution`，乘以位置权重：

| 条件 | 分数 | 归类 | 说明 |
|---|---|---|---|
| VPIP | +1 | behavior | 只要入池就 +1 |
| Edge 范围手牌 | +1 | behavior | VPIP 且 baseline~tolerance |
| Deviation 手牌 | +2 | behavior | VPIP 且超出 tolerance |
| 单手亏损 ≥30BB | +2 | loss | 与 ≥80BB 不叠加 |
| 单手亏损 ≥80BB | +3 | loss | 取高值 |
| Bad Beat 情绪 | +2 | loss | 5 手情绪窗口 |
| Cooler 情绪 | +2 | loss | 5 手情绪窗口 |
| Tilt 情绪 | +4 | behavior | 5 手情绪窗口 |

**全局加分**：连续 VPIP ≥ trigger → +2（不乘权重）。trigger 值：HU=5, 6max=4, 9max/FR=3。

**纯 VPIP 封顶**：无 deviation/loss/emotion → weightedRisk 上限 4.0。

**归类用途**：`lossPoints` vs `behaviorPoints` 决定提醒文案是 Loss Tilt 还是 Tech Tilt。

### Recovery Score (恢复分)

| 条件 | 分数 | 前提 |
|---|---|---|
| fold | +1.0 | 正常行为 |
| VPIP in baseline/tolerance | +1.25 | 正常行为 |
| 连续 2 手正常 | 额外 +0.5 | |
| 无情绪信号 | +0.25 | |

**有效性**：最近 2 手至少 1 手 normal，否则 recovery = 0。

### Net Score

```
netScore = weightedRisk - weightedRecovery
```

---

## 4 状态机

```swift
enum TiltPhase {
    case normal       // 正常
    case watch        // 观察 — 偏了但没失控
    case tilt         // 上头 — 明显脱离 baseline
    case recovering   // 恢复中 — 正在回稳
}
```

### 转换规则

```
Normal ──(netScore ≥ watch)──→ Watch
Watch  ──(netScore ≥ tilt OR 3手内2次deviation, 且最新手非修正)──→ Tilt
Watch  ──(netScore < watch)──→ Normal
Tilt   ──(netScore < tilt AND 最近2手normal AND recovery上升)──→ Recovering
Recovering ──(netScore < watch AND 4手中≥3手normal)──→ Normal
Recovering ──(新deviation)──→ Watch/Tilt（按netScore判断）
```

### 修正保护

Watch → Tilt 升级被**阻止**当 `latestHandIsCorrection = true`。

判定条件（**全部满足**）：
1. `isNormalBehavior(hand)` = true
2. 无任何情绪信号
3. 无大亏损（bbResult > -30）

确保用户"开始纠正"时不被系统判更严重。

### 阈值

| | Cash | Cash (friendly) | Tournament |
|---|---|---|---|
| watchThreshold | 4.0 | 4.0 | 3.0 |
| tiltThreshold | 6.0 | 7.0 | 5.0 |

---

## 提醒系统

### 优先级

```
① Big Pot Alert（独立事件，最高优先）
② Phase-based Alert（状态驱动，含正向反馈）
③ 无 banner
```

### Phase-based 文案矩阵

#### Normal 状态

| 场景 | 显示 |
|---|---|
| 正常 | 无 banner |
| 刚从 elevated 降回 + 最新是 fold | **回到正轨** · 保持纪律（一次性） |

#### Watch 状态

| 场景 | headline | detail |
|---|---|---|
| 默认（loss 主导） | Loss Tilt | 连输后入池率上升，注意接下来几手 |
| 默认（behavior 主导） | Tech Tilt | 范围开始偏移，保持警觉 |
| 最新手是 **fold correction** | **好弃牌** | 这一手收住了 |
| 最新手是 **VPIP correction** | (保留主状态标题) | 风险仍高，但这一手是正确修正，继续保持 |

#### Tilt 状态

| 场景 | headline | detail |
|---|---|---|
| 默认（loss 主导） | Loss Tilt | danger 级别文案 |
| 默认（behavior 主导） | Tech Tilt | danger 级别文案 |
| 最新手是 **fold correction** | **纪律弃牌** | 先稳住 |
| 最新手是 **VPIP correction** | (保留主状态标题) | 风险仍然很高，但这手打得对。一手一手来 |

#### Recovering 状态

| 场景 | headline | detail |
|---|---|---|
| 默认 | 恢复中 | 恢复观察中 · 保持纪律 |
| 最新手是 **fold correction** | **恢复进行中** | 继续保持 |
| 最新手是 **VPIP correction** | **恢复进行中** | 继续按范围打 |

### 正向反馈设计原则

- **奖励决策不奖励结果** — 只看手牌是否在范围内，不看输赢
- **文案分层** — 每个状态有独立的 fold / VPIP 修正文案，体现状态差异
- **不改变算法** — 纯 UI 文案替换，`latestHandIsCorrection` 判定逻辑不变
- **轻量低打扰** — 通过现有 coach message 系统展示，不额外弹窗

---

## Big Pot 告警（独立）

- 触发：最新手 VPIP 且 |bbResult| ≥ 100BB
- 分级：Large (100-149), Huge (150-249), Massive (≥250)
- 按 强/弱牌 × 赢/输 × 底池大小 = 12 种场景，各有独立文案
- Big Pot banner 优先于 phase-based banner
- Big Pot 的亏损同时计入 Risk Score（≥30BB/≥80BB 加分规则）

---

## 情绪信号

| 信号 | Risk 贡献 | 归类 | 窗口 | UI 标签 |
|---|---|---|---|---|
| Bad Beat | +2 | loss | 5 手 | 轻度信号 |
| Cooler | +2 | loss | 5 手 | 中度信号 |
| Tilt | +4 | behavior | 5 手 | 强信号 |

### 交互设计

- **全部需确认弹窗** — 告知用户每个选项的系统影响
- **3 秒内可撤销** — Undo banner + haptic 反馈 + 确认提示
- **手牌历史可见** — 彩色标签显示在 row 中（Bad Beat=琥珀, Cooler=灰, Tilt=红）

---

## UI 状态映射

| Phase | GlowStatus | 颜色 | banner |
|---|---|---|---|
| Normal | .normal | 无 | 仅一次性正向反馈（刚降回时） |
| Watch | .warning | 黄色 | 警告 + 正向修正（当最新手是 correction） |
| Tilt | .danger | 红色 | 危险 + 正向修正（当最新手是 correction） |
| Recovering | .recovering | 青色 (teal) | 恢复观察 + 正向修正 |

---

## Normal 行为判定

`isNormalBehavior(hand)` 条件：

| 手牌类型 | 条件 |
|---|---|
| fold | 无 tilt 情绪信号 |
| VPIP | 手牌分类非 deviation + 亏损未超 30BB + 无 tilt 情绪 |

`latestHandIsCorrection` 在此基础上**额外要求**：
- 无任何情绪信号（`emotionSignal == nil`）
- 无大亏损（`bbResult > -30`）

---

## 冷静期（简化）

V6 不再使用硬性手牌倒计时。状态机自然驱动恢复流程：
- 进入 Tilt → danger banner
- 进入 Recovering → 恢复观察提示 + 正向反馈
- 回到 Normal → banner 消失（首手 fold 显示一次性"回到正轨"）
