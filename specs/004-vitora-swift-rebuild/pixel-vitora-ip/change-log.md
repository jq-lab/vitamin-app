# Pixel Vitora Change Log

> 每次 Pixel Vitora 相关改动都必须追加记录。没有记录的 IP 改动视为 handoff 不完整。

## 2026-05-24 · PixelGlassEggContainer Home Renderer

| 字段 | 内容 |
| --- | --- |
| 目的 | 按用户提供的蓝晶蛋参考图，把 Today 首页主蛋从简单蓝晶 `PixelEggView` 提升为低像素霜态玻璃数字蛋容器，要求透明冰蓝蛋壳、voxel 阶梯边缘、蓝色像素星星和约 60% 可见晶体填充。 |
| 改动 | 在 `PixelEggView.swift` 新增 `PixelGlassEggContainer`：使用 `Canvas + TimelineView` 自绘蛋形 mask、像素晶格、阶梯 rim、内部发光晶体、星星贴片、呼吸/漂浮/高光扫过和点击回弹扩散；Today 首页主蛋改用新组件，小尺寸头像继续保留旧 `PixelEggView`，避免缩小后细节噪声过重。 |
| 主要文件 | `ios/Vitora/Core/DesignSystem/PixelEggView.swift`、`ios/Vitora/Features/TodayFeature/EggCompoundView.swift` |
| 规格来源 | 用户 2026-05-24 PixelGlassEggContainer 计划、`F-VISUAL-004`、`C-TODAY-003`、`IAC-T-002`。 |
| 构建结果 | `xcodebuild -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 ENABLE_USER_SCRIPT_SANDBOXING=NO build` 通过。 |
| 模拟器结果 | 已安装并启动到 iPhone 17 Pro Simulator，截图保存到 `ios/QA/Screenshots/PixelGlassEggContainer/today-pixel-glass-egg-home-v2.png`。 |
| 未解决问题 | 本轮只替换 Today 首页主蛋；右侧半圆弧轨道、快捷记录页和小尺寸消息头像不在本轮范围。 |

## 2026-05-22 · Today Blue Crystal Pixel Egg Variant

| 字段 | 内容 |
| --- | --- |
| 目的 | 按 D-065，把 Today 首页主视觉从旧能量碗/琥珀蛋推进到蓝晶混合 Pixel Egg，并承接图4的蓝白晶体、水感和像素眼方向。 |
| 改动 | `PixelEggView` 增加 `blueCrystal` 材质：半透明蓝白外壳、像素晶格、水感内部颗粒、白/蓝像素眼和冷色柔光；只作为 Today 首页蛋形主视觉变体，仍保留 Pixel Vitora 身份。 |
| 主要文件 | `ios/Vitora/Core/DesignSystem/PixelEggView.swift` |
| 规格来源 | D-065、`F-VISUAL-004`、`C-TODAY-003`。 |
| 构建结果 | `xcodebuild -workspace Vitora.xcworkspace -scheme Vitora -destination id=EE0BC9AB-70C1-40F5-B13E-9C11F748E697 ENABLE_USER_SCRIPT_SANDBOXING=NO build` 通过。 |
| 未解决问题 | 若后续继续提高还原度，应只扩展统一 `PixelEggView` 的材质参数，不得在 Today 页面局部重画 smooth orb、人像、宠物或普通 icon。 |

## 2026-05-16 · Frosted Material Variants

| 字段 | 内容 |
| --- | --- |
| 目的 | 修正 Vitora 聊天页中 IP 过彩、过实体、位置不稳定的问题，让它符合“白色霜态外壳为主，内部局部透彩”的新 baseline。 |
| 改动 | `PixelVitoraView` 增加 `materialStyle`：`standard / heroCompanion / messageAvatar / tabFace / ambientBackground`；不同场景只调白色外壳、局部色彩、glow 和 blur 强度，不改变角色方向。消息头像进一步强化乳白磨砂方形和分段低像素眼。 |
| 主要文件 | `ios/Vitora/Core/DesignSystem/PixelVitoraView.swift` |
| 构建结果 | `xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/vitora-derived-header-ip build` 通过。 |
| UI 测试结果 | `VitoraAssistantSurfaceUITests`、`VisualLanguageSmokeTests` 通过，3 tests passed，0 failed。 |
| 未解决问题 | 若后续继续调 IP，还应只调整统一组件的材质参数和状态，不得在单个页面重画新的小人。 |

## 2026-05-14 · New Soft Character Baseline And White Pixel Eyes

