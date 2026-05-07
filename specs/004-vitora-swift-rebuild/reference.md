# Vitora Swift Rebuild · 前端最终参考索引

> 规格集：`004-vitora-swift-rebuild`
> 批次：IA / Design Pivot Adaptation
> 日期：2026-05-05
> 状态：当前生效

本文档回答：P0 前端每一步应该参考哪一个正式线框、视觉规则和证据文件。它已废弃旧 Luna / 旧 Cycle 日历首页 / 旧 Today 记录入口索引。

## 0. 使用规则

| Rule ID | Rule |
| --- | --- |
| RF-AUTH-001 | `wireframes.md` 是正式结构参考。 |
| RF-AUTH-002 | `design-language-demo.md` 和 `design-tokens.md` 是正式视觉参考。 |
| RF-AUTH-003 | Figma / RN / 旧截图只作 evidence 或 anti-evidence，不能覆盖新 IA。 |
| RF-AUTH-004 | 若旧资产里出现 Luna、human avatar、smooth orb、Cycle calendar home，应按 `design-language-demo.md` 的 correction 处理。 |

## 1. 参考类型

| Type | Meaning |
| --- | --- |
| `Formal Wireframe` | 以 `wireframes.md` 的 `WF-*` 为最终前端结构。 |
| `Visual High-rule` | 以 `design-language-demo.md` 和 `design-tokens.md` 为视觉系统。 |
| `Evidence Only` | 旧 Figma/RN 只证明某种意图存在，不是目标画面。 |
| `Anti-evidence` | 明确不能复刻的旧画面或旧交互。 |

## 2. Flow Reference Matrix

| Flow | User Step | Formal Reference | Visual Reference | Notes |
| --- | --- | --- | --- | --- |
| UF-001 | Onboarding | IA-001 to IA-003 | G2/G4 readable glass | HealthKit optional；不做 WeChat gate。 |
| UF-002 | Today first open | WF-T-001 | Today aura + clear glass | 3 秒内状态/要素/建议。 |
| UF-003 | Pull-to-reveal Energy Ball | WF-T-002 | EnergyRevealHeader tokens | 不是 refresh；默认隐藏。 |
| UF-004 | Vitora daily suggestion | WF-T-006 | Suggestion card G2 glass | `我试试` 形成当日意图。 |
| UF-005 | Tell Vitora contextual flow | WF-V-005 | Contextual sheet G3 glass | 不切 tab；保存前确认。 |
| UF-006 | Full Vitora assistant | WF-V-001 to WF-V-004 | Pixel Vitora hero + input dock | 不是空聊天页。 |
| UF-007 | Evening review | WF-R-001 | Energy Ball review layer | 对比介入前后感受。 |
| UF-008 | Cycle overview | WF-C-001 | Cycle aura + clear glass | 阶段关系 + 能量动态。 |
| UF-009 | Cycle details | WF-C-002, WF-C-003 | Chart/callout tokens | 阶段透明解释；趋势探索。 |
| UF-010 | Support / privacy | WF-S-001 | G4 practical surface | 六个 P0 支撑项。 |

## 3. Screen Reference Matrix

| IA | Screen / State | Reference | Must Show | Must Not Show |
| --- | --- | --- | --- | --- |
| IA-010 | Today Home | WF-T-001 | 日历 strip、Pixel Vitora 装饰、状态卡、身体要素、建议卡 | 独立记录区、常驻大球、dashboard 堆卡 |
| IA-011 | Energy Reveal | WF-T-002 | 下拉揭示、半展开、全屏 ritual、可收起 | refresh 语义、长阻塞动画 |
| IA-012 | Today Calendar | WF-T-003 | 月历/周历、今天、阶段/预测、Vitora 洞察 | Cycle 首页日历 |
| IA-013 | Today State Detail | WF-T-004 | 曲线、关键窗口、告诉 Vitora | 直接拖曲线改模型 |
| IA-014 | Body Factors Detail | WF-T-005 | 指标数值、趋势、对今天意义 | 高级图表堆叠 |
| IA-015 | Suggestion Detail | WF-T-006 | 建议、原因、提醒、我试试/换一个/不适合 | 任务完成率 |
| IA-020 | Vitora Assistant Surface | WF-V-001 | Pixel Vitora、Vitora 知道、直接问、chips、input dock | 空白聊天页、功能 dashboard |
| IA-021 | Contextual Vitora Sheet | WF-V-005 | 来源上下文、快捷补充、输入、语音、确认 | 直接切 tab |
| IA-022 | Full Vitora Context Mode | WF-V-002 to WF-V-004 | 压缩 IP、对话、rich response、确认保存 | 旧单一沉浸聊天提示页 |
| IA-024 | Evening Review | WF-R-001 | 早上状态、晚间反馈、是否有帮助 | “完成了吗”压力 |
| IA-030 | Cycle Home | WF-C-001 | 阶段关系卡、能量动态卡、设置入口 | 日历首页、高级商业卡 |
| IA-031 | Phase Detail | WF-C-002 | 判断依据、预测窗口、对今天意义、校准 | 只重复首页 |
| IA-032 | Energy Dynamics Detail | WF-C-003 | 日/周/月、图层、callout、Vitora 叙事 | 多指标复杂 dashboard |
| IA-040 to IA-046 | Support | WF-S-001 | 六个 P0 支撑项 | VIP、主题、小组件、帮助墙 |

## 4. Visual Evidence Reference

| Evidence | Use |
| --- | --- |
| `assets/design_04/today_tab.png` | Today clear glass + aura + Pixel Vitora 装饰方向。 |
| `assets/design_04/vitora_tab.png` | Vitora AI-native assistant surface 方向。 |
| `assets/design_04/vitora_chip_clicked.png` | Quick context chips / input-adjacent context 方向。 |
| `assets/design_04/cycle_d.png` | Cycle 阶段关系 + 能量动态 + Pixel Vitora 方向。 |
| `wireframes-walkthrough-demo.md` | 完整 IA walkthrough evidence。 |
| `design-language-demo.md` | 视觉 high-rule evidence。 |

## 5. Anti-evidence

| Old Reference | Why Not Target |
| --- | --- |
| 旧 Figma Today 大能量球首页 | Energy Ball 改为下拉/首次/复盘 ritual，不常驻。 |
| 旧 Luna 首页/沉浸聊天 | 只保留 Pixel assistant 意图；正式目标是 Vitora Assistant Surface。 |
| 旧 Luna record sheet | 只保留输入/确认保存意图；正式目标是 contextual Tell Vitora。 |
| 旧 Cycle 日历页作为 Cycle 流程 | 日历归 Today 顶部；Cycle 负责长期节律和能量动态。 |
| human avatar / smooth orb | 与 Pixel Vitora IP 冲突。 |
| Apple Health dashboard-like flat white | 与 Aura Glass Pixel Companion 冲突。 |

## 6. QA Coverage

- Every P0 flow maps to a formal `WF-*`.
- Every formal screen has visual high-rule reference.
- No implementation task should cite old `RF-*` IDs from pre-pivot reference.
- New tasks should cite `WF-T-*`, `WF-V-*`, `WF-C-*`, `WF-S-*`, `WF-R-*`, `C-*`, `vt.*`, and `IAC-*`.
