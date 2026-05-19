# Vitora Swift Rebuild · Canonical Facts

> 规格集： `004-vitora-swift-rebuild`
> 批次： Canonical Facts · IA / Design Pivot Adapted
> 日期：2026-05-05
> 状态：当前生效

本文档是 `004-vitora-swift-rebuild` 的最高事实来源。后续 `spec.md`、`userflows.md`、`ia.md`、`wireframes.md`、`components.md`、`design-tokens.md`、`interaction-acceptance.md`、`plan.md`、`tasks.md` 与本文档冲突时，以本文档为准。

本文档只记录已锁定事实，不记录 Swift 架构、数据库 schema、API endpoint 或实现任务。

## 0. 来源与权威

| Fact ID | Fact | Constraint | Source |
| --- | --- | --- | --- |
| F-SOURCE-001 | 本文件是 004 Swift rebuild 的最高事实来源。 | 派生规格冲突时先改 facts，再改派生规格。 | D-004, D-005 |
| F-SOURCE-002 | 原始 `Spec/` 只作为产品意图库、约束库、候选功能池。 | 旧结论必须经过 Product Reset 与本轮 pivot 后才能进入 P0。 | D-002 |
| F-SOURCE-003 | 当前已存在 app 只作为 evidence / anti-evidence。 | 不复刻当前颜色、布局、缺失按钮、宽抽屉、旧记录跳转或混乱 UX。 | D-003, D-025 |
| F-SOURCE-004 | Prior generated rebuild material 不进入事实链。 | 不引用 003、不引用旧截图作为真相。 | D-001 |
| F-SOURCE-005 | `wireframes-walkthrough-demo.md` 是本轮 IA pivot 的临时 high-rule evidence。 | 正式 specs 必须吸收它；实现不能绕过正式 specs 只读 demo。 | D-039 |
| F-SOURCE-006 | `design-language-demo.md` 是本轮视觉系统 pivot 的临时 high-rule evidence。 | 正式 tokens、components、wireframes、acceptance 必须吸收它。 | D-038, D-039 |

## 1. 产品身份事实

| Fact ID | Fact | Constraint | Source |
| --- | --- | --- | --- |
| F-PRODUCT-001 | 产品名为 Vitora。 | 后续用户面对文案不再使用旧产品名。 | Product Charter |
| F-PRODUCT-002 | 用户面对的 AI assistant 名为 Vitora。 | `Luna` 只允许作为历史证据或内部代码迁移债务，不进入产品文案、IA、用户流程或视觉目标。 | D-032 |
| F-PRODUCT-003 | Vitora 是全局 Assistant Layer。 | 它不是普通聊天 Tab、不是记录工具、不是建议卡来源标签，而是全 app 可唤醒的解释、校准、记录、建议、复盘层；P0 底部 Dock 在 Today / Vitora / Cycle 常驻，Tab 三入口同处一个居中玻璃胶囊，右侧独立圆形 `+` 负责快捷记录；输入条只在 AI 管家页展开；sheet 展示时全局 Dock 隐藏，sheet 使用自己的本地输入。 | D-032, D-035, D-036, D-043, D-045, D-046, D-047, D-048 |
| F-PRODUCT-004 | Vitora 的核心循环是学习循环。 | 不做打卡循环、任务循环、连续天数循环或完成率循环。 | D-007 |
| F-PRODUCT-005 | 核心用户问题是：“我今天怎么样，以及我可以轻轻试什么？” | P0 功能优先服务这个问题。 | D-007 |
| F-PRODUCT-006 | Vitora 的职责是解释、记录、建议、复盘、学习。 | Vitora 不变成泛聊天、不做医疗诊断、不做任务管理。 | D-032 |
| F-PRODUCT-007 | 记录是“告诉 Vitora 一件重要变化”。 | 记录不是独立打卡区，必须嵌入状态、身体要素、建议、Cycle 等真实对象。 | D-033, D-036 |

## 2. P0 Swift MVP 事实

