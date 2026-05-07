# Vitora Swift Rebuild · Visual Evidence Map

> 规格集：`004-vitora-swift-rebuild`
> 批次：IA / Design Pivot Adaptation
> 日期：2026-05-05
> 状态：当前生效

本文档说明视觉证据如何使用。pivot 后，旧 Figma / RN 截图不再是直接目标；新目标以 `wireframes.md`、`design-language-demo.md`、`design-tokens.md` 和 `assets/design_04/` 为准。

## 0. 使用规则

| Rule ID | Rule |
| --- | --- |
| EV-AUTH-001 | `assets/design_04/*` 是当前设计语言最高视觉证据。 |
| EV-AUTH-002 | 旧 Figma 节点只作局部结构/历史意图证据。 |
| EV-AUTH-003 | 当前 RN / Swift 截图只作可达性、交互、反证，不作目标视觉。 |
| EV-AUTH-004 | 若证据与 `wireframes.md` 或 `design-language-demo.md` 冲突，以 formal specs 为准。 |

## 1. Current Visual Evidence

| Evidence ID | Source | Proves | Caveat |
| --- | --- | --- | --- |
| EV-D04-TODAY | `assets/design_04/today_tab.png` | Today 使用浅蓝弥散背景、清透玻璃、Pixel Vitora 装饰、状态曲线、身体要素、建议卡。 | 不复制任何旧 dashboard 密度。 |
| EV-D04-VITORA | `assets/design_04/vitora_tab.png` | Vitora Tab 是 AI-native assistant surface，有 Pixel Vitora、上下文、对话、直接问、chips、input dock。 | 直接问不能占满屏幕。 |
| EV-D04-CHIP | `assets/design_04/vitora_chip_clicked.png` | Quick context chips 是输入附近的小上下文对象。 | 不是大功能卡。 |
| EV-D04-CYCLE-D | `assets/design_04/cycle_d.png` | Cycle 可以用阶段关系 + 能量动态 + Pixel Vitora + clear glass。 | 需保持 blue/cyan-first。 |
| EV-DEMO-WF | `wireframes-walkthrough-demo.md` | 完整 IA walkthrough。 | 已被 `wireframes.md` 正式吸收。 |
| EV-DEMO-DL | `design-language-demo.md` | Aura Glass Pixel Companion visual system。 | 已被 tokens/components/acceptance 正式吸收。 |

## 2. Legacy Figma Evidence

| Evidence ID | Old Area | Current Use | Anti-evidence |
| --- | --- | --- | --- |
| EV-LEGACY-TODAY | 旧 Today Figma / RN | 可参考早期能量、曲线、底部三 tab 的意图。 | 大 Energy Ball 常驻、AI 监测卡、独立记录区不再是目标。 |
| EV-LEGACY-VITORA | 旧 Luna Figma / RN | 可参考像素 assistant、输入 dock、记录表面意图。 | 用户面对名称 Luna、空聊天页、旧沉浸聊天唯一心智不再是目标。 |
| EV-LEGACY-RECORD | 旧 record sheet | 可参考自然语言输入、快捷类型、确认保存需要。 | 不再作为 Today 独立记录区或强制切 tab 目标。 |
| EV-LEGACY-CYCLE | 旧 Cycle / calendar | 可参考阶段、日历和长期节律候选。 | Cycle 首页日历、高级展开、商业入口不进入 P0。 |
| EV-LEGACY-DRAWER | 旧 drawer | 可参考支撑项候选。 | 宽抽屉、VIP、小组件、帮助墙、养成入口不进入 P0。 |

## 3. Formal Visual Targets

| Target | Formal Source | Evidence |
| --- | --- | --- |
| Today home | `WF-T-001`, `C-TODAY-*`, `vt.bg.aura.today` | EV-D04-TODAY |
| Energy reveal | `WF-T-002`, `C-TODAY-008` | EV-DEMO-WF |
| Vitora assistant surface | `WF-V-001` to `WF-V-004`, `C-VITORA-*` | EV-D04-VITORA, EV-D04-CHIP |
| Contextual Vitora sheet | `WF-V-005`, `C-VITORA-010` | EV-DEMO-WF |
| Cycle home | `WF-C-001`, `C-CYCLE-002`, `C-CYCLE-004` | EV-D04-CYCLE-D |
| Support | `WF-S-001`, `C-SUPPORT-*`, `vt.glass.g4.support` | EV-DEMO-DL |

## 4. Evidence QA Rules

- Any implementation using legacy Figma must also cite the corresponding formal `WF-*`.
- Any screenshot used for QA must be freshly captured from the current Swift app.
- Old screenshots under `assets/wireframes/rn/` remain historical evidence only.
- Figma MCP should be used again when implementing a screen whose final visual still depends on a Figma node, but the node cannot override pivot decisions.
