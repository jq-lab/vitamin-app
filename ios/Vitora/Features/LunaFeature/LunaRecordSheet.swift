import SwiftUI

struct LunaRecordSheet: View {
    @ObservedObject var viewModel: LunaViewModel

    private let examples = [
        "今天来月经了，量中等",
        "昨晚睡了 7 小时，深睡偏少",
        "下午 3 点开始有点累",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.lg) {
            ZStack {
                Capsule()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: 42, height: 5)
                    .frame(maxWidth: .infinity)

                HStack {
                    Spacer()

                    Button {
                        viewModel.closeRecordSheetKeepingDraft()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                            .background(VitoraTheme.ColorToken.softSurface)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("关闭记录")
                    .accessibilityIdentifier("luna.record.close")
                }
            }
            .padding(.top, VitoraTheme.Spacing.xs)

            HStack(alignment: .firstTextBaseline) {
                Button {
                    viewModel.recordMode = .quick
                } label: {
                    Text("手动记录")
                        .font(modeFont(.quick))
                        .foregroundStyle(viewModel.recordMode == .quick ? VitoraTheme.ColorToken.primaryText : VitoraTheme.ColorToken.tertiaryText)
                        .overlay(alignment: .bottom) {
                            if viewModel.recordMode == .quick {
                                Capsule()
                                    .fill(VitoraTheme.ColorToken.actionPrimaryDeep)
                                    .frame(height: 3)
                                    .offset(y: 6)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("luna.record.mode.quick")

                Spacer()

                Button {
                    viewModel.recordMode = .naturalLanguage
                } label: {
                    Text("AI 记录")
                        .font(modeFont(.naturalLanguage))
                        .foregroundStyle(viewModel.recordMode == .naturalLanguage ? VitoraTheme.ColorToken.primaryText : VitoraTheme.ColorToken.tertiaryText)
                        .overlay(alignment: .bottom) {
                            if viewModel.recordMode == .naturalLanguage {
                                Capsule()
                                    .fill(VitoraTheme.ColorToken.actionPrimaryDeep)
                                    .frame(height: 3)
                                    .offset(y: 6)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("luna.record.mode.natural")
            }
            .padding(.horizontal, VitoraTheme.Spacing.md)

            if viewModel.recordMode == .naturalLanguage {
                naturalLanguageSection
            } else {
                quickRecordSection
            }

            if let preview = viewModel.parsePreview {
                RecordParsePreview(
                    preview: preview,
                    summary: $viewModel.editableSummary,
                    onSave: viewModel.saveRecord,
                    onCancel: viewModel.cancelRecord
                )
            } else {
                Button(action: viewModel.parseDraft) {
                    HStack {
                        Text(viewModel.recordMode == .naturalLanguage ? "让 Vitora 理解" : "生成确认")
                        Spacer()
                        Image(systemName: "arrow.up")
                    }
                    .font(.callout.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.paper)
                    .padding(.horizontal, VitoraTheme.Spacing.md)
                    .frame(minHeight: VitoraTheme.Size.touchTargetMin)
                    .background(VitoraTheme.ColorToken.shell)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.42 : 1)
                .padding(.horizontal, VitoraTheme.Spacing.md)
                .accessibilityIdentifier("luna.record.parse")
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, VitoraTheme.Spacing.md)
        .padding(.bottom, VitoraTheme.Spacing.lg)
        .background(VitoraTheme.ColorToken.paper)
    }

    private var naturalLanguageSection: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.md) {
            Text("用一句话，记经期、睡眠或能量")
                .font(.title3.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            Text("Vitora 觉得你可以这样试：")
                .font(.caption)
                .foregroundStyle(Color(red: 184 / 255, green: 184 / 255, blue: 189 / 255))

            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
                ForEach(examples, id: \.self) { example in
                    Button {
                        viewModel.selectExample(example)
                    } label: {
                        Text(example)
                            .font(.subheadline)
                            .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                            .padding(.horizontal, VitoraTheme.Spacing.md)
                            .frame(minHeight: 40)
                            .background(VitoraTheme.ColorToken.paper)
                            .overlay(
                                Capsule()
                                    .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            TextField("写一句今天发生的事", text: $viewModel.draftText)
                .font(.body)
                .textFieldStyle(.plain)
                .padding(VitoraTheme.Spacing.md)
                .frame(minHeight: 76, alignment: .topLeading)
                .background(VitoraTheme.ColorToken.softSurface)
                .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.lg, style: .continuous))
                .accessibilityIdentifier("luna.record.input")
        }
        .padding(.horizontal, VitoraTheme.Spacing.md)
    }

    private var quickRecordSection: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.md) {
            HStack(spacing: VitoraTheme.Spacing.lg) {
                Text("身体")
                    .font(.headline)
                    .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                Text("心情")
                    .font(.subheadline)
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                Text("想法")
                    .font(.subheadline)
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
            }

            RecordQuickTypeGrid(
                selectedType: viewModel.selectedQuickType,
                onSelect: viewModel.selectQuickType
            )

            TextField("补充一句描述", text: $viewModel.draftText)
                .font(.body)
                .textFieldStyle(.plain)
                .padding(VitoraTheme.Spacing.md)
                .frame(minHeight: 58, alignment: .topLeading)
                .background(VitoraTheme.ColorToken.softSurface)
                .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.lg, style: .continuous))
                .accessibilityIdentifier("luna.record.input")
        }
        .padding(.horizontal, VitoraTheme.Spacing.md)
    }

    private func modeFont(_ mode: LunaViewModel.RecordMode) -> Font {
        viewModel.recordMode == mode ? .title3.weight(.bold) : .title3.weight(.regular)
    }
}
