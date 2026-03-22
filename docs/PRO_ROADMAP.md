# TiltGuard Pro – Feature Roadmap

> 专业版功能规划（预留框架，后续更新）

---

## Pro 版本定位

**目标用户**: 认真对待扑克、追求长期盈利的玩家

**核心价值**: 深度数据分析 + GTO 对比 + 高级报告

---

## Pro 功能列表

### 1. BB 输赢记录

**功能描述**: 记录每手牌的大盲注输赢

**用户输入**:
```
+5bb    (赢了 5 个大盲)
-10bb   (输了 10 个大盲)
```

**数据分析**:
| 指标 | 说明 |
|------|------|
| Session BB +/- | 本场盈亏 |
| Big Pot Wins | 大池胜率 |
| Big Pot Losses | 大池亏损频率 |
| BB/100 | 每百手盈利 |

**数据库字段**:
```swift
bbResult: Double?  // 预留字段，已在 HandRecord 中
```

---

### 2. 位置记录

**功能描述**: 记录每手牌的位置信息

**位置选项**:
| 位置 | 缩写 | 说明 |
|------|------|------|
| Under The Gun | UTG | 枪口位 |
| Middle Position | MP | 中间位 |
| Cut Off | CO | 关煞位 |
| Button | BTN | 庄家位 |
| Small Blind | SB | 小盲位 |
| Big Blind | BB | 大盲位 |

**分析功能**:
- 各位置 VPIP 统计
- 位置盈利分析
- 位置漏洞识别

**数据库字段**:
```swift
position: String?  // 预留字段，已在 HandRecord 中
```

---

### 3. 入池方式记录

**功能描述**: 记录入池的具体行为

**行为选项**:
| 行为 | 说明 |
|------|------|
| Limp | 平跟入池 |
| Call | 跟注入池 |
| Raise | 加注入池 |
| 3bet | 三次下注 |

**分析功能**:
- Limp 频率警告
- 3bet 范围分析
- 加注尺度建议

**数据库字段**:
```swift
actionType: String?  // 预留字段，已在 HandRecord 中
```

---

### 4. GTO 范围对比

**功能描述**: 将玩家实际范围与 GTO 范围对比

**对比逻辑**:
```
玩家实际范围 (Player Range)
        vs
GTO 推荐范围 (GTO Range)
```

**警告示例**:
```
⚠️ Range Deviation
You overplay KTo in UTG position.
GTO suggests folding this hand.
```

**需要的数据**:
- 内置 GTO 范围表（按位置）
- 玩家历史手牌数据
- 偏差计算引擎

---

### 5. 高级报告

#### 5.1 位置 VPIP 报告
```
Position VPIP Analysis
──────────────────────
UTG:  12%  ✓ Optimal
MP:   15%  ✓ Optimal
CO:   22%  ✓ Optimal
BTN:  35%  ⚠️ Too Loose
SB:   28%  ✓ Optimal
BB:   18%  ✓ Optimal
```

#### 5.2 手牌 EV 分析
```
Hand EV Report
──────────────
Best Performers:
  AA   +45bb/100
  KK   +38bb/100
  AKs  +22bb/100

Worst Performers:
  KJo  -12bb/100  ⚠️
  QTo  -8bb/100   ⚠️
  J9s  -5bb/100
```

#### 5.3 Tilt 频率分析
```
Tilt Analysis (Last 30 Days)
────────────────────────────
Tilt Sessions:    4 / 20 (20%)
Avg Tilt Duration: 45 min
Tilt Triggers:
  - Post bad beat: 60%
  - Long session:  25%
  - Late night:    15%
```

#### 5.4 疲劳检测
```
Fatigue Detection
─────────────────
Session Length:  4h 30m
VPIP Trend:      ↗️ Increasing
Decision Time:   ↘️ Decreasing
Recommendation:  Take a 15-min break
```

---

## 数据库完整设计

### Player 表
```swift
@Model
class Player {
    @Attribute(.unique) var playerId: UUID
    var email: String
    var createdAt: Date

    // 终身统计
    var lifetimeHands: Int
    var lifetimeVPIPHands: Int
    var lifetimeVPIP: Double

    // 关系
    var sessions: [Session]
}
```

