import SwiftUI

struct TodayCalendarSheet: View {
    let selectedCycleDay: Int
    let onSelectCycleDay: (Int) -> Void
    let onClose: () -> Void
    let onAskVitora: () -> Void

    var body: some View {
        detailContainer(title: "周期日历", subtitle: "今天在周期时间线上的位置", onClose: onClose) {
            HStack {
                Text("2026年5月")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Spacer()
                Button("今天", action: {})
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
            }

            VStack(spacing: 12) {
                HStack {
                    ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(1...28, id: \.self) { day in
                        Button {
                            onSelectCycleDay(cycleDay(forCalendarDay: day))
                        } label: {
                            Text("\(day)")
                                .font(.footnote.weight(isSelectedCalendarDay(day) ? .bold : .regular))
                                .foregroundStyle(isSelectedCalendarDay(day) ? VitoraTheme.ColorToken.paper : VitoraTheme.ColorToken.strongText)
                                .frame(width: 34, height: 34)
                                .background(isSelectedCalendarDay(day) ? VitoraTheme.ColorToken.actionPrimaryDeep : phaseTint(for: day))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(VitoraTheme.ColorToken.paper.opacity(isSelectedCalendarDay(day) ? 0.92 : 0.0), lineWidth: 1.2)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("选择 5月\(day)日")
                        .accessibilityIdentifier("today.calendar.day.\(day)")
                    }
                }
            }
            .padding(14)
            .background(GlassSurface(cornerRadius: 22, opacity: 0.62, shadowStrength: 0.34, variant: .cleanElevated))

            Text("选中：\(selectedSummary)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            VStack(alignment: .leading, spacing: 6) {
                Text("Vitora 洞察")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text("今日建议已参考黄体期、睡眠变化和午后低谷窗口。")
                    .font(.subheadline.weight(.medium))
                    .lineSpacing(3)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GlassSurface(cornerRadius: 20, opacity: 0.66, shadowStrength: 0.24, variant: .cleanResting))

            Text("返回 Today 后，背景会跟随当前周期阶段轻柔变色。")
                .font(.footnote)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            Button("告诉 Vitora 日期/感受不准", action: onAskVitora)
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("today.calendar.askVitora")
        }
        .accessibilityIdentifier("today.calendar.sheet")
    }

    private func phaseTint(for day: Int) -> Color {
        switch DynamicAuraVariant.cycleVariant(for: cycleDay(forCalendarDay: day)) {
        case .menstrual:
            return Color(red: 255 / 255, green: 214 / 255, blue: 225 / 255).opacity(0.52)
        case .follicular:
            return VitoraTheme.ColorToken.auraBlue.opacity(0.13)
        case .ovulation:
            return VitoraTheme.ColorToken.success.opacity(0.16)
        case .luteal:
            return VitoraTheme.ColorToken.lutealGold.opacity(0.18)
        case .base:
            return VitoraTheme.ColorToken.auraCyan.opacity(0.12)
        }
    }

    private var selectedSummary: String {
        let dateDay = ((selectedCycleDay + 14) % 28) + 1
        let phase = DynamicAuraVariant.cycleVariant(for: selectedCycleDay).phaseLabel
        return "5月\(dateDay)日 · \(phase) Day \(selectedCycleDay)"
    }

    private func isSelectedCalendarDay(_ day: Int) -> Bool {
        cycleDay(forCalendarDay: day) == selectedCycleDay
    }

    private func cycleDay(forCalendarDay day: Int) -> Int {
        ((day + 12) % 28) + 1
    }
}
