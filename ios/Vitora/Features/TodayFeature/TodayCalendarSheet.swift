import SwiftUI

struct TodayCalendarSheet: View {
    let onClose: () -> Void
    let onAskVitora: () -> Void

    var body: some View {
        detailContainer(title: "周期日历", onClose: onClose) {
            HStack {
                Text("2026年5月")
                    .font(.title3.weight(.bold))
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
                        Text("\(day)")
                            .font(.footnote.weight(day == 5 ? .bold : .regular))
                            .foregroundStyle(day == 5 ? VitoraTheme.ColorToken.paper : VitoraTheme.ColorToken.strongText)
                            .frame(width: 34, height: 34)
                            .background(day == 5 ? VitoraTheme.ColorToken.actionPrimaryDeep : phaseTint(for: day))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(14)
            .background(GlassSurface(cornerRadius: 22, opacity: 0.34))

            Text("选中：5月5日 · 黄体期 Day 18 · 距下次经期约 8 天")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            Text("Vitora 今日建议已参考黄体期和睡眠变化。")
                .font(.footnote)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            Button("告诉 Vitora 日期/感受不准", action: onAskVitora)
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("today.calendar.askVitora")
        }
        .accessibilityIdentifier("today.calendar.sheet")
    }

    private func phaseTint(for day: Int) -> Color {
        switch day {
        case 1...5:
            return Color(red: 255 / 255, green: 214 / 255, blue: 225 / 255).opacity(0.52)
        case 6...14:
            return VitoraTheme.ColorToken.auraBlue.opacity(0.13)
        default:
            return VitoraTheme.ColorToken.lutealGold.opacity(0.18)
        }
    }
}