### Session 表
```swift
@Model
class Session {
    @Attribute(.unique) var sessionId: UUID
    var playerId: UUID

    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval

    var totalHands: Int
    var vpipHands: Int
    var sessionVPIP: Double

    // Pro 预留
    var totalBBResult: Double?

    // 关系
    var handRecords: [HandRecord]
    var player: Player?
}
```

### HandRecord 表
```swift
@Model
class HandRecord {
    @Attribute(.unique) var handId: UUID
    var sessionId: UUID
    var timestamp: Date

    // MVP 字段
    var didVPIP: Bool
    var card1Rank: String?
    var card2Rank: String?
    var suited: Bool?
    var handType: String?
    var result: String?  // WIN / NOT_WIN

    // Pro 预留字段 ⭐
    var bbResult: Double?
    var position: String?
    var actionType: String?
    var potSize: Double?

    // 关系
    var session: Session?
}
```

### HandStatistics 表（长期分析）
```swift
@Model
class HandStatistics {
    @Attribute(.unique) var handType: String  // e.g., "AKs"
    var playerId: UUID

    var totalPlays: Int
    var wins: Int
    var losses: Int
    var winRate: Double

    // Pro 预留
    var totalBBWon: Double?
    var evPerHand: Double?
}
```

---

## Pro 功能开发优先级

| 优先级 | 功能 | 复杂度 | 价值 |
|--------|------|--------|------|
| P1 | BB 输赢记录 | 低 | 高 |
| P1 | 位置记录 | 低 | 高 |
| P2 | 入池方式记录 | 低 | 中 |
| P2 | 位置 VPIP 报告 | 中 | 高 |
| P3 | GTO 范围对比 | 高 | 高 |
| P3 | 手牌 EV 分析 | 中 | 中 |
| P4 | Tilt 频率分析 | 中 | 中 |
| P4 | 疲劳检测 | 高 | 中 |

---

## Pro 商业模式

### 订阅方案（建议）
| 方案 | 价格 | 功能 |
|------|------|------|
| Basic | 免费 | MVP 全部功能 |
| Pro Monthly | $4.99/月 | 全部 Pro 功能 |
| Pro Annual | $29.99/年 | 全部 Pro 功能 + 优先支持 |

### 功能门控
```swift
enum SubscriptionTier {
    case basic
    case pro
}

func canAccessFeature(_ feature: ProFeature) -> Bool {
    switch feature {
    case .bbTracking, .positionTracking:
        return subscription == .pro
    case .gtoComparison, .advancedReports:
        return subscription == .pro
    default:
        return true
    }
}
```

---

## 未来愿景

### Phase 4: AI Coach
- 个性化建议引擎
- 实时策略提示
- 漏洞自动识别

### Phase 5: 社区功能
- 匿名数据对比
- 排行榜系统
- 学习小组

### Phase 6: 多平台
- iPad 优化版本
- Apple Watch 快速记录
- Mac 桌面分析工具

---

## 技术预留

### API 接口预留
```swift
protocol PokerAnalyticsAPI {
    // MVP
    func recordHand(_ hand: HandRecord) async throws
    func getSessionStats(_ sessionId: UUID) async throws -> SessionStats

    // Pro 预留
    func getPositionAnalysis(_ playerId: UUID) async throws -> PositionAnalysis
    func getGTOComparison(_ hand: HandRecord) async throws -> GTOResult
    func generateReport(_ type: ReportType) async throws -> Report
}
```

### 数据同步预留
```swift
// 未来 CloudKit 同步
protocol CloudSyncable {
    func sync() async throws
    func resolveConflict(_ local: Self, _ remote: Self) -> Self
}
```

---

## 重要提醒

> ⚠️ **MVP 阶段注意事项**
>
> 1. 数据库字段已预留，**不要删除** Pro 字段
> 2. UI 不要显示 Pro 功能入口
> 3. 代码架构要支持未来扩展
> 4. 用户数据从 Day 1 开始收集完整字段

---

*Document Version: 1.0*
*Last Updated: 2026-03-06*
