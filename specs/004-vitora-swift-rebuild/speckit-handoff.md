# Vitora Swift Rebuild · SpecKit Handoff

> 分支：`004-vitora-swift-rebuild`
> 功能目录：`specs/004-vitora-swift-rebuild/`
> 日期：2026-05-07
> 状态：P0 Swift MVP Final QA Passed

本文档告诉后续 SpecKit Pro / coding agent 如何接手当前项目。当前不是 clean-from-zero 状态：Swift P0 已完成到 `T177`，包含 IA / Design Pivot、Today、Vitora、Cycle、Evening Review、Support、Trust hardening 和 Final QA。后续不要从旧 `T102` 或旧 Luna IA 继续。

## 1. 当前状态

| 项目 | 状态 | 含义 |
| --- | --- | --- |
| 规格集 | pivot 后就绪 | `facts/spec/userflows/ia/wireframes/components/tokens/acceptance/plan/tasks` 已更新到新方向。 |
| Demo 文档 | 作为证据保留 | `wireframes-walkthrough-demo.md` 与 `design-language-demo.md` 保留，不直接作为任务。 |
| Swift 工作 | P0 已完成 | `T001-T177` 已完成；完整 suite 109 passed。 |
| 下一任务 | 无 P0 未完成任务 | 新功能或视觉微调必须先更新 specs/tasks。 |
| 推荐下一命令 | `/speckit.analyze` | 只在新增/调整 specs 后运行，确认一致性再 implement。 |

## 2. 规格权威顺序

后续 agent 必须按以下顺序读取：

1. `facts.md`
2. `spec.md`
3. `userflows.md`
4. `ia.md`
5. `wireframes.md`
6. `design-tokens.md`
7. `components.md`
8. `interaction-acceptance.md`
9. `plan.md`
10. `tasks.md`
11. `quickstart.md`
12. `compliance.md`
13. `data-privacy-ai-boundaries.md`
14. `data-model.md`
15. `contracts/`
16. `wireframes-walkthrough-demo.md` and `design-language-demo.md` only as evidence

如果任务涉及 Pixel Vitora 的造型、材质、表情、道具、动效或页面接入，必须先读取：

```text
pixel-vitora-ip/README.md
pixel-vitora-ip/pixel-vitora-ip-spec.md
pixel-vitora-ip/implementation-contract.md
pixel-vitora-ip/qa-checklist.md
```

如果任务涉及 Cycle 页面首页视觉、布局、图表、Tip、Tab 避让或页面内 Pixel Vitora 接入，必须先读取：

```text
cycle-page/README.md
cycle-page/cycle-page-spec.md
cycle-page/implementation-contract.md
cycle-page/qa-checklist.md
```

如果任务涉及 Vitora Tab assistant surface、Quick Context、Input Dock、周期上下文展开态或 Vitora 页面内 Pixel Vitora 接入，必须先读取：

```text
vitora-page/README.md
vitora-page/vitora-page-spec.md
vitora-page/implementation-contract.md
vitora-page/qa-checklist.md
```

如果任务涉及首层背景、动态 aura、周期色变化、视频背景素材或 Reduce Motion 背景兜底，必须先读取：

```text
dynamic-aura-background/README.md
dynamic-aura-background/dynamic-aura-background-spec.md
dynamic-aura-background/implementation-contract.md
dynamic-aura-background/qa-checklist.md
```

`spec_en.md` 不是当前默认产品真相。

## 3. 不要做的事

默认不要运行：

```text
/speckit.tasks
/speckit.specify
/speckit.userflows
/speckit.ia
/speckit.wireframes
/speckit.components
/speckit.plan
```

原因：

- `tasks.md` 已经保留 `T001-T177` 完成历史。
- `T102-T138` 是已完成的分段 pivot block，不能被覆盖回旧任务。
- 重跑 tasks 可能覆盖进度和人工拆解。只有在新 scope 已经明确写入 specs 后，才考虑生成新的 tasks。

## 4. 后续推荐流程

### 步骤 1 · 新需求先改 specs

新增功能、商业级视觉微调、真实语音记录、本地 LLM / agentic usage 等都必须先写入相关 specs，并同步 `tasks.md`。

### 步骤 2 · Analyze

```text
/speckit.analyze
```

必须重点检查：

