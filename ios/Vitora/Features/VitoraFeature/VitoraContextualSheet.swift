import SwiftUI

struct VitoraContextualSheet: View {
    let context: VitoraContextPayload
    let onClose: () -> Void
    @State private var input = ""
    @State private var selectedChips: Set<String> = []
    @State private var isVoiceRecording = false
    @State private var showsUnderstanding = false
    @State private var showsSaved = false
    @State private var selectedTab: RecordTab = .daily

    private enum RecordTab: String, CaseIterable {
        case daily
        case period

        var label: String {
            switch self {
            case .daily: return "日常"
            case .period: return "经期"
            }
        }

        var icon: String {
            switch self {
            case .daily: return "sun.max.fill"
            case .period: return "drop.fill"
            }
        }
    }

    // ── Daily chips (from original quick supplement)
    private let dailyChips = [
        "睡得浅", "压力大", "腹胀", "喝咖啡", "运动了", "吃得少",
        "心情好", "头痛", "焦虑", "久坐", "喝酒了", "加班熬夜",
    ]

    // ── Period: status chips
    private let periodStatusChips = ["经期来了", "经期结束", "量偏多", "量偏少", "量适中"]

    // ── Period: pain level
    private let painLevels = ["无痛经", "轻微", "明显", "严重"]

    // ── Period: symptom chips (from reference: 压力/多囊/甲状腺/乳房胀痛/腰酸/头痛/水肿/长痘/失眠/疲惫/情绪波动/食欲变化)
    private let symptomChips = [
        "乳房胀痛", "腰酸", "头痛", "长痘",
        "水肿", "食欲变化", "失眠", "疲惫",
        "情绪波动", "怕冷", "腹泻", "便秘",
    ]

    // ── Colors
    private let dailyFill = Color(red: 255 / 255, green: 243 / 255, blue: 234 / 255)
    private let periodFill = Color(red: 234 / 255, green: 240 / 255, blue: 252 / 255)
    private let dailyTabColor = Color(red: 255 / 255, green: 225 / 255, blue: 205 / 255)
    private let periodTabColor = Color(red: 200 / 255, green: 218 / 255, blue: 248 / 255)

    private var activeFill: Color {
        selectedTab == .daily ? dailyFill : periodFill
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Drag handle
            Capsule()
                .fill(Color.gray.opacity(0.35))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 8)

            // ── Folder tabs
            HStack(spacing: 0) {
                ForEach(RecordTab.allCases, id: \.self) { tab in
                    folderTabButton(tab)
                }
            }
            .padding(.horizontal, 16)

