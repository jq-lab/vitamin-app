# Vitora 花园玩法素材档案 · 真实花种目录

> 状态：D-058 轻证据层素材  
> 用途：为复盘种子、今日建议、早安/晚安卡和 Cycle 花架证据提供统一花种、花语、资产命名和 2D 低像素视觉规则。  
> 边界：不恢复花园 Tab、花园手册、成长册、花田地图、完成率、连续天数或任务压力。

## 使用原则

- 真实花种只作为“建议 → 反馈”的轻量可视化证据，不作为诊断表达。
- 用户仍然只选择 `恢复 / 留余量 / 轻动` 三个照顾方向；真实花种由 Vitora 根据方向和日期稳定分配。
- 花语取正向、温和、非诊断含义；不同文化解释存在差异，产品文案只保留适合 Vitora 的积极表达。
- 视觉保持 2D 低像素风格；优先使用资产，资产缺失时使用 SwiftUI Canvas fallback。

## 阶段规则

| Score | Stage ID | 展示文案 | 资产后缀 | 视觉规则 |
| --- | --- | --- | --- | --- |
| `<50` | `wilted` | 休眠 | `wilted` | 叶片下垂、低饱和、草坪略暗；不表达失败。 |
| `50-69` | `score60` | 半开 | `60` | 花形清楚但装饰少。 |
| `70-89` | `score80` | 盛开 | `80` | 花瓣完整、颜色更饱满。 |
| `90-100` | `score100` | 成色更好 | `100` | 盛开 + 露水 + 小石子 + 草坪更丰富。 |

资产命名：

```text
flower_{flowerID}_{stageSuffix}
flower_daisy_60
flower_daisy_100
```

## 三方向映射

| 复盘方向 | 候选真实花种 | 说明 |
| --- | --- | --- |
| `recovery` 恢复种子 | 薰衣草、蓝铃花、绣球花 | 偏平静、恢复、理解。 |
| `reserve` 留余量种子 | 白雏菊、山茶花、波斯菊、郁金香 | 偏留白、欣赏、平衡、更新。 |
| `lightMovement` 轻动种子 | 向日葵、牡丹、蓝花楹 | 偏向光、舒展、新生。 |

## 花种目录

| ID | 中文名 | Real Name | 花语 | Vitora 可用含义 |
| --- | --- | --- | --- | --- |
| `daisy` | 白雏菊 | Daisy | 纯真、新开始、希望 | 今天可以从一个很小的开始重新调整。 |
| `sunflower` | 向日葵 | Sunflower | 温暖、积极、向光 | 把注意力转向能让你恢复能量的方向。 |
| `lavender` | 薰衣草 | Lavender | 平静、安宁、温柔守护 | 慢下来不是停下，是给身体留出恢复空间。 |
| `bluebell` | 蓝铃花 | Bluebell | 谦逊、感恩、稳定 | 稳定的小选择，也会慢慢改变今天的节奏。 |
| `camellia` | 山茶花 | Camellia | 欣赏、优雅、感激 | 你已经在认真照顾自己，这件事值得被看见。 |
| `hydrangea` | 绣球花 | Hydrangea | 真诚、理解、感谢 | Vitora 正在从你的反馈里更理解你。 |
| `peony` | 牡丹 | Peony | 丰盛、好运、舒展 | 状态变顺时，你会更自然地展开。 |
| `cosmos` | 波斯菊 | Cosmos | 和谐、秩序、平衡 | 今天先找到一个更平衡的节奏。 |
| `tulip` | 郁金香 | Tulip | 更新、关怀、乐观 | 一点点调整，也是在给明天留新的可能。 |
| `jacaranda` | 蓝花楹 | Jacaranda | 智慧、新生、好运 | 每次复盘，都会让你更懂自己的节律。 |

## 参考来源

- https://www.petalrepublic.com/daisy-flower-meaning/
- https://www.bloomingexpert.com/flower-meaning/sunflower/
- https://www.bloomingexpert.com/flower-meaning/lavender/
- https://scienceinsights.org/what-do-bluebells-symbolize-meanings-and-origins/
- https://www.bloomingexpert.com/flower-meaning/camellia/
- https://localflower.ca/blog/meaning-of-hydrangeas
- https://www.bloomingexpert.com/flower-meaning/peony/
- https://www.petalrepublic.com/cosmos-flower-meaning/
- https://www.flowericon.com/pages/tulip
- https://flowernames.flowersluxe.com/flower-meanings/jacaranda-flower-meaning-symbolism