| Fact ID | Fact | Constraint | Source |
| --- | --- | --- | --- |
| F-P0-001 | P0 目标是证明 Vitora 最小学习闭环。 | 不追求原始 Spec 全量 parity，也不追求当前实现 parity。 | D-004 |
| F-P0-ONBOARDING-001 | P0 需要最小 onboarding。 | 收集最小身份、周期上下文和关注点；不设置 WeChat account gate。 | D-019 |
| F-P0-DATA-001 | P0 具备 HealthKit 能力。 | HealthKit 对用户可选，不能成为使用门槛。 | D-020 |
| F-P0-DATA-002 | 用户拒绝或跳过 HealthKit 时，app 仍必须可用。 | 必须提供手动/低数据路径。 | D-020 |
| F-P0-NAV-001 | P0 主导航固定为 Today / Vitora / Cycle。 | 不增加第四个主 Tab。 | D-008, D-032 |
| F-P0-TODAY-001 | Today 的心智是“现在状态 → 身体要素 → Vitora 今日建议”。 | Today 不能变成密集指标 dashboard，也不能保留独立打卡/记录区。 | D-033 |
| F-P0-TODAY-002 | Today 顶部日历入口进入周期日历。 | 周期日历解释“今天在周期时间线的位置”；不作为 Cycle 首页组件。 | D-037 |
| F-P0-ORB-001 | Energy Bowl 进入 P0，作为 Today 首屏状态主交互。 | Today 首屏不再使用顶部下拉 Energy Ball；首页固定为综合能量碗、碗外下方三阶段周期圆弧和 Vitora 今日建议，不展示睡眠/周期预测切换、实时预测图、数据小标签、花园手册、成长册入口或校准 chips；睡眠种子状态只允许作为 `Vitora 今日建议` 卡内的低权重建议反馈证据；能量数字必须单层高对比可读，状态词位于数字下方并与 `查看数据` 同行；水滴动效从屏幕顶部落入碗口，水位按综合能量显示浅水/半碗/接近满碗，Reduce Motion 下静态显示对应水位；碗下圆弧必须下移到碗外红线区域，和碗底保持约一个中文字高度的呼吸空间；`查看数据` 打开今日分析，合并综合实时预测、数据小标签与睡眠、HRV、心率、周期依据。 | D-034, D-041, D-042, D-044, D-047, D-048, D-049, D-050, D-051, D-052, D-053, D-055 |
| F-P0-VITORA-001 | Vitora Tab 是 AI-native assistant surface。 | 默认态必须有固定实体化的 Pixel Vitora / `Vitora 知道` 上下文卡、对话、快捷上下文、输入 dock；进入后不自动大展开，上拉进入聊天聚焦态时隐藏 hero 卡并展示完整聊天内容，不切回 Today；周期、睡眠、营养使用统一上下文卡模板。 | D-035, D-050 |
| F-P0-VITORA-002 | 非 CTA 唤醒 Vitora 打开 3/4 contextual sheet。 | Sheet 必须带来源上下文；上滑后才升级完整 Vitora。 | D-036 |
| F-P0-VITORA-003 | Vitora 输入必须支持文字、语音入口、快捷上下文和发送。 | P0 可先做文字主路径，但视觉和规格不得封死语音记录；输入条只在 AI 管家页展开，结构为语音/键盘、文本或语音条、发送，不保留输入内 `+`；只有用户点击 `AI管家` Tab 时自动展开并聚焦输入；全局 Dock 使用 safe-area 承载并在 sheet 展示时隐藏，避免 title/input 串页。 | D-035, D-043, D-045, D-046, D-048 |
| F-P0-RECORD-001 | P0 需要轻量记录捕获与理解确认。 | 用户保存的是事实，Vitora 更新的是判断；AI 理解必须可确认、修改、不更新；全局 Dock 右侧独立圆形 `+` 打开 contextual sheet，不切换到 Vitora Tab、不改全局草稿，sheet title 使用稳定“关闭 / 标题 / 来源摘要 / 底部本地输入”结构。 | D-033, D-036, D-045, D-046, D-048 |
| F-P0-AB-001 | Vitora 今日建议形成当日意图和晚间复盘路径。 | 不是 toast、不是任务清单、不是完成压力；Today 首页建议卡必须先用大字号身体翻译解释原因，再提供可轮换的 `吃+休息 / 运动+吃 / 休息+运动` 两条组合建议，`我试试` 进入现有今日分析/提醒路径并可推动睡眠种子状态从半开继续打开，`换一换` 只在本卡内循环切换。 | D-010, D-033, D-049, D-055 |
| F-P0-REVIEW-001 | P0 需要最小晚间复盘。 | 复盘必须对比当天 app 介入前后效果，可使用能量对比表达，但不依赖 Today 顶部下拉 Energy Ball；用户完成 `有帮助 / 一般 / 不适合` 反馈后，可以选择一颗睡眠种子，作为明早验证身体方向的实验层。 | D-021, D-041, D-055 |
| F-P0-CYCLE-001 | Cycle 的心智是长期节律背景 + 长周期能量动态。 | 首页为 `周期回顾`：三件事总结、能量动态、三张节律洞察卡和低权重 `本周期花架证据`；花架证据只展示最近 7-10 次“建议 → 反馈”的学习结果；不放 30 天成长册、花园手册、种子选择、花田地图或日历首页，不引入打卡、连续天数、完成率、红点或任务清单。 | D-037, D-051, D-052, D-053, D-055 |
| F-P0-CYCLE-002 | Cycle 二层必须提供透明解释和趋势探索。 | 阶段详情解释 Vitora 如何判断；能量动态详情提供日/周/月、图层、关键点、Vitora 叙事。 | D-037 |
| F-P0-SUPPORT-001 | P0 保留设置/支撑能力。 | 个人资料、HealthKit 与数据来源、营养补给、提醒偏好、数据导出、隐私法律与账号移除必须可达。 | D-024 |
| F-P0-SUPPORT-002 | 设置入口从 Cycle 右上 profile/settings 进入，Vitora contextual support 可从 Vitora 进入。 | Today 保持聚焦，不放常驻宽抽屉入口。 | D-024, D-037 |
| F-P0-SUPPLEMENT-001 | 营养补给页面保留在 P0。 | 管理页在支撑区；快捷新增从 Vitora 输入/记录流进入。 | D-022 |
| F-P0-AI-001 | 云端或服务端智能能力可支撑 P0 Vitora 能力。 | 技术方案后续可替换；产品层不绑定单一模型。 | FI-044 |
| F-P0-AI-002 | Local Gemma / agentic usage 不进入 P0 实现。 | 规格不得封死未来本地模型和 agentic usage。 | D-016 |