            // ── Content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    switch selectedTab {
                    case .daily: dailyContent
                    case .period: periodContent
                    }

                    if showsUnderstanding {
                        understandingCard
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 100)
            }

            Spacer(minLength: 0)

            // ── Input dock pinned to bottom
            VitoraInputDock(
                text: $input,
                placeholder: selectedTab == .period ? "描述经期状况..." : "告诉 Vitora 一件事...",
                isVoiceRecording: isVoiceRecording,
                voiceSignal: isVoiceRecording ? .listeningPreview : .idle,
                onVoice: { isVoiceRecording.toggle() },
                onSend: {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
                        showsUnderstanding = true
                        showsSaved = false
                    }
                }
            )
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
        .background(activeFill)
        .animation(.easeOut(duration: 0.22), value: selectedTab)
    }

    // MARK: - Folder Tab

    private func folderTabButton(_ tab: RecordTab) -> some View {
        let isSelected = selectedTab == tab
        let tabBg = tab == .daily ? dailyTabColor : periodTabColor
        let fillBg = tab == .daily ? dailyFill : periodFill

        return Button {
            withAnimation(.easeOut(duration: 0.22)) {
                selectedTab = tab
                showsUnderstanding = false
                showsSaved = false
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 13, weight: .bold))
                Text(tab.label)
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(isSelected
                ? VitoraTheme.ColorToken.strongText
                : VitoraTheme.ColorToken.secondaryText.opacity(0.62))
            .frame(maxWidth: .infinity)
            .frame(height: isSelected ? 44 : 38)
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 16,
                    style: .continuous
                )
                .fill(isSelected ? fillBg : tabBg.opacity(0.48))
            )
            .offset(y: isSelected ? 2 : 6)
        }
        .buttonStyle(.plain)
        .zIndex(isSelected ? 1 : 0)
        .accessibilityIdentifier("vitora.context.tab.\(tab.rawValue)")
    }

    // MARK: - Daily

    private var dailyContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("快捷补充")

            LazyVGrid(columns: chipColumns(3), spacing: 8) {
                ForEach(dailyChips, id: \.self) { chip in
                    multiChip(chip)
                }
            }
        }
    }

    // MARK: - Period

    private var periodContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Status
            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("经期状态")

                LazyVGrid(columns: chipColumns(3), spacing: 8) {
                    ForEach(periodStatusChips, id: \.self) { chip in
                        multiChip(chip)
                    }
                }
            }

            // Pain level
            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("痛经程度")

                HStack(spacing: 8) {
                    ForEach(painLevels, id: \.self) { level in
                        exclusiveChip(level, group: painLevels)
                    }
                }
            }

            // Symptoms
            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("记录症状")

                Text("可多选，Vitora 会综合判断")
                    .font(.caption)
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)

                LazyVGrid(columns: chipColumns(4), spacing: 8) {
                    ForEach(symptomChips, id: \.self) { chip in
                        multiChip(chip)
                    }
                }
            }
        }
    }

    // MARK: - Chip Buttons

    private func multiChip(_ chip: String) -> some View {
        let isOn = selectedChips.contains(chip)
        return Button {
            withAnimation(.easeOut(duration: 0.14)) {
                if isOn { selectedChips.remove(chip) } else { selectedChips.insert(chip) }
                input = selectedChips.joined(separator: "、")
                showsSaved = false
            }
        } label: {
            Text(chip)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(isOn ? .white : VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 40)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isOn ? VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.82) : Color.white.opacity(0.82))
                        .shadow(color: Color.black.opacity(isOn ? 0.08 : 0.03), radius: 5, x: 0, y: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private func exclusiveChip(_ chip: String, group: [String]) -> some View {
        let isOn = selectedChips.contains(chip)
        return Button {
            withAnimation(.easeOut(duration: 0.14)) {
                // Remove other items in the same group
                for g in group { selectedChips.remove(g) }
                selectedChips.insert(chip)
                input = selectedChips.joined(separator: "、")
                showsSaved = false
            }
        } label: {
            Text(chip)
                .font(.caption.weight(.bold))
                .foregroundStyle(isOn ? .white : VitoraTheme.ColorToken.strongText.opacity(0.72))
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isOn ? VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.78) : Color.white.opacity(0.72))
                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline.weight(.bold))
            .foregroundStyle(VitoraTheme.ColorToken.strongText)
    }

    private func chipColumns(_ count: Int) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: count)
    }

    // MARK: - Understanding Card

    private var understandingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                PixelVitoraView(state: showsSaved ? .idle : .confirming, size: 34, showsGlow: false)
                Text(showsSaved ? "已保存给 Vitora" : "Vitora 理解为")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }

            Text(showsSaved ? "Vitora 会把这件事纳入今天的状态判断。" : "确认后保存为今天的上下文。")
                .font(.subheadline)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            VStack(spacing: 7) {
                infoRow("日期", "今天")
                infoRow("记录", input.isEmpty ? "状态变化" : input)
                infoRow("影响", selectedTab == .period ? "周期 + 经量 + 症状" : "睡眠 + HRV + 周期")
            }
            .padding(12)
            .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            ComplianceLabel(.vitora)

            HStack(spacing: 8) {
                if showsSaved {
                    pill("完成", filled: true, action: onClose)
                } else {
                    pill("确认保存", filled: true) {
                        withAnimation(.easeOut(duration: 0.24)) { showsSaved = true }
                    }
                    pill("修改", filled: false) {
                        withAnimation(.easeOut(duration: 0.18)) { showsUnderstanding = false }
                    }
                    pill("取消", filled: false, action: onClose)
                }
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.76))
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .accessibilityIdentifier("vitora.context.confirm")
    }

    private func pill(_ title: String, filled: Bool, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.caption.weight(.semibold))
            .foregroundStyle(filled ? .white : VitoraTheme.ColorToken.actionPrimaryDeep)
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(filled ? VitoraTheme.ColorToken.actionPrimaryDeep : Color.white.opacity(0.62))
            .clipShape(Capsule())
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .frame(width: 40, alignment: .leading)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
