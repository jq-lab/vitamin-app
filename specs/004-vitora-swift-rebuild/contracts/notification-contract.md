# Vitora Swift Rebuild · Notification Contract

> Contract: notification
> 状态：SpecKit tasks 输入

## 0. Rules

| Rule ID | Rule |
| --- | --- |
| NTC-001 | P0 通知只服务 A/B 当日意图和晚间复盘。 |
| NTC-002 | 通知权限不是 A/B 选择前置条件。 |
| NTC-003 | 通知内容不包含健康数值、记录原文或 AI 回复。 |
| NTC-004 | 用户可关闭提醒偏好。 |
| NTC-005 | 提醒状态必须可导出、可删除。 |

## 1. Notification Types

| Type ID | Trigger | Payload Content | Linked Models |
| --- | --- | --- | --- |
| NTY-001 | DailyIntention selected and user opts in | Generic gentle reminder, opens app to intention context. | DM-016, DM-017, DM-018 |
| NTY-002 | Evening review available and user opts in | Generic review prompt, opens Vitora review context. | DM-016, DM-019 |

## 2. Scheduling Contract

| Step ID | Requirement |
| --- | --- |
| NTS-001 | Ask notification permission only when user shows reminder intent or opens reminder preference. |
| NTS-002 | Save DailyIntention even if notification permission is not granted. |
| NTS-003 | Store ReminderInstance state after schedule / cancel / fire callback. |
| NTS-004 | Cancel related reminders when DailyIntention is canceled or account removal completes. |
| NTS-005 | Reminder preference only appears in light drawer and relevant A/B / review states. |

## 3. Tests

| Test ID | Test |
| --- | --- |
| NTT-001 | A/B selection without notification permission still saves intention. |
| NTT-002 | Reminder preference off cancels pending P0 reminders. |
| NTT-003 | Notification payload has no sensitive values. |
| NTT-004 | Account removal clears scheduled P0 reminders. |