| 字段 | 内容 |
| --- | --- |
| 目的 | 按用户最新图一，把全 app 的 Pixel Vitora 从“小彩色 icon / 蓝青点阵柱眼”推进到“柔体彩色小人”：磨砂乳白外壳、粉橙暖黄主体、白色低像素块眼。 |
| 改动 | 更新统一 `PixelVitoraView`：重塑有机小人轮廓、加强暖色云雾、弱化青蓝为边缘空气感、增加 frosted skin 叠层、把眼睛改为白色低像素块眼；所有页面继续通过统一组件继承新 baseline。 |
| 主要文件 | `ios/Vitora/Core/DesignSystem/PixelVitoraView.swift` |
| Baseline 参考 | 用户 2026-05-14 新柔体彩色小人参考图。 |
| 构建结果 | `xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` 通过。 |
| UI 测试结果 | `VitoraAssistantSurfaceUITests`、`VisualLanguageSmokeTests` 通过，3 tests passed，0 failed。 |
| 模拟器结果 | 已安装并启动到 iPhone 17 Pro Simulator，导出 `ios/QA/Screenshots/ImplementationV1/34-vitora-new-ip-folder-hero.png`、`35-today-new-ip.png`、`36-cycle-new-ip.png`。 |
| 未解决问题 | 当前小尺寸 IP 已统一为暖色柔体彩色小人；后续若继续提高还原度，应只微调统一组件的眼睛块大小、磨砂颗粒和轮廓比例，不得逐页单独绘制。 |

## 2026-05-14 · Soft Color Blob IP Baseline

| 字段 | 内容 |
| --- | --- |
| 目的 | 按用户新参考图，把 Pixel Vitora 从旧蓝色玻璃球切换为柔体彩色 blob：半透明乳白外壳、粉橙暖光主体、青蓝/淡紫空气感，并保留像素眼。 |
| 改动 | 在统一 `PixelVitoraView` 内新增有机 blob shape、彩色云雾层、柔白/银白 rim、左上高光、右下冷色透光；保留 `PixelVitoraScene`、状态、道具和页面接入方式，避免逐页重画。 |
| 主要文件 | `ios/Vitora/Core/DesignSystem/PixelVitoraView.swift` |
| Baseline 截图 | `/Users/youxiang/Desktop/Vitora-WaterAura-三页截图/20-vitora-new-blob-ip.png` |
| 构建结果 | `xcodebuild build` 通过。 |
| 模拟器结果 | 已安装并启动到 iPhone 17 Pro Simulator 的 Vitora Tab，截图已导出。 |
| 未解决问题 | 后续如要更贴近参考图，可继续微调 blob 比例、眼睛块大小和星点位置，但不得回退到旧蓝色玻璃球。 |

## 2026-05-07 · Glass Pixel Baseline Lock

| 字段 | 内容 |
| --- | --- |
| 目的 | 把 Pixel Vitora 从普通发光圆形 UI 元素推进到玻璃质感、像素表情、轻悬浮生命感的品牌 IP，并锁定为后续 baseline。 |
| 改动 | 重做玻璃球材质层；加强厚白 rim、蓝青主体光、左上高光、右下透光和底部软阴影；把眼睛改成像素柱；加入随机眨眼；把建议卡 clipboard 改为自绘玻璃道具；让 Today 顶部、今日建议卡、Energy Reveal、底部 Vitora Tab 共用同一套 IP。 |
| 主要文件 | `ios/Vitora/Core/DesignSystem/PixelVitoraView.swift` |
| Baseline 截图 | `ios/QA/Screenshots/ImplementationV1/15-ip-glass-simulator-visible.png` |
| 迭代截图 | `ios/QA/Screenshots/ImplementationV1/13-ip-glass-final.png`、`ios/QA/Screenshots/ImplementationV1/14-ip-glass-final-tuned.png` |
| 构建结果 | `xcodebuild build` 通过。 |
| UI 测试结果 | `TodayPivotUITests` 通过；`VisualLanguageSmokeTests` 通过。 |
| 未解决问题 | 后续如要新增更多表情或道具，必须先扩展本 spec pack，不得直接在页面里单独绘制。 |

## 2026-05-07 · Spec Pack Created

| 字段 | 内容 |
| --- | --- |
| 目的 | 为防止后续上下文丢失后 IP 画风跑偏，建立独立 Pixel Vitora IP 规格包。 |
| 改动 | 新增 `README.md`、`pixel-vitora-ip-spec.md`、`implementation-contract.md`、`visual-evidence.md`、`qa-checklist.md`、`change-log.md`。 |
| 主要文件夹 | `specs/004-vitora-swift-rebuild/pixel-vitora-ip/` |
| Baseline 截图 | `ios/QA/Screenshots/ImplementationV1/15-ip-glass-simulator-visible.png` |
| 文档验证 | 运行 specs 内 Pixel Vitora / smooth orb / Vitora face 检索，确认入口可发现。 |
| 未解决问题 | 后续若新增 IP 任务，应同步 `tasks.md` 或对应新 scope 的任务拆解。 |