## 3. 视觉事实

| Fact ID | Fact | Constraint | Source |
| --- | --- | --- | --- |
| F-VISUAL-001 | 设计语言锁定为“浅霜弥散背景 + 清透拟态玻璃组件 + Pixel Vitora 陪伴体”。 | 正式设计 tokens、components、wireframes、QA 必须服从；全 App 背景用低饱和原生分层承载空气感，不直接使用外部参考图素材。 | D-038, D-054 |
| F-VISUAL-002 | App 背景当前采用 Warm Paper Aura：暖米纸底 + 珍珠白主卡 + 低饱和青雾/暖雾分区，并可按 Today / Vitora / Cycle / Sheet / Onboarding / Support 场景调整。 | 青色保留为 Vitora 水感和边缘空气层；Lavender 只做边缘氛围；不能变成死白 dashboard、重橙照片、营销渐变或彩色雾面整卡；子页面必须保持白色霜状玻璃质感和高可读性。 | design-language-demo.md, D-054, D-056 |
| F-VISUAL-003 | 第一层 IA 主卡使用清透拟态玻璃。 | 保持透明感、白色高光边、软蓝阴影和文字可读性。 | D-038 |
| F-VISUAL-004 | Pixel Vitora 是品牌 IP。 | 必须是像素风格发光小球；不是 smooth orb、human avatar、pet 或普通图标。 | D-038 |
| F-VISUAL-005 | 底部 Vitora CTA 使用 Pixel Vitora face，且低凸起。 | 不能用 heart icon、黑色大圆、过高浮动按钮；不能遮挡 Vitora input dock。 | design-language-demo.md |

## 4. P0 不做事实

| Fact ID | Fact | Constraint | Source |
| --- | --- | --- | --- |
| F-OUT-001 | P0 不做 WeChat account gate。 | 不能把 WeChat 作为进入 app 的必需条件。 | D-019 |
| F-OUT-002 | P0 不做 broad drawer placeholder pages。 | 延期功能不可见，不用占位页预告未来范围。 | D-014, D-024 |
| F-OUT-003 | P0 不做完整 VIP 体系。 | 订阅管理和行为洞察式升级提示后移。 | FI-049 |
| F-OUT-004 | P0 不做 IoT、小组件、多设备深度。 | 这些能力进入 P1/P2 或后续技术 batch。 | FI-051, FI-052 |
| F-OUT-005 | P0 不做完整 assistant 养成体系。 | 避免天数、进度压力进入核心体验；只允许 D-055 的复盘种子实验层作为建议反馈可视化，不做养成进度。 | FI-033, FI-040, D-055 |
| F-OUT-006 | P0 不做本地 LLM 执行。 | 只保留未来可引入的产品和数据边界。 | D-016 |
| F-OUT-007 | P0 不复制当前 RN 视觉和混乱 UX。 | 当前实现只提供 evidence / anti-evidence。 | D-003, D-017 |
| F-OUT-008 | P0 不做自定义任务卡。 | 避免把 Today 推向任务管理。 | FI-016 |
| F-OUT-009 | P0 不把 Cycle 做成日历首页。 | 日历从 Today 顶部进入；Cycle 负责长期节律。 | D-037 |
| F-OUT-010 | P0 不做 Apple Health dashboard 风格。 | 视觉必须体现 Aura Glass Pixel Companion。 | D-038 |

## 5. 合规、隐私、AI 边界事实

