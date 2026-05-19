# Pixel Vitora IP Spec Pack

> 规格集：`004-vitora-swift-rebuild`  
> 状态：当前 Pixel Vitora 柔体彩色 blob IP baseline  
> 当前 baseline 截图：用户 2026-05-14 提供的新柔体彩色小人参考图；当前 App 内验收截图以本轮导出的 `34/35/36` 系列为准。

本文件夹是 Pixel Vitora IP 的上下文恢复入口。任何后续设计师、工程师或 agent 只要涉及 Pixel Vitora 的造型、材质、表情、道具、动效或页面接入，必须先读取本文件夹，再进入实现。

硬规则：后续 IP 细节只能在当前“柔体彩色小人 + 半透明乳白磨砂外壳 + 白色低像素眼 + 低幅生命动效”的 Pixel Vitora baseline 上扩展，不能重设角色方向，也不能回退到旧蓝色玻璃球或蓝青点阵柱眼。

## 1. 读取顺序

1. `README.md`：确认当前 baseline、权威文件和恢复路径。
2. `pixel-vitora-ip-spec.md`：严格执行的 IP 规格。
3. `implementation-contract.md`：工程实现边界和接入规则。
4. `visual-evidence.md`：目标参考、当前实现截图和证据等级。
5. `qa-checklist.md`：人工验收、自动验收和反向验收。
6. `change-log.md`：历史改动、测试结果和未解决问题。

若本文件夹与 `facts.md` 冲突，以 `facts.md` 为准；若本文件夹与 `design-tokens.md`、`components.md` 或 `interaction-acceptance.md` 冲突，先同步正式规格，再继续实现。

## 2. 当前 Baseline

当前锁定的 App 内可执行 baseline 是：

```text
用户 2026-05-14 提供的新柔体彩色小人参考图；App 内 baseline 截图随本轮实现输出。
```

它代表当前 SwiftUI 原生 Pixel Vitora 的可复用实现方向：

- 柔软有机小人 blob 主体，不是标准圆球。
- 半透明乳白磨砂外壳。
- 粉橙暖光主体，暖黄作为中心光。
- 青蓝和淡紫只做边缘空气感，不作为第一眼主体色。
- 白色 / 银白柔和 rim。
- 白色低像素块眼，眼睛亮度必须高于内部彩色云雾。
- 左上柔光高光。
- 右下冷色透光。
- 底部软阴影。
- 轻呼吸、轻漂浮、随机眨眼、星点微闪。
- 今日建议卡中的玻璃 clipboard 道具。

## 3. 文件职责

| 文件 | 职责 |
| --- | --- |
| `pixel-vitora-ip-spec.md` | IP 造型、材质、状态、道具、动效和禁用方向的权威规格。 |
| `implementation-contract.md` | 工程接入规则，约束只能通过统一组件扩展 IP。 |
| `visual-evidence.md` | 记录目标图、当前实现图、baseline 选择和证据等级。 |
| `qa-checklist.md` | 每次 IP 改动后的验收清单。 |
| `change-log.md` | 每次 IP 改动的上下文记忆。 |

## 4. 后续改动流程

1. 先读本文件夹全部文件。
2. 判断改动是否保持 baseline，不保持则不得实现。
3. 若需要新增状态、表情或道具，先更新 `pixel-vitora-ip-spec.md` 和 `implementation-contract.md`。
4. 修改统一 SwiftUI 组件后，跑 `qa-checklist.md` 的构建、UI 测试和截图验收。
5. 把改动目的、截图路径、测试结果写入 `change-log.md`。

## 5. 快速恢复提示

下一位 agent 可以从这句话开始：

```text
先读取 specs/004-vitora-swift-rebuild/pixel-vitora-ip/README.md 和 pixel-vitora-ip-spec.md。
当前 Pixel Vitora baseline 是 2026-05-14 新柔体彩色小人：磨砂乳白外壳、粉橙暖黄主体、白色低像素眼。
任何 IP 改动必须继承柔体彩色小人 + 低像素眼形态，只能通过统一 PixelVitoraView / PixelVitoraScene 扩展。
```
