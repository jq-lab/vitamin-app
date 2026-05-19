# Vitora Tab Spec Pack

> 日期：2026-05-07
> 范围：Vitora Tab assistant surface，尤其是 Quick Context 选择 `周期` 后的展开态。

## 先读顺序

后续任何 agent 如果要改 Vitora Tab、Quick Context、Input Dock、assistant hero 或周期上下文展开态，必须先读：

1. `README.md`
2. `vitora-page-spec.md`
3. `implementation-contract.md`
4. `qa-checklist.md`
5. `change-log.md`

如果涉及 Pixel Vitora 的造型、材质、表情、道具或动效，还必须同时读取：

```text
../pixel-vitora-ip/README.md
../pixel-vitora-ip/pixel-vitora-ip-spec.md
```

## 当前 Baseline

| 类型 | 路径 |
| --- | --- |
| 目标图 · 默认 Vitora Tab | `assets/design_04/vitora_tab.png` |
| 目标图 · 周期 chip 展开态 | `assets/design_04/vitora_chip_clicked.png` |
| 旧实现证据 | `ios/QA/Screenshots/ImplementationV1/04-vitora-optimized.png` |
| 当前 App baseline | `ios/QA/Screenshots/ImplementationV1/18-vitora-target-aligned.png` |
| Pixel Vitora IP baseline | `ios/QA/Screenshots/ImplementationV1/15-ip-glass-simulator-visible.png` |

## 硬规则

Vitora Tab 是 Vitora 居住的 assistant surface，不是 dashboard、功能宫格、空聊天页或 Cycle 首页。后续细节只能在当前玻璃像素小球 IP 基础上扩展，不能重设角色方向。

周期上下文展开卡只表示“这次提问带入周期背景”，不得把 Vitora Tab 改成周期首页，也不得新增第四个 Tab。
