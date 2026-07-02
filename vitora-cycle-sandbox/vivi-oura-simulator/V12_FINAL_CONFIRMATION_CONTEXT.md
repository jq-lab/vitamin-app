# V12 最终确认版上下文

本目录是 Vitora 17 Pro 模拟器当前确认版本的源码基线。下一轮 Codex session 请以这个目录为唯一基线继续，不要回到旧版本。

## 当前版本定位

- 版本名：V12 最终确认版
- 主要运行入口：React Native / Expo app
- 关键源码：
  - `App.tsx`
  - `src/simulatorWebPatch.ts`
- WebView HTML 基线资产：
  - `web/index.html`
  - `web/vivi-home.html`
- 本轮确认原则：不再通过修改 HTML 实现新 UI；17 Pro 运行效果以 RN 覆盖层为准。

## 已确认保留的 UI

- “检查 / 探索”页面：保留上一轮已拍定版本。
- “健康 / 我的健康”页面：保留上一轮已拍定版本。
- “今日”页面：当前入口打开后，中间主组件为黄色“今日能量”卡片。
- “注册 / 建档”页面：沿用 HTML onboarding；当 onboarding 打开时，RN 覆盖层应隐藏，避免遮挡注册流程。

## 今日页当前结构

顶部圆圈顺序：

1. 今日 80%
2. 睡眠 +30
3. 专注 -30
4. 代谢 -15
5. 晨间 +10

当前默认打开：

- `nativeTab = "today"`
- `todayActiveId = "today"`
- `APP_DEMO_QUERY = "openTab=today"`

关键特征：

- 黄色“今日能量”主卡片是当前确认版本识别点。
- 每个顶部圆圈可切换中间主卡片。
- “更多”进入对应健康详情。
- 灰色“监测到”条为 AI 监测留言条。

## 17 Pro 部署信息

- 模拟器：iPhone 17 Pro
- 最近使用 UDID：`EE0BC9AB-70C1-40F5-B13E-9C11F748E697`
- Bundle ID：`com.local.vivi.oura`
- 推荐验证：
  - 冷启动检查注册页是否可显示。
  - 完成或关闭注册后进入今日页。
  - 今日页默认显示黄色“今日能量”卡片。
  - 检查 / 健康页仍保持上一轮确认 UI。

## 后续协作约束

- 新 UI 改动优先改 `App.tsx` 和 `src/simulatorWebPatch.ts`。
- 不要把 Figma 临时 asset URL 写入运行时代码。
- 不要用 `git reset`、`git clean`、`expo --clear`、`pod install`、`xcodebuild clean` 清理当前基线。
- 如果需要远端 git push，先确认 V12 目录里的 remote。

