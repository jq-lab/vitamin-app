# Vitora Swift Rebuild · Persistence Contract

> Contract: persistence
> 状态：SpecKit tasks 输入

本文档定义保存、加密、导出、删除和日志边界。它不定义数据库 schema；schema 必须从 `DM-*` 映射，并在任务阶段细化。

## 0. Persistence Rules

| Rule ID | Rule | Source |
| --- | --- | --- |
| PC-001 | DC-02 / DC-03 数据保存前必须进入加密存储。 | DP-001, DP-002 |
| PC-002 | DC-00 UI 状态不得混入健康内容。 | DC-00 |
| PC-003 | DC-05 默认临时，除非用户确认保存为 P0 领域对象。 | DC-05, AI-001 |
| PC-004 | Keychain 管理本地密钥，不把密钥写入普通 app storage。 | F-PRIVACY-002 |
| PC-005 | 日志只记录事件类别、状态类别和非敏感 ID。 | LG-001 to LG-005 |
| PC-006 | 导出覆盖 P0 已保存用户数据。 | EX-001 to EX-003 |
| PC-007 | 账号移除清除本地数据、密钥、导出暂存和 app gate 状态。 | EX-004 to EX-006 |

## 1. Model Persistence Matrix

| Models | Storage Class | Notes |
| --- | --- | --- |
| DM-001, DM-002 | Encrypted local table | 用户偏好和 onboarding context 可导出、可删除。 |
| DM-003, DM-013, DM-014 | Lightweight state | 可轻持久，但不得保存健康内容。 |
| DM-004, DM-017, DM-018 | Encrypted local table + system permission mirror | 保存状态类别，不保存通知敏感正文。 |
| DM-005 | HealthKit-derived summary / encrypted cache | 原始 HealthKit 样本优先按需读取；只缓存 P0 摘要。 |
| DM-006, DM-007 | Encrypted local table / derived view | Cycle 基础上下文可导出、可删除。 |
| DM-008, DM-009, DM-010 | Encrypted local table | 记录、理解结果和营养补给条目。 |
| DM-011, DM-012, DM-015, DM-020 | Derived cache | 可重建；删除来源时必须失效。 |
| DM-016, DM-019 | Encrypted local table | 学习闭环核心数据。 |
| DM-021 | Encrypted local table | 对话消息最小化保存。 |
| DM-022, DM-023 | Transient only | 默认不长期存储。 |
| DM-024, DM-025 | Encrypted control record | 导出 / 账号移除状态可追踪。 |

## 2. Export Contract

| Export ID | Requirement |
| --- | --- |
| EXP-001 | 导出必须由用户主动确认。 |
| EXP-002 | 导出范围包含 onboarding context、手动记录、A/B 意图、复盘反馈、营养补给、Cycle 基础上下文、提醒偏好和数据控制记录。 |
| EXP-003 | 导出文件准备期间必须有 `preparing`、`ready`、`completed` 或 `error` 状态。 |
| EXP-004 | 导出暂存文件不得长期保留。 |
| EXP-005 | 导出失败必须允许重试或取消。 |

## 3. Account Removal Contract

| Removal ID | Requirement |
| --- | --- |
| ARM-001 | 账号移除需要二次确认。 |
| ARM-002 | 完成后清除 local database、Keychain key、derived cache、notification requests 和 export temp files。 |
| ARM-003 | 完成后 app route 回到 AppGate 新开始状态。 |
| ARM-004 | 如果中途失败，必须显示可理解恢复路径，不露出底层技术细节。 |

## 4. Persistence Tests

| Test ID | Test |
| --- | --- |
| PCT-001 | 保存用户确认的 Vitora 记录/理解后 app 重启仍可读取。 |
| PCT-002 | A/B 选择后 EveningReviewService 能读取当日意图。 |
| PCT-003 | 删除 NutritionEntry 后 Today / Vitora 派生状态失效。 |
| PCT-004 | 导出包含所有 P0 保存类型。 |
| PCT-005 | 账号移除后 AppGate 进入新开始状态，旧数据不可读。 |
| PCT-006 | 日志测试确认不含记录原文、HealthKit 数值或 AI prompt。 |
