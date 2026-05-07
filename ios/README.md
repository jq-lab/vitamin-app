# Vitora iOS

本目录是 `004-vitora-swift-rebuild` 的原生 Swift / SwiftUI 实现入口。

## 当前阶段

- 当前完成度：P0 Swift MVP through Phase 18 Final QA
- 工程：`ios/Vitora.xcodeproj`
- scheme：`Vitora`
- 主要范围：
  - Onboarding：无账号门槛，HealthKit 可跳过，低数据模式可进入 Today。
  - Today：`现在状态 → 身体要素 → Vitora 今日建议`，无独立打卡/记录区。
  - Energy Reveal：Today 顶部下拉显示 Energy Ball 仪式层。
  - Vitora：AI-native assistant surface，包含 Pixel Vitora、上下文、直接问、快捷上下文和 input dock。
  - Contextual Sheet：从 Today / Cycle 对象唤醒 Vitora 时保留来源上下文。
  - Cycle：长期节律背景 + 能量动态，Cycle 首页不承担日历首页。
  - Support：Cycle 右上设置入口只显示 P0 支撑项。
  - Trust：隐私、AI fallback、合规表达和日志边界已加固。

## 构建

当前本机验证 destination：

```bash
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1' build
```

## 测试

推荐完整测试命令：

```bash
xcodebuild -project ios/Vitora.xcodeproj -scheme Vitora -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1' -parallel-testing-enabled NO test
```

最近一次完整验证：

- 时间：2026-05-07 08:33 CST
- 结果：109 个测试通过，0 failed，0 skipped
- 设备：iPhone 17 Simulator，iOS 26.4.1
- 输出：`ios/QA/Reports/xcodebuild-test.txt`
- xcresult：`/tmp/vitora-final-qa-20260507c.xcresult`

补充 QA：

- Final manual QA checklist：`ios/QA/manual-qa.md`
- Quickstart 执行结果：`ios/QA/quickstart-results.md`
- 反向验收：`ios/QA/Reports/reverse-acceptance-scan.txt`
- 最终截图：`ios/QA/Screenshots/Final/`
- 限制表达扫描：`ios/QA/Scripts/restricted-expression-scan.sh` 已通过

## 最终截图

| 场景 | 路径 |
| --- | --- |
| Onboarding | `ios/QA/Screenshots/Final/01-onboarding.png` |
| Today | `ios/QA/Screenshots/Final/02-today-home.png` |
| Energy Reveal | `ios/QA/Screenshots/Final/03-energy-reveal.png` |
| Vitora Tab | `ios/QA/Screenshots/Final/04-vitora-tab.png` |
| Contextual Vitora Sheet | `ios/QA/Screenshots/Final/05-contextual-vitora-sheet.png` |
| Cycle | `ios/QA/Screenshots/Final/06-cycle-home.png` |
| Support | `ios/QA/Screenshots/Final/07-support-settings.png` |
| Evening Review | `ios/QA/Screenshots/Final/08-evening-review.png` |

## Migration Debt

- 代码内部仍保留部分 `Luna*` 类型、测试名或历史服务名，作为 migration debt。用户面对文案、新 IA 和正式规格均使用 `Vitora`。
- P0 语音入口已存在可访问入口和状态规则，但真实录音、转写和语音理解不属于当前 P0。
- 视觉已落地 Aura Glass / Pixel Vitora 方向，但商业级细节仍应继续通过 Figma 和截图做逐轮视觉微调。

## 持久化选择

- `PersistenceClient` 协议、`RepositoryRegistry` 和测试用 `InMemoryPersistenceClient` 已建立。
- 测试适配器对敏感 payload 使用 CryptoKit AES-GCM 保护，密钥由 `SecureKeyStoring` 提供。
- 后续生产数据库 wrapper 仍建议优先使用 GRDB + SQLCipher。
- 不允许 feature 直接访问数据库细节；所有读写必须经过 repository 或 domain service。

## 规格入口

实现必须优先读取：

- `specs/004-vitora-swift-rebuild/facts.md`
- `specs/004-vitora-swift-rebuild/spec.md`
- `specs/004-vitora-swift-rebuild/tasks.md`
- `specs/004-vitora-swift-rebuild/quickstart.md`

不要重建旧 RN / Expo 结构，不要恢复旧 Luna 用户文案，不要把 Today / Vitora / Cycle 改回 pivot 前 IA。
