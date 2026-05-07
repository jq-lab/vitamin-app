# Vitora Final Manual QA Checklist

> 日期：2026-05-07  
> 设备：iPhone 17 Simulator  
> 来源：`specs/004-vitora-swift-rebuild/interaction-acceptance.md`  
> 范围：`IAC-QA-001` 到 `IAC-QA-015`

## 结果总览

| ID | 场景 | 检查结果 | 证据 |
| --- | --- | --- | --- |
| IAC-QA-001 | 新装打开，跳过 HealthKit。 | Pass | `OnboardingLowDataUITests.testSkipHealthKitEntersLowDataToday`；`Screenshots/Final/01-onboarding.png`；`quickstart-results.md`。 |
| IAC-QA-002 | Today 首屏丰富数据。 | Pass | `TodayPivotUITests.testTodayUsesStateFactorsSuggestionWithoutStandaloneRecordSection`；`Screenshots/Final/02-today-home.png`。 |
| IAC-QA-003 | Today 顶部下拉。 | Pass | `AccessibilityUITests.testReduceMotionAndTransparencyPathKeepsCoreInteractionsAvailable`；`iosef swipe`；`Screenshots/Final/03-energy-reveal.png`。 |
| IAC-QA-004 | 点击 Today 状态卡。 | Pass | `AccessibilityUITests.testDynamicTypeKeepsMainNavigationInputAndSheetsUsable`；`Screenshots/Final/05-contextual-vitora-sheet.png` 的背景状态详情。 |
| IAC-QA-005 | 长按 Today 状态卡。 | Pass | `AskableSurfaceUITests` 覆盖 long-press/context menu；最终反向验收确认长按不是唯一入口。 |
| IAC-QA-006 | 点击校准 chip。 | Pass | `ContextualVitoraSheetUITests.testTodayCalibrationOpensContextualSheetAndUnderstandingState`；`Screenshots/Final/05-contextual-vitora-sheet.png`。 |
| IAC-QA-007 | 进入 Vitora Tab。 | Pass | `VitoraAssistantSurfaceUITests.testVitoraTabIsAssistantSurfaceNotEmptyChat`；`Screenshots/Final/04-vitora-tab.png`。 |
| IAC-QA-008 | Vitora 输入文字。 | Pass | `ContextualVitoraSheetUITests` 输入“昨晚醒了两次”后出现 `Vitora 理解为`。 |
| IAC-QA-009 | Vitora 语音入口。 | Pass | `AccessibilityUITests` 验证 `vitora.input.voice` 可访问、44pt 命中区、label 为“语音记录”；P0 保留语音入口，不实现真实语音转写。 |
| IAC-QA-010 | Cycle 首页。 | Pass | `CyclePivotUITests.testCycleHomeIsLongHorizonRhythmAndEnergyDynamics`；`Screenshots/Final/06-cycle-home.png`。 |
| IAC-QA-011 | Cycle 能量二层点曲线点。 | Pass | `CyclePivotUITests.testCycleEnergyDetailShowsTrendExploration`；pivot QA 截图 `Screenshots/Pivot/09-cycle-energy-callout.png`。 |
| IAC-QA-012 | Today 顶部日历。 | Pass | `TodayPivotUITests.testTodayCalendarIsTopEntry`；pivot QA 截图 `Screenshots/Pivot/02-today-calendar-sheet.png`。 |
| IAC-QA-013 | 晚间复盘。 | Pass | `EveningReviewUITests.testEveningReviewShowsBeforeAfterFeedbackAndLearningSignal`；`Screenshots/Final/08-evening-review.png`。 |
| IAC-QA-014 | 设置入口。 | Pass | `SettingsPanelUITests.testSettingsPanelShowsOnlyP0SupportItemsAndChildPanels`；`Screenshots/Final/07-support-settings.png`。 |
| IAC-QA-015 | Accessibility。 | Pass | `AccessibilityUITests` 覆盖触控区域、Dynamic Type、Reduce Motion / Reduce Transparency 核心路径。 |

## 人工观察结论

- Today 首页保持 `现在状态 → 身体要素 → Vitora 今日建议`，没有独立记录区。
- Energy Ball 通过下拉显示，不是常驻首屏大英雄组件。
- Vitora Tab 是 assistant surface，不是空白聊天页，也不是普通 dashboard。
- Contextual Vitora sheet 从 Today 状态上下文打开，没有切走 Tab。
- Cycle 首页只显示阶段关系和能量动态，不承担日历首页。
- 设置入口只出现 P0 支撑项，没有 VIP、主题、小组件、帮助墙或养成入口。

## 残余风险

- Pixel Vitora 与 glass/aura 视觉已按当前 Swift 能力实现，但最终商业级视觉仍需要继续和 Figma/用户截图做逐轮微调。
- P0 语音入口目前是交互占位和状态入口，不包含真实录音、转写和语音理解。
- 代码中仍保留部分 internal `Luna*` 命名作为 migration debt；用户面对文案与新规格使用 Vitora。
