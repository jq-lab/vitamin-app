# Implementation Plan: Vitora Swift Rebuild P0

> 分支：`004-vitora-swift-rebuild`
> 日期：2026-05-07
> 状态：P0 Swift MVP Final QA Passed
> 输入规格：`specs/004-vitora-swift-rebuild/spec.md`

本文档是 SpecKit Pro `/speckit.analyze` 与 `/speckit.implement` 的技术计划输入。当前项目已经完成 `T001-T177`，包括 IA / Design Pivot Adaptation、Evening Review、Support、Trust hardening 和 Final QA。后续新功能必须先更新 specs/tasks，再进入 analyze/implement。

## 1. Summary

Vitora P0 Swift rebuild 要交付一个原生 iOS 身体节律陪伴 app：

- Today：`现在状态 → 身体要素 → Vitora 今日建议`。
- Vitora：AI-native assistant surface，不是空聊天页。
- Cycle：`当前周期阶段与今天 + 能量动态`。
- 记录：不再是独立打卡区，变成“告诉 Vitora 一件重要变化”。
- AI：Vitora 是全局 Assistant Layer，可从对象级 contextual sheet 被唤醒。
- 视觉：`弥散渐变背景 + 清透拟态玻璃组件 + Pixel Vitora 陪伴体`。

当前已完成 Swift 基础设施、领域服务、Onboarding、Today、Vitora assistant、Cycle、Evening Review、Support、Trust hardening 和 Final QA。旧 `Luna*` 内部命名只作为 migration debt 保留，用户面对文案和新规格均使用 Vitora。

## 2. Technical Context

| 项 | 决策 |
| --- | --- |
| Platform | 原生 iOS Swift / SwiftUI。 |
| Source root | `ios/`。 |
| Main tabs | `Today / Vitora / Cycle`。 |
| Legacy naming | 旧代码中的 `Luna*` 可暂存为 migration debt；用户面对文案、新组件、新 specs 使用 `Vitora`。 |
| Persistence | 保留现有加密持久化 / repository 方向。 |
| HealthKit | 可选增强；跳过/拒绝后 app 可用。 |
| AI | AI adapter 继续隔离；后续 local Gemma / agentic usage 不在 P0，但边界不能封死。 |
| QA | XCTest、XCUITest、Simulator/iosef、截图人工检查。 |
| Visual system | Aura Glass Pixel Companion，由 `design-tokens.md` 和 `components.md` 驱动。 |

## 3. Authority Inputs

| 优先级 | 文件 | 计划用途 |
| --- | --- | --- |
| 1 | `facts.md` | 产品事实、范围、用户面对命名。 |
| 2 | `spec.md` | `REQ-*` 行为和验收。 |
| 3 | `userflows.md` | P0 用户路径。 |
| 4 | `ia.md` | 路由、屏幕、二层 IA。 |
| 5 | `wireframes.md` | 正式线框与动态。 |
| 6 | `design-language-demo.md` | 视觉 high-rule evidence。 |
| 7 | `design-tokens.md` | `vt.*` tokens。 |
| 8 | `components.md` | `C-*` 组件。 |
| 9 | `interaction-acceptance.md` | `IAC-*` 验收门。 |
| 10 | `data-model.md`, `contracts/`, `data-privacy-ai-boundaries.md`, `compliance.md` | 数据、AI、隐私、合规约束。 |
| 11 | `wireframes-walkthrough-demo.md` | IA pivot evidence，不直接作为任务。 |

## 4. Constitution Check

| 门禁 | 状态 | 计划处理 |
| --- | --- | --- |
| 三主区 | Pass | 只实现 Today / Vitora / Cycle。 |
| Vitora 命名 | Pass with migration debt | 用户面对 Luna 已迁移到 Vitora；internal `Luna*` 可暂存。 |
| Today 心智 | Pass | Today 为状态/要素/建议对象级校准，无独立记录区。 |
| Vitora Tab | Pass | 已改为 assistant surface。 |
| Cycle 心智 | Pass | Cycle 首页为阶段关系 + 能量动态，无日历首页。 |
| 视觉系统 | Pass with visual polish debt | 已使用 Aura Glass / Pixel Vitora；商业级视觉仍需后续微调。 |
| 隐私 / 合规 | Pass with continued checks | 继续使用现有 privacy / AI boundary。 |
| 已完成代码 | Pass | T001-T177 已完成，保留 migration debt 说明。 |

