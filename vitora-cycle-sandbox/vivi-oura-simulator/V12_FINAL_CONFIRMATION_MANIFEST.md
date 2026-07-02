# V12 最终确认版清单

## 包含内容

- React Native / Expo 应用源码
- iOS 工程文件
- WebView 基线 HTML 资产
- 当前确认版上下文说明
- 当前确认版 git 本地标记

## 不建议纳入压缩包的生成物

- `node_modules`
- `.expo`
- `ios/build`
- Xcode DerivedData

这些内容可由锁文件和工程配置重新生成，保留会让 V12 包体过大。

## 关键验收点

- 今日页默认黄色“今日能量”卡片。
- 检查页保持上一轮确认 UI。
- 健康页保持上一轮确认 UI。
- 注册页通过 HTML onboarding 恢复显示。
- 17 Pro 安装包 Bundle ID 为 `com.local.vivi.oura`。

## Git 标注建议

- 分支名：`final-confirmation-v12`
- 标签名：`v12-final-confirmation`
- 提交信息：`最终确认版 V12`

如果 V12 本地仓库没有 remote，下轮需要先执行：

```bash
git remote add origin <你的仓库地址>
git push -u origin final-confirmation-v12
git push origin v12-final-confirmation
```

