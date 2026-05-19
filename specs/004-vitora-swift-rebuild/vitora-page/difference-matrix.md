# Vitora Tab Difference Matrix

| 区域 | 目标图 `vitora_chip_clicked.png` | 旧实现 `04-vitora-optimized.png` | 当前 `18-vitora-target-aligned.png` | 状态 |
| --- | --- | --- | --- | --- |
| Hero 空间 | 大 Pixel Vitora 在背景建立居住感，前景双栏玻璃卡。 | 更像竖向功能栈，IP 与上下文分散。 | 已改为背景大 IP + 双栏上下文卡。 | 已解决 |
| Top controls | 返回、静音、更多是玻璃圆按钮。 | 顶部控制弱或偏普通 header。 | 已加入 44pt 玻璃圆按钮。 | 已解决 |
| Vitora 知道 | 右栏四条上下文，信息密度高。 | 有上下文但层级像卡片列表。 | 已压入右栏，四条上下文固定。 | 已解决 |
| Date strip | 细长玻璃 pill，左右分别是日期和周期。 | 日期上下文不够像当前对话背景。 | 已改为 pill strip。 | 已解决 |
| 消息气泡 | 小 IP face + 玻璃气泡 + 合规短句。 | 对话优先级不够，像功能入口之间的内容。 | 已强化为主线气泡。 | 已解决 |
| 上下文卡 | 选择 topic 后展开当前提问上下文。 | 周期、睡眠、营养结构不一致。 | 已统一为 `VitoraContextSummaryCard`，覆盖周期/睡眠/营养。 | 已解决 |
| Chips | 靠近输入区的小工具带。 | chip 尺寸偏大，解释卡占空间。 | 已改为 compact capsule tool belt。 | 已解决 |
| Input Dock | 语音/键盘、输入或内联语音条、send 一体化玻璃 dock；记录 plus 独立在全局 Dock 右侧。 | 行为完整但视觉顺序和目标图不一致。 | 已重排并保留 voice/text/send 可访问性 id。 | 已解决 |
| Bottom Tab 避让 | 中央 face 低凸起，不遮挡输入 dock。 | 有遮挡风险。 | 输入区 bottom padding 已增加。 | 需截图持续验收 |
| IP 形象 | 保持玻璃像素小球 baseline。 | 已有 baseline。 | 未改 IP 造型，只调整页面尺寸和状态。 | 已锁定 |

## 禁止回退

- 不回到空聊天页。
- 不回到大功能宫格。
- 不把 topic 上下文卡升级成 Cycle 首页。
- 不把 Input Dock 放到 Bottom Tab 后面。
- 不换掉 Pixel Vitora 玻璃像素小球。
