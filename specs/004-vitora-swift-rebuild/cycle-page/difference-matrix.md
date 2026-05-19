# Cycle Page Difference Matrix

> 目标图：`assets/design_04/cycle_d.png`  
> 上一版：`ios/QA/Screenshots/ImplementationV1/05-cycle-optimized.png`  
> 当前 baseline：`ios/QA/Screenshots/ImplementationV1/17-cycle-target-aligned.png`

本文记录 Cycle 页面从上一版到当前 baseline 的差异，帮助后续 agent 判断哪些问题已经解决、哪些仍可优化、哪些方向禁止回退。

## 1. 差异矩阵

| 区域 | 目标状态 | 上一版问题 | 当前 baseline 状态 | 后续处理 |
| --- | --- | --- | --- | --- |
| Header | 紧凑标题 + 左上头像我的 + 右上分享。 | 顶部节奏偏松，Tip 占据上半区。 | 已压缩标题；左上头像和右上分享均保持 44pt 触控。 | 保持；不要做大 hero。 |
| Profile / settings / share | 头像是用户设置入口，不是 IP；分享只导出周期卡片截图。 | 视觉上可用但重量偏大。 | 头像为左上玻璃圆；右上为原生分享入口。 | 保持；不得替换为 Pixel Vitora，不导出隐藏健康数据。 |
| 阶段关系卡 | 小标题、Day 18、黄体期、阶段轴、两条 Vitora 信息、小 IP。 | IP 偏右上装饰，内部 spacing 偏松。 | 已改为目标图结构，小 IP 在右下。 | 可继续微调密度，不改结构。 |
| 阶段轴 | 低饱和四色阶段，当前黄体暖金，今天小标记。 | 节点和线条偏重。 | 已缩小节点和 label，保留今天标记。 | 可微调曲线与节点间距。 |
| 能量动态卡 | 日/周/月、62%、↑5%、平滑曲线、今天 68% callout。 | 图表偏折线，callout 默认不出现。 | 已改平滑曲线，默认显示 `今天 68%`。 | 可继续优化图表 token。 |
| 图表信息量 | 单曲线 + 高中低轴 + Vitora 叙事。 | 缺 y 轴标签，dashboard 感偏弱但信息不完整。 | 已补 `高 / 中 / 低` 和叙事行小 IP。 | 不增加多指标墙。 |
| Tip pill | 轻提示长按问 Vitora / 校准。 | Tip 在 header 下方，抢首屏。 | 已移至能量卡下方。 | P1 可做一次性出现/消失。 |
| Tab 避让 | 底部 Tab 低凸起，不遮挡内容。 | 页面底部避让不够稳定。 | 当前首屏可见 Tip 和 Tab；能量叙事未被遮挡。 | 继续保持 tabBarHeight + 避让。 |
| Pixel Vitora | 使用统一玻璃像素小球 baseline。 | IP 位置和大小不够像目标图。 | 页面内小 IP 均使用统一 `PixelVitoraScene`。 | 任何 IP 变动先读 `pixel-vitora-ip/`。 |

## 2. 已解决

- Cycle 首页不再像日历入口或基础概览。
- Header 和两张主卡已形成目标图式首屏层级。
- 阶段卡右下小 IP 与 chevron 已对齐“轻陪伴入口”。
- 能量卡已补日/周/月、趋势摘要、平滑曲线和默认今天 callout。
- 我的头像与分享视觉圆保持小，但触控为 44pt。
- 自动 UI 回归已覆盖 Cycle、视觉语言和可访问性。

## 3. 仍可优化

- Tip pill 可在后续接入一次性 TipKit 出现/消失逻辑。
- 阶段轴可继续精细调整曲线弧度和节点对齐。
- 能量曲线可进一步抽象成 chart token，供详情页共享。
- 低数据、低置信、阶段不准等状态仍需更完整的视觉矩阵。

## 4. 禁止回退

- 不把 Cycle 首页改回日历。
- 不把阶段卡改成科普墙。
- 不把能量卡改成复杂医疗 dashboard。
- 不加入任务、打卡、完成率、连续天数或红点。
- 不替换 Pixel Vitora IP 形象。
- 不把左上 profile/settings 当成 Vitora 角色入口；不让右上分享导出记录原文或隐藏健康数据。
