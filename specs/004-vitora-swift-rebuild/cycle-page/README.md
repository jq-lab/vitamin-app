# Cycle Page Spec Pack

> 规格集：`004-vitora-swift-rebuild`  
> 状态：Cycle 页面当前可执行 baseline  
> 目标图：`assets/design_04/cycle_d.png`  
> 当前 baseline 截图：`ios/QA/Screenshots/ImplementationV1/17-cycle-target-aligned.png`

本文件夹是 Cycle 页面后续设计、实现和 QA 的上下文恢复入口。任何后续设计师、工程师或 agent 只要涉及 Cycle 页面首页视觉、布局、组件、图表、Tip、Tab 避让或页面内 Pixel Vitora 接入，必须先读取本文件夹，再进入实现。

硬规则：Cycle 页面只能表达“长期节律背景 + 长周期能量动态”。不得把 Cycle 首页改回周期日历首页、任务打卡页、复杂医疗 dashboard 或商业化入口页。

## 1. 读取顺序

1. `README.md`：确认当前 baseline、目标图和恢复路径。
2. `cycle-page-spec.md`：严格执行的 Cycle 页面规格。
3. `implementation-contract.md`：工程实现边界和接入规则。
4. `difference-matrix.md`：目标图、上一版、当前 baseline 的差异记录。
5. `visual-evidence.md`：目标参考、当前实现截图和证据等级。
6. `qa-checklist.md`：自动验收、人工截图验收和反向验收。
7. `change-log.md`：历史改动、测试结果和未解决问题。

若本文件夹与 `facts.md` 冲突，以 `facts.md` 为准；若本文件夹与 `components.md`、`design-tokens.md` 或 `interaction-acceptance.md` 冲突，先同步正式规格，再继续实现。

## 2. 当前 Baseline

当前锁定的 App 内可执行 baseline 是：

```text
ios/QA/Screenshots/ImplementationV1/17-cycle-target-aligned.png
```

它代表当前 SwiftUI 原生 Cycle 页面的可复用实现方向：

- 紧凑页面标题 `周期` 和日期。
- 左上 profile/settings 头像玻璃圆按钮，不是 Pixel Vitora；右上分享只生成周期卡片截图。
- 第一张卡是 `当前周期阶段与今天`。
- 第二张卡是 `能量动态`。
- 页面底部有轻 Tip pill：`长按卡片，可以让 Vitora 解释或校准`。
- 底部 Tab 保持三主区，Cycle selected，中央 Vitora face 低凸起。
- 页面不出现日历首页、打卡、完成率、商业卡或复杂多指标健康图表。

上一版对照图：

```text
ios/QA/Screenshots/ImplementationV1/05-cycle-optimized.png
```

目标方向图：

```text
assets/design_04/cycle_d.png
```

## 3. 文件职责

| 文件 | 职责 |
| --- | --- |
| `cycle-page-spec.md` | Cycle 页面结构、组件、视觉和禁用方向的权威规格。 |
| `implementation-contract.md` | 工程接入规则，约束改动入口和不可变边界。 |
| `difference-matrix.md` | 记录目标、上一版、当前 baseline 的差异和状态。 |
| `visual-evidence.md` | 记录目标图、当前实现图、baseline 选择和证据等级。 |
| `qa-checklist.md` | 每次 Cycle 页面改动后的验收清单。 |
| `change-log.md` | 每次 Cycle 页面改动的上下文记忆。 |

## 4. 后续改动流程

1. 先读本文件夹全部文件。
2. 若改动涉及页面内 Pixel Vitora，先读 `../pixel-vitora-ip/README.md` 和 `../pixel-vitora-ip/pixel-vitora-ip-spec.md`。
3. 判断改动是否保持 Cycle 页面 baseline，不保持则不得实现。
4. 修改 SwiftUI 后，跑 `qa-checklist.md` 的构建、UI 测试和截图验收。
5. 把改动目的、截图路径、测试结果写入 `change-log.md`。

## 5. 快速恢复提示

下一位 agent 可以从这句话开始：

```text
先读取 specs/004-vitora-swift-rebuild/cycle-page/README.md 和 cycle-page-spec.md。
当前 Cycle 页面 baseline 是 ios/QA/Screenshots/ImplementationV1/17-cycle-target-aligned.png。
目标方向图是 assets/design_04/cycle_d.png。
任何 Cycle 页面改动都必须保持“长期节律背景 + 能量动态”，不得恢复日历首页、打卡、完成率、商业卡或复杂 dashboard。
```