| Fact ID | Fact | Constraint | Source |
| --- | --- | --- | --- |
| F-COMPLIANCE-001 | 合规规则是硬门。 | `004/compliance.md` 是 Swift rebuild 的合规表达来源。 | D-015 |
| F-COMPLIANCE-002 | 健康相关内容必须使用批准的合规标识策略。 | UI、Vitora 输出、营养、趋势和复盘都必须服从。 | D-018 |
| F-COMPLIANCE-003 | 限制表达列表必须被继承。 | 文案、AI 输出和 UI copy 都必须服从 `004/compliance.md`。 | FI-048 |
| F-PRIVACY-001 | 健康数据本地优先。 | 后续技术 plan 必须定义本地保护方案。 | D-015 |
| F-PRIVACY-002 | 敏感健康数据必须加密。 | 不允许以明文方式作为最终方案。 | D-015 |
| F-PRIVACY-003 | 发给 LLM 的上下文必须最小化并脱敏。 | 不发送可直接识别用户身份的字段。 | FI-047 |
| F-PRIVACY-004 | 日志和错误上报不得泄露健康数值。 | 不记录健康数值、记录原文、prompt、完整 AI 输出。 | D-015 |
| F-PRIVACY-005 | 数据导出和账号移除是产品底线。 | 必须在支撑区可达。 | FI-036, FI-037 |
| F-AI-001 | Vitora 可使用 AI 生成解释、建议、复盘和记录理解。 | 所有输出必须服从合规和隐私边界。 | D-032 |
| F-AI-002 | AI 能力不得改变 P0 产品事实。 | 模型选择、运行位置和技术方案后续再定。 | D-016 |

## 6. Implementation Progress Facts

| Fact ID | Fact | Constraint | Source |
| --- | --- | --- | --- |
| F-IMPL-001 | `tasks.md` 中 T001-T177 已完成，代表 P0 Swift MVP 已通过最终 QA。 | 后续新 scope 必须先更新 specs/tasks，再进入 analyze/implement。 | D-040, final QA |
| F-IMPL-002 | T102-T138 的 IA / Design Pivot Adaptation 已完成。 | 不能回到旧 US6 Evening Review 或旧 T102。 | D-040, final QA |
| F-IMPL-003 | 旧代码中的 Luna 命名可以暂时作为 migration debt 存在。 | 用户面对文案、正式 specs、新任务和新组件必须使用 Vitora；后续迁移不得改变产品命名。 | D-032, D-040 |
| F-IMPL-004 | 最近完整测试为 109 passed、0 failed、0 skipped。 | 结果见 `ios/QA/Reports/xcodebuild-test.txt` 和 `/tmp/vitora-final-qa-20260507c.xcresult`。 | T174 |

## 7. Traceability Index

| Decision / Feature | Covered By |
| --- | --- |
| D-032 | F-PRODUCT-002, F-PRODUCT-003, F-P0-NAV-001, F-IMPL-003 |
| D-033 | F-P0-TODAY-001, F-P0-RECORD-001, F-P0-AB-001 |
| D-034 | F-P0-ORB-001, F-P0-REVIEW-001 |
| D-041 | F-P0-ORB-001, F-P0-REVIEW-001 |
| D-042 | F-P0-ORB-001 |
| D-043 | F-PRODUCT-003, F-P0-NAV-001, F-P0-VITORA-003 |
| D-044 | F-P0-ORB-001 |
| D-047 | F-PRODUCT-003, F-P0-ORB-001 |
| D-048 | F-PRODUCT-003, F-P0-ORB-001, F-P0-VITORA-003, F-P0-RECORD-001 |
| D-049 | F-P0-ORB-001, F-P0-AB-001 |
| D-050 | F-P0-ORB-001, F-P0-VITORA-001 |
| D-051 | F-P0-ORB-001, F-P0-CYCLE-001, F-P0-CYCLE-002 |
| D-052 | F-P0-ORB-001, F-P0-REVIEW-001, F-P0-CYCLE-001, F-P0-CYCLE-002 |
| D-055 | F-P0-ORB-001, F-P0-AB-001, F-P0-REVIEW-001, F-P0-CYCLE-001, F-OUT-005 |
| D-056 | F-VISUAL-001, F-VISUAL-002, F-VISUAL-003 |
| D-035 | F-P0-VITORA-001, F-P0-VITORA-003 |
| D-036 | F-P0-VITORA-002, F-P0-RECORD-001 |
| D-037 | F-P0-TODAY-002, F-P0-CYCLE-001, F-P0-CYCLE-002, F-OUT-009 |
| D-038 | F-VISUAL-001 to F-VISUAL-005, F-OUT-010 |
| D-039 | F-SOURCE-005, F-SOURCE-006 |
| D-040 | F-IMPL-001, F-IMPL-002, F-IMPL-003, F-IMPL-004 |

## 8. 使用规则

后续 specs 必须引用本文件的 Fact ID。若发现派生规格仍要求旧 Luna 产品角色、旧 Cycle 日历首页、旧 Today 独立记录区、旧沉浸聊天、Apple Health dashboard 视觉或 smooth orb / human avatar IP，必须先修正派生规格，再继续实现。
