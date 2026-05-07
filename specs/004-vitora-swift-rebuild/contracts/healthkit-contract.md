# Vitora Swift Rebuild · HealthKit Contract

> Contract: healthkit
> 状态：SpecKit tasks 输入

## 0. Rules

| Rule ID | Rule |
| --- | --- |
| HKC-001 | HealthKit 是 P0 可选增强。 |
| HKC-002 | 用户可授权、跳过、拒绝或稍后再开。 |
| HKC-003 | 授权缺席不阻塞 Today / Vitora / Cycle。 |
| HKC-004 | 读取范围必须是 P0 allowlist。 |
| HKC-005 | 读取结果先汇总为 HealthSignal，不把原始样本长期复制。 |
| HKC-006 | HealthKit 状态必须可从轻抽屉重新访问。 |

## 1. P0 Allowlist

| Kind ID | HealthKit Data Kind | P0 Use | Persistence |
| --- | --- | --- | --- |
| HKA-001 | Sleep summary | Today 解释和低数据判断。 | 保存日级摘要或派生状态。 |
| HKA-002 | Step count | 活动趋势摘要。 | 保存日级摘要。 |
| HKA-003 | Active energy | 活动趋势摘要。 | 保存日级摘要。 |
| HKA-004 | Heart rate average | 状态趋势摘要。 | 保存摘要，不存长序列。 |
| HKA-005 | Resting heart rate | 状态趋势摘要。 | 保存摘要，不存长序列。 |
| HKA-006 | Heart rate variability | 状态趋势摘要。 | 保存摘要，不存长序列。 |

新增 HealthKit data kind 必须先更新本文件和 `decision-log.md`。

## 2. Authorization States

| State | App Behavior |
| --- | --- |
| `notAsked` | Onboarding 或 data sources 展示用途说明。 |
| `authorized` | 读取 allowlist summary，更新 HealthSignal。 |
| `skipped` | 进入低数据路径，保留稍后开启入口。 |
| `denied` | 进入低数据路径，说明可从系统设置调整。 |
| `revoked` | 停止读取，失效派生 HealthSignal，保留手动路径。 |

## 3. Tests

| Test ID | Test |
| --- | --- |
| HKT-001 | 用户跳过 HealthKit 后仍进入 Today。 |
| HKT-002 | `denied` 状态不阻塞告诉 Vitora / 手动保存路径。 |
| HKT-003 | 读取范围只包含 HKA-001 到 HKA-006。 |
| HKT-004 | 撤销授权后 Today 进入低数据状态。 |
| HKT-005 | HealthKit 原始样本不进入日志。 |