- `tasks.md` 当前 `T001-T177` 完成；如果出现新任务，必须来自明确的新 specs。
- `plan.md` 与 `tasks.md` 不应把旧 Evening Review 或旧 Luna IA 当下一阶段。
- 用户面对 Luna 已被迁移为 Vitora 或标记为 internal migration debt。
- Today / Vitora / Cycle 新 IA 不被新任务破坏。
- Aura Glass Pixel Companion、Pixel Vitora、Today / Vitora / Cycle 首层 UI 仍对照 `assets/design_04/`。

### 步骤 3 · Implement

```text
/speckit.implement
```

如果新增了任务，实现从新的未完成任务开始；不要回到旧 `T102`。

## 5. Coding Agent Rules

后续 coding agent 必须遵守：

- 不恢复旧 RN / Expo。
- 不继续旧 `T102` Evening Review。
- 不新增用户面对 `Luna`。
- 不把 Today 做回记录 app。
- 不把 Vitora Tab 做成空聊天页或 dashboard。
- 不把 Cycle 首页做成日历。
- 不把 Pixel Vitora 替换成 smooth orb、人类头像、宠物或普通 icon。
- 涉及 Pixel Vitora 的改动必须继承 `pixel-vitora-ip/` 中的玻璃像素小球 baseline，并更新 `pixel-vitora-ip/change-log.md`。
- 涉及 Cycle 页面首页的改动必须继承 `cycle-page/` 中的当前 baseline，并更新 `cycle-page/change-log.md`。
- 涉及 Vitora Tab assistant surface 的改动必须继承 `vitora-page/` 中的当前 baseline，并更新 `vitora-page/change-log.md`。
- 涉及 Dynamic Aura Background 的改动必须继承 `dynamic-aura-background/` 中的视频素材和周期色规则，并更新 `dynamic-aura-background/change-log.md`。
- 每个 UI phase 结束必须用 simulator / iosef 交互检查，并保存截图。

## 6. QA Evidence

| Artifact | Path |
| --- | --- |
| Full test output | `ios/QA/Reports/xcodebuild-test.txt` |
| Final QA report | `ios/QA/final-qa-report.md` |
| Manual QA checklist | `ios/QA/manual-qa.md` |
| Design handoff spec | `specs/004-vitora-swift-rebuild/design-handoff.md` |
| Pixel Vitora IP spec pack | `specs/004-vitora-swift-rebuild/pixel-vitora-ip/` |
| Cycle page spec pack | `specs/004-vitora-swift-rebuild/cycle-page/` |
| Vitora Tab spec pack | `specs/004-vitora-swift-rebuild/vitora-page/` |
| Dynamic Aura Background spec pack | `specs/004-vitora-swift-rebuild/dynamic-aura-background/` |
| Design gap report | `ios/QA/design-handoff-gap-report.md` |
| Design comparison screenshots | `ios/QA/Screenshots/ComparisonV2/` |
| Quickstart result | `ios/QA/quickstart-results.md` |
| Reverse acceptance | `ios/QA/Reports/reverse-acceptance-scan.txt` |
| Final screenshots | `ios/QA/Screenshots/Final/` |

最近完整测试结果：

```text
109 passed
0 failed
0 skipped
Result bundle: /tmp/vitora-final-qa-20260507c.xcresult
```

## 7. Next Agent Prompt

可以这样启动下一轮：

```text
先读取 specs/004-vitora-swift-rebuild/speckit-handoff.md、facts.md、plan.md、tasks.md、quickstart.md。
当前 T001-T177 已完成。不要回到旧 T102。
如果要继续新功能或视觉微调，先更新 specs/tasks，再运行 /speckit.analyze。
通过 analyze 后，再从新的未完成任务执行 /speckit.implement。
每个 UI 阶段都要跑 simulator/iOS QA，并对照 wireframes.md、design-tokens.md、components.md、interaction-acceptance.md。
```

## 8. Handoff 完成定义

当前 handoff 完成后应满足：

- `tasks.md` 保留 T001-T177 已完成。
- 当前没有 P0 未完成任务。
- `quickstart.md` 指向 final QA 后的回归路径。
- `plan.md` 保留分段 IA / Design Pivot Adaptation 历史。
- `wireframes.md`、`components.md`、`design-tokens.md`、`interaction-acceptance.md` 已吸收两个 demo docs。
- 用户可以在新增 scope 后运行 `/speckit.analyze`。
