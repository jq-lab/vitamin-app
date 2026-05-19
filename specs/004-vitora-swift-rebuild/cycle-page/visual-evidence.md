# Cycle Page Visual Evidence

> 本文件记录 Cycle 页面相关目标图、当前实现图和证据等级。

## 1. Evidence Index

| ID | Path | Type | Role |
| --- | --- | --- | --- |
| `CY-EV-TARGET-D` | `assets/design_04/cycle_d.png` | 目标图 | Cycle 页面当前唯一主视觉方向参考。 |
| `CY-EV-REF-COMPACT-20260518` | `ios/QA/Screenshots/ImplementationV1/20260518-cycle-reference-compact-summary-final.png` | 当前实现 | 按用户卡片参考图收紧后的首屏：头像/分享、轻插画、紧凑摘要卡、连体页签、洞察列表。 |
| `CY-EV-BASELINE-17` | `ios/QA/Screenshots/ImplementationV1/17-cycle-target-aligned.png` | 当前实现 | 当前 App 内可执行 baseline。 |
| `CY-EV-PREV-05` | `ios/QA/Screenshots/ImplementationV1/05-cycle-optimized.png` | 上一版实现 | 用于判断本轮已解决差异。 |
| `CY-EV-IP-15` | `ios/QA/Screenshots/ImplementationV1/15-ip-glass-simulator-visible.png` | IP baseline | 页面内 Pixel Vitora 形象来源。 |

## 2. Evidence Priority

1. `facts.md`：最高事实来源。
2. `cycle-page/cycle-page-spec.md`：Cycle 页面执行规格。
3. `assets/design_04/cycle_d.png`：视觉方向参考。
4. `20260518-cycle-reference-compact-summary-final.png`：按最新卡片参考收紧后的当前实现。
5. `17-cycle-target-aligned.png`：上一版可执行 App baseline。
6. `05-cycle-optimized.png`：上一版差异参考。

若目标图与正式 facts 冲突，以 facts 为准。例如目标图中的任何可能被理解为 human avatar、日历首页、商业化入口或医疗 dashboard 的元素，都不得进入实现。

## 3. 当前 Baseline 说明

`20260518-cycle-reference-compact-summary-final.png` 已确认：

- Cycle 首页首屏包含左头像、右分享、`周期回顾 / 复盘成长 · 洞察规律`、轻日历插画、三件事白霜摘要卡、三段卡片式页签和洞察列表。
- 三件事摘要卡包含当前阶段、本周平均、低谷窗口和待确认状态，使用紧凑分割线结构，不再使用 2x2 大方块。
- `30 天成长册`、花园手册和种子选择已从当前可见路径移除；周期学习由三件事总结、能量动态和节律洞察承接。
- 左上 profile/settings 是用户入口，不是 Vitora IP；右上分享只导出周期卡片截图。
- 页面没有日历首页、打卡、完成率、商业卡或复杂多指标健康图表。

## 4. 目标图使用方式

`cycle_d.png` 只作为方向参考：

- 参考浅蓝 Aura Glass 背景。
- 参考两张主玻璃卡的首屏层级。
- 参考阶段关系 + 能量动态的页面心智。
- 参考 Pixel Vitora 作为轻陪伴入口，而不是主内容。

不得机械复刻：

- 任何可能变成人像 avatar 的元素。
- 任何超出 P0 的商业、任务或医疗 dashboard 信息。
- 任何和当前 Pixel Vitora spec 冲突的 IP 形态。