## 5. Project Structure

```text
ios/
├── Vitora.xcodeproj
├── Vitora/
│   ├── App/
│   ├── Core/
│   │   ├── DesignSystem/
│   │   ├── Navigation/
│   │   ├── Persistence/
│   │   ├── Privacy/
│   │   ├── Logging/
│   │   └── AI/
│   ├── Domains/
│   │   ├── Onboarding/
│   │   ├── Today/
│   │   ├── Vitora/          # target naming;旧 Luna 可迁移
│   │   ├── Cycle/
│   │   ├── Support/
│   │   └── Review/
│   ├── Features/
│   │   ├── OnboardingFeature/
│   │   ├── TodayFeature/
│   │   ├── VitoraFeature/   # target naming;旧 LunaFeature 可迁移
│   │   ├── CycleFeature/
│   │   └── SupportFeature/
│   └── Resources/
├── VitoraTests/
└── VitoraUITests/
```

迁移策略：不要求一次性重命名所有旧文件路径；但新任务不得新增用户面对 `Luna` 文案或新 `Luna*` 组件。若暂时保留 `Domains/Luna` 或 `Features/LunaFeature`，必须在 adaptation tasks 中记录为 migration debt。

## 6. Architecture Adjustments

### 6.1 Navigation

`AppRouter` 必须适配：

- Primary tabs: Today / Vitora / Cycle。
- Contextual presentation: `VitoraContextualSheet`。
- Upgrade state: `VitoraFullContextMode`。
- Today sheets: calendar、state detail、body factors、suggestion detail、Energy Reveal。
- Cycle sheets: phase detail、energy dynamics detail。
- Support panel: profile/settings from Cycle avatar and Vitora `⋯`。

### 6.2 Design System

`Core/DesignSystem` 必须从旧 flat tokens 改为：

- `AuraBackground`
- `GlassSurface` with G0-G4 material levels
- `PixelVitoraView`
- `VitoraFaceTabButton`
- `AskableSurface`
- `CalloutBubble`
- `VitoraInputDock`

### 6.3 Today

旧 `TodayStateOrb` / `TodaySignalCard` / `TodayAnalysisSheet` 需要重组为：

- `TodayStatusCard`
- `RhythmCurve`
- `CalibrationChips`
- `BodyFactorTiles`
- `VitoraDailySuggestionCard`
- `EnergyBowlRealtimePrediction`
- `TodayCalendarSheet`

### 6.4 Vitora

旧 `LunaHome` / `LunaRecord` / `LunaImmersiveChat` 需要重组为：

- `PixelVitoraHero`
- `VitoraKnowsPanel`
- `AssistantMessageBubble`
- `DirectQuestionStrips`
- `QuickContextChips`
- `VitoraInputDock`
- `VitoraContextualSheet`
- `UnderstandingConfirmSheet`
- `VitoraFullContextMode`

### 6.5 Cycle

旧 Cycle 基础概览 / 日历首页需要重组为：

- `CurrentPhaseRelationCard`
- `EnergyDynamicsCard`
- `CurrentPhaseDetailSheet`
- `EnergyDynamicsDetailSheet`
- `CycleSettingsEntry`

日历移到 Today 顶部入口。

## 7. 阶段计划

