# CLAUDE.md - Project Instructions

## 语言设置
- 默认使用中文与用户交流
- 代码注释可以使用英文
- 文档根据需要使用中英文

## 项目概述

**VPCT (VPIP Controller)** 是一个 iOS 扑克行为分析应用，主要功能：
- 实时追踪 VPIP（主动入池率）
- 事件驱动 Tilt 检测（4 个独立检测器）
- 冷静期升级系统（观察窗口 → 冷静倒计时）
- 中英文本地化
- Guest 模式（无需登录即可使用）

## 技术栈

- **UI 框架**: SwiftUI
- **架构**: @Observable + DataService (centralized state)
- **本地存储**: SwiftData
- **认证**: Sign in with Apple (planned)
- **本地化**: In-app L10n enum (not .strings files)

## 项目结构

```
TiltGuard/
├── TiltGuard/
│   ├── App/                 # App 入口 (TiltGuardApp.swift)
│   ├── Models/              # SwiftData 模型
│   │   ├── PlayerData.swift
│   │   ├── SessionData.swift
│   │   ├── HandRecordData.swift
│   │   ├── TiltCoachMessage.swift
│   │   └── ...
│   ├── Views/               # SwiftUI 视图
│   │   ├── MainTabView.swift     # 4-Tab 主容器
│   │   ├── HomeView.swift        # 首页
│   │   ├── SessionView.swift     # 牌局 (含冷静期UI)
│   │   ├── StatsView.swift       # 统计 (含guest锁定)
│   │   ├── SettingsView.swift    # 设置
│   │   ├── VPIPInputView.swift   # 手牌输入
│   │   ├── SessionSummaryView.swift
│   │   ├── SessionDetailView.swift
│   │   ├── AllSessionsView.swift
│   │   └── Settings sub-views...
│   ├── Services/            # 业务逻辑
│   │   ├── DataService.swift     # 核心数据服务 (session, tilt, cooldown)
│   │   ├── L10n.swift           # 中英文本地化
│   │   ├── LanguageManager.swift
│   │   └── AppearanceManager.swift
│   ├── Components/          # 可复用组件
│   └── Extensions/          # Color, 工具扩展
├── docs/
│   ├── MVP_IMPLEMENTATION.md    # 功能实现文档 (v2.0)
│   ├── PRO_ROADMAP.md          # Pro 功能规划
│   └── design/
│       ├── UI_DESIGN_v1.6.md   # 当前版本
│       └── _archived/          # 历史版本备份
└── CLAUDE.md
```

## 核心架构

### DataService (集中式状态管理)
- `@Observable` class，注入为 `.environment()`
- 管理: Player, Session, HandRecords
- Tilt 检测: 4 个独立检测器 (lossChase, styleDrift, winTilt, vpipDrift)
- 冷静期: TiltPhase 状态机 (normal → observing → cooldown)
- Guest 模式: 不累积 lifetime 统计，app 重启清除历史

### Tilt Detection → Cooldown Escalation
```
正常 → 检测器触发提醒 → 观察 5 手 → 行为未改善 → 冷静期 10 手
                                    → 行为改善 → 恢复正常

冷静期触发类型 (CooldownTrigger):
- lossBased: 追损/逆风, 退出检查含 loss 信号, +5 手延长
- winBased:  顺风膨胀, 退出不检查 loss 信号, +3 手延长 (更温和)
- driftBased: 一般漂移, 同 lossBased
```

### L10n 本地化
- `L10n.s(.key, lang)` 模式
- 80+ keys，覆盖所有 UI 文字
- App 名称 "VPCT" / "VPIP CONTROLLER" 不翻译

## 核心模型

### PlayerData
- id, createdAt, lifetimeHands, lifetimeVPIPHands

### SessionData
- id, startTime, endTime, totalHands, vpipHands, totalBBResult
- `@Relationship(deleteRule: .cascade)` handRecords

### HandRecordData
- id, timestamp, didVPIP, card1Rank, card2Rank, isSuited
- resultRaw, bbResult
- **Pro 预留**: positionRaw, actionTypeRaw

## 开发规范

### 命名规范
- 类名：大驼峰 `PlayerData`
- 变量名：小驼峰 `sessionVPIP`
- L10n Key：小驼峰 `tiltLossChaseH`

### Git 提交规范
- `feat:` 新功能
- `fix:` 修复 bug
- `docs:` 文档更新
- `refactor:` 代码重构
- `style:` 代码格式化

## 当前开发阶段

**Phase 1: MVP 基本完成**

已实现:
- ✅ Session 系统 (start, end, delete)
- ✅ 手牌记录 (fold + VPIP, 左滑删除)
- ✅ VPIP 计算 (session, 30min rolling, lifetime)
- ✅ 4 检测器 Tilt 检测
- ✅ 冷静期升级系统 (trigger-specific)
- ✅ 中英文本地化
- ✅ Guest 模式
- ✅ 设置页 (外观/语言/功能开关)

待实现:
- 🔲 Sign in with Apple
- 🔲 数据云同步
- 🔲 App Store 上架

## UI 设计规范

### 设计文档位置
```
docs/design/
├── UI_DESIGN_v1.6.md          # 当前版本 (冷静期 + 本地化)
└── _archived/                  # 历史版本备份
    ├── UI_DESIGN_v0.9.md ~ v1.5.md
```

### UI 变更规则
1. **任何 UI 设计变更必须先与用户商量确认**
2. 变更前先备份当前版本到 `_archived/` 目录
3. 新版本递增版本号
4. 在文档末尾「版本历史」中记录变更内容

### 当前设计要点 (v1.6)
- **4 个 Tab**: VT(首页), Live(牌局), Stats(统计), Me(设置)
- **品牌**: VPCT + 紫色竖条标识，不翻译
- **Hero 区域**: 状态机驱动 (6 种状态)
- **冷静期 UI**: 进度环倒计时，类似预热
- **颜色统一**: WIN=品牌紫, LOSS=secondary
- **无 Pro UI**: 数据库预留，但 UI 不显示锁定功能
- **输入流程**: ≤ 4 次点击完成
- **删除功能**: 手牌长按删除，session 长按删除，自动重算统计

## 注意事项

- Pro 功能字段已在数据库预留，但 MVP 阶段不实现
- Tilt 检测 + 冷静期是核心卖点，需要重点打磨
- 保持 UI 简洁，输入要极简
- **UI 是项目的重要卖点，设计需要精心打磨**
