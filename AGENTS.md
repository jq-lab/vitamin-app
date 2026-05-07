# Vitora Swift Rebuild · Codex 入口指令

**本项目所有交流语言主要为中文。** 代码标识使用英文；面向用户的字符串使用简体中文。

## 1. 当前分支目标

本分支是 Vitora 的纯 Swift 重建分支。

- 分支名：`004-vitora-swift-rebuild`
- SpecKit Pro 功能目录：`specs/004-vitora-swift-rebuild/`
- 目标：从最新 004 规格开始实现原生 iOS P0，不继承旧 RN / Expo 实现。

## 2. 真实来源优先级

1. `specs/004-vitora-swift-rebuild/facts.md`
2. `specs/004-vitora-swift-rebuild/spec.md`
3. `specs/004-vitora-swift-rebuild/userflows.md`
4. `specs/004-vitora-swift-rebuild/ia.md`
5. `specs/004-vitora-swift-rebuild/wireframes.md`
6. `specs/004-vitora-swift-rebuild/reference.md`
7. `specs/004-vitora-swift-rebuild/components.md`
8. `specs/004-vitora-swift-rebuild/design-tokens.md`
9. `specs/004-vitora-swift-rebuild/data-model.md`
10. `specs/004-vitora-swift-rebuild/data-privacy-ai-boundaries.md`
11. `specs/004-vitora-swift-rebuild/compliance.md`
12. `specs/004-vitora-swift-rebuild/plan.md`
13. `specs/004-vitora-swift-rebuild/contracts/`
14. `specs/004-vitora-swift-rebuild/quickstart.md`
15. Figma 链接和当前 app 证据只按 004 文档里的来源分级使用。

如果文件之间冲突，先服从 `facts.md`。如果 `facts.md` 也需要调整，必须同步记录到 `00-product-reset/decision-log.md`。

## 3. 每次会话开始前

必须先读：

```text
specs/004-vitora-swift-rebuild/facts.md
```

如果任务涉及实现，还要读：

```text
specs/004-vitora-swift-rebuild/spec.md
specs/004-vitora-swift-rebuild/plan.md
specs/004-vitora-swift-rebuild/speckit-handoff.md
```

如果任务涉及界面，还要读：

```text
specs/004-vitora-swift-rebuild/wireframes.md
specs/004-vitora-swift-rebuild/reference.md
specs/004-vitora-swift-rebuild/components.md
specs/004-vitora-swift-rebuild/design-tokens.md
specs/004-vitora-swift-rebuild/interaction-acceptance.md
```

## 4. 硬规则

- 不把旧 RN / Expo 代码当实现目标。
- 不引用旧的 `.specify/specs/` 派生规格。
- 不使用旧截图作为新视觉依据。
- 不新增第四个主 Tab。
- 不实现打卡、连续天数、完成率、未完成红点或任务清单心智。
- 不展示 P0 之外的占位入口。
- HealthKit 是可选增强，不能成为进入 app 的门槛。
- 健康相关数据本地优先，敏感内容必须加密保存。
- 发给 AI 的上下文必须最小化，并移除直接身份线索。
- 日志和错误上报不能包含健康数值、记录原文、prompt 或完整 AI 输出。
- A/B 选择必须形成当日意图、提醒偏好和晚间复盘路径，不能停在即时反馈。
- 合规表达以 `compliance.md` 的 `CL-*`、`CX-*`、`CB-*`、`CR-*` 为准；不要在实现或新文档里重新发明表达边界。

## 5. SpecKit Pro 使用方式

本分支已经把最新 004 specs 放在 SpecKit Pro 读取的目录：

```text
specs/004-vitora-swift-rebuild/
```

后续推荐命令顺序：

```text
/speckit.tasks
/speckit.analyze
/speckit.implement
```

不要默认重新运行 `/speckit.specify`、`/speckit.userflows`、`/speckit.ia`、`/speckit.wireframes`、`/speckit.components` 或 `/speckit.plan`，因为这些核心规格已经人工校准完成。

如果必须重跑某个生成命令，先说明会覆盖哪些文件，并获得用户确认。

## 6. Swift 实现边界

后续实现应创建新的原生 iOS 工程：

```text
ios/
├── Vitora.xcodeproj
├── Vitora/
├── VitoraTests/
└── VitoraUITests/
```

实现必须以 `plan.md`、`contracts/`、`data-model.md` 和 `quickstart.md` 为输入。旧 JS/TS 文件只能在用户明确要求时作为历史证据读取，不能作为 Swift 结构来源。