| 阶段 | 状态 | 目标 |
| --- | --- | --- |
| Phase 1 Setup | 已完成 T001-T008 | 工程壳。 |
| Phase 2 Foundation | 已完成 T009-T036 | Core / domain / persistence / AI shell。 |
| Phase 3 Onboarding | 已完成 T037-T049 | 无 WeChat / HealthKit optional。 |
| Phase 4 Old Today | pivot 前已完成 T050-T064 | 保留服务，UI 需 adaptation。 |
| Phase 5 Old A/B | pivot 前已完成 T065-T076 | 保留意图/提醒能力，UI 需接新建议卡。 |
| Phase 6 Old Luna Record | pivot 前已完成 T077-T093 | 保留记录/理解能力，UI 和命名需 adaptation。 |
| Phase 7 Old Luna Chat | pivot 前已完成 T094-T101 | 保留聊天能力，心智需改为 Vitora surface。 |
| Phase 8 Pivot Baseline Tests | 已完成 T102-T108 | 新 IA / 视觉系统自动化验收。 |
| Phase 9 Design System Pivot | 已完成 T109-T113 | AuraBackground、GlassSurface、PixelVitoraView、InputDock。 |
| Phase 10 App Shell / Naming Pivot | 已完成 T114-T116 | 主 Tab、presentation、用户面对 Vitora 命名迁移。 |
| Phase 11 Today Pivot | 已完成 T117-T123 + D-041 adaptation | Today 收口为状态、身体要素、Vitora 今日建议和 Energy Bowl 实时预测。 |
| Phase 12 Vitora Assistant Pivot | 已完成 T124-T130 | 旧 Luna surface 重构为完整 Vitora assistant surface。 |
| Phase 13 Cycle Pivot | 已完成 T131-T135 | Cycle 收口为周期阶段与今天、能量动态、设置入口。 |
| Phase 14 Pivot QA Gate | 已完成 T136-T138 | Simulator/iosef、截图、设计证据偏差报告。 |
| Phase 15 Evening Review | 已完成 T139-T145 | 基于 Energy Ball review 和当日意图。 |
| Phase 16 Support / Trust | 已完成 T146-T161 | 设置、数据、营养、提醒、导出、隐私。 |
| Phase 17 Privacy / AI / Compliance Hardening | 已完成 T162-T169 | AI 输出、日志、低数据、合规扫描。 |
| Phase 18 Final QA | 已完成 T170-T177 | simulator、截图、可访问性、性能、视觉验收。 |

## 8. 下一实现门禁

在继续新增 scope 的 `/speckit.implement` 前必须：

1. 新 scope 已写入正式 specs，并同步新增 tasks。
2. `/speckit.analyze` 通过或 findings 已修复。
3. `design-tokens.md`、`components.md`、`wireframes.md`、`interaction-acceptance.md` 仍与 demo docs 一致。
4. quickstart / handoff 说明当前 `T001-T177` 已完成，不回到旧 T102。

## 9. Traceability Matrix

| 区域 | 正式来源 | 实现目标 |
| --- | --- | --- |
| Today home | REQ-004, WF-T-001, C-TODAY-003 to 007 | `TodayFeature` refactor |
| Energy Bowl / 实时预测 | REQ-005, WF-T-002, C-TODAY-008 | `TodayStatusCard` / `EnergyBowlView` |
| Contextual Vitora | REQ-008, WF-V-005, C-VITORA-010 | Global sheet/router |
| Vitora Tab | REQ-010, WF-V-001 to 004, C-VITORA-001 to 009 | `VitoraFeature` |
| Record confirm | REQ-011, WF-V-004, C-VITORA-012 | Record service + UI |
| Cycle | REQ-012, WF-C-001 to 003, C-CYCLE-* | `CycleFeature` refactor |
| Support | REQ-014, WF-S-001, C-SUPPORT-* | `SupportFeature` |
| Visual system | REQ-016, `design-tokens.md` | `Core/DesignSystem` |
| Design evidence | `design-language-demo.md`, `assets/design_04/today_tab.png`, `assets/design_04/vitora_tab.png`, `assets/design_04/cycle_d.png` | screenshot comparison and `ios/QA/pivot-adaptation-report.md` |
| QA | `interaction-acceptance.md` | XCUITest + manual QA |

## 10. Validation Checklist

- No formal P0 plan continues old `T102` first.
- 新 UI 任务不得引入用户面对的 Luna。
- No Cycle implementation task puts calendar on Cycle home.
- No Today task adds standalone record section.
- Vitora input dock avoidance is explicit.
- Pixel Vitora IP is part of design system and tab CTA.
- Every new UI task cites `WF-*`, `C-*`, `vt.*`, and `IAC-*`.
- Today / Vitora / Cycle first-level screenshots are compared against `assets/design_04/` evidence and `design-language-demo.md`.
