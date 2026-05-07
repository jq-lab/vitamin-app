# Vitora Swift Rebuild · Figma Reference Index

> 规格集：`004-vitora-swift-rebuild`
> 批次：IA / Design Pivot Adaptation
> 日期：2026-05-05
> 状态：当前生效

本文档记录 Figma 链接如何在 pivot 后使用。旧 Figma 仍有价值，但不再自动等于最终 UI 标准。

## 0. 使用规则

| Rule ID | Rule |
| --- | --- |
| FRI-AUTH-001 | 当前最终 UI 以 `wireframes.md`、`design-language-demo.md`、`design-tokens.md` 为准。 |
| FRI-AUTH-002 | Figma 节点若与 pivot 冲突，作为 evidence / anti-evidence，不作为目标。 |
| FRI-AUTH-003 | 实现前如需精确视觉，应重新用 Figma MCP 读取节点，并在 `ios/QA/figma-check.md` 记录。 |
| FRI-AUTH-004 | 用户面对命名使用 Vitora；旧 Figma 中 Luna 只代表历史 assistant 设计意图。 |

## 1. Pivot Visual Sources

| ID | Area | Source | Use |
| --- | --- | --- | --- |
| FRI-PIVOT-001 | Today | `assets/design_04/today_tab.png` | Today aura + clear glass + Pixel Vitora 装饰方向。 |
| FRI-PIVOT-002 | Vitora | `assets/design_04/vitora_tab.png` | Vitora assistant surface 方向。 |
| FRI-PIVOT-003 | Vitora chips | `assets/design_04/vitora_chip_clicked.png` | Quick context chips / input dock 附近上下文方向。 |
| FRI-PIVOT-004 | Cycle | `assets/design_04/cycle_d.png` | Cycle phase relation + energy dynamics 方向。 |
| FRI-PIVOT-005 | Full walkthrough | `wireframes-walkthrough-demo.md` | IA 第一层和二层完整路径 evidence。 |
| FRI-PIVOT-006 | Design language | `design-language-demo.md` | 弥散渐变、清透玻璃、Pixel Vitora high-rule。 |

## 2. Legacy Figma Nodes

| ID | Old Area | Link / Node | Current Use | Current Caveat |
| --- | --- | --- | --- | --- |
| FRI-LEGACY-001 | Today | `node-id=373-259` | 参考早期曲线、卡片和三 tab 意图。 | 不使用常驻大能量球、独立记录区、旧 AI 监测卡密度。 |
| FRI-LEGACY-002 | Old assistant | `node-id=301-289` | 参考像素 assistant 和输入 dock 的历史方向。 | 用户面对名称改为 Vitora；正式目标见 `WF-V-001`。 |
| FRI-LEGACY-003 | Old record sheet | `node-id=301-150`, `node-id=301-18` | 参考记录输入、快捷类型、确认保存需求。 | 不作为 Today 独立记录区；不强制切 Tab。 |
| FRI-LEGACY-004 | Old chat | `node-id=301-676` | 参考输入/阅读状态。 | 旧沉浸聊天不是唯一模型；正式目标是 Vitora assistant surface。 |
| FRI-LEGACY-005 | Old Cycle | `node-id=327-2`, `node-id=309-814` | 参考阶段和长期节律候选。 | Cycle 首页改为阶段关系 + 能量动态；不做日历首页。 |
| FRI-LEGACY-006 | Old Calendar | `node-id=306-2`, `node-id=334-1100` | Today 顶部日历二层可参考。 | 日历入口归 Today，不归 Cycle 首页。 |
| FRI-LEGACY-007 | Old Drawer | `node-id=305-2` | 支撑项候选池。 | P0 只显示六个支撑项。 |

## 3. Implementation Mapping

| New Task Area | Formal Source | Figma Use |
| --- | --- | --- |
| Today pivot | `WF-T-001` to `WF-T-006`, `C-TODAY-*` | 先看 `assets/design_04/today_tab.png`，旧 Today 只作反证。 |
| Vitora pivot | `WF-V-001` to `WF-V-005`, `C-VITORA-*` | 以 `assets/design_04/vitora_tab.png` 为方向；旧 assistant 节点仅参考像素/输入意图。 |
| Cycle pivot | `WF-C-001` to `WF-C-003`, `C-CYCLE-*` | 以 `assets/design_04/cycle_d.png` 为方向；旧 Cycle 日历不作首页目标。 |
| Support | `WF-S-001`, `C-SUPPORT-*` | 旧 drawer 只作反证和候选池。 |

## 4. QA

- 实现时引用 Figma 必须同时引用 formal `WF-*`。
- 若 Figma 节点显示 human avatar、smooth orb、旧 Luna 文案或 Cycle 日历首页，应记录为 anti-evidence。
- 当前最高视觉规则是 `弥散渐变背景 + 清透拟态玻璃组件 + Pixel Vitora 陪伴体`。
