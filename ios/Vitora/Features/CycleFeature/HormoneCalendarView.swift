import SwiftUI

struct HormoneCalendarView: View {
    let onClose: () -> Void
    @State private var displayedMonth = Date()
    @State private var reminderEnabled = false

    private let currentCycleDay = 18
    private let cycleLength = 28
    private let periodLength = 5
    private let ovulationDay = 14

    private let weekdays = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        ZStack {
            Color(red: 250 / 255, green: 248 / 255, blue: 245 / 255).ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    }
                    Spacer()
                    Text("我的激素")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Spacer()
                    Color.clear.frame(width: 18)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        monthSelector
                        calendarGrid
                        statusTags
                        insightCard
                        complianceText
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    // MARK: - Month Selector

    private var monthSelector: some View {
        HStack {
            Button {
                displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.left")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            Spacer()

            Text(monthYearString)
                .font(.title3.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            Spacer()

            Button {
                displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            Button {
                displayedMonth = Date()
            } label: {
                Text("回今天")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 1, green: 0.98, blue: 0.82), in: Capsule())
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.72))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.58), lineWidth: 0.7))
        )
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        VStack(spacing: 8) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day cells
            let days = daysInMonth()
            let firstWeekday = firstWeekdayOffset()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                // Empty leading cells
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Color.clear.frame(height: 44)
                }

                // Day cells
                ForEach(1...days, id: \.self) { day in
                    dayCell(day: day)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.82))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.58), lineWidth: 0.7))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
    }

    private func dayCell(day: Int) -> some View {
        let phase = cyclePhase(for: day)
        let isToday = isCurrentDay(day)
        let isFuture = isFutureDay(day)

        return ZStack {
            if isToday {
                Circle()
                    .stroke(VitoraTheme.ColorToken.strongText, lineWidth: 2)
                    .frame(width: 40, height: 40)
            } else if !isFuture {
                Circle()
                    .fill(phase.color.opacity(0.55))
                    .frame(width: 40, height: 40)
            }

            Text("\(day)")
                .font(.system(size: 15, weight: isToday ? .bold : .medium))
                .foregroundStyle(isFuture ? VitoraTheme.ColorToken.tertiaryText : VitoraTheme.ColorToken.strongText)
        }
        .frame(height: 44)
    }

    // MARK: - Status Tags

    private var statusTags: some View {
        HStack(spacing: 10) {
            Text("距下次经期还有 12 天")
                .font(.caption.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            Text("黄体期 Day \(currentCycleDay)")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 0.90, green: 0.55, blue: 0.22))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(red: 0.90, green: 0.55, blue: 0.22).opacity(0.12), in: Capsule())
        }
    }

    // MARK: - Insight Card

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("✨").font(.body)
                Text("Vitora 智能洞察")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }

            Text("你的经期 Day 3，还有 2 天结束")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            Text("上月黄体期偏短，本月可能 PMS 提前 3 天出现")
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            HStack {
                Spacer()
                HStack(spacing: 8) {
                    Text("🔔").font(.body)
                    Text("提醒按键")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    Toggle("", isOn: $reminderEnabled)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .tint(VitoraTheme.ColorToken.actionPrimary)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.82))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.58), lineWidth: 0.7))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
    }

    private var complianceText: some View {
        Text("本内容仅供生活方式参考，不构成医疗建议")
            .font(.caption2)
            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private var monthYearString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy 年 MM 月"
        return fmt.string(from: displayedMonth)
    }

    private func daysInMonth() -> Int {
        Calendar.current.range(of: .day, in: .month, for: displayedMonth)?.count ?? 30
    }

    private func firstWeekdayOffset() -> Int {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: displayedMonth)
        guard let firstDay = cal.date(from: comps) else { return 0 }
        let weekday = cal.component(.weekday, from: firstDay)
        // Convert: Sunday=1 → Monday=0
        return (weekday + 5) % 7
    }

    private func isCurrentDay(_ day: Int) -> Bool {
        let cal = Calendar.current
        let today = Date()
        return cal.component(.day, from: today) == day
            && cal.component(.month, from: today) == cal.component(.month, from: displayedMonth)
            && cal.component(.year, from: today) == cal.component(.year, from: displayedMonth)
    }

    private func isFutureDay(_ day: Int) -> Bool {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: displayedMonth)
        guard let date = cal.date(from: DateComponents(year: comps.year, month: comps.month, day: day)) else { return false }
        return date > Date()
    }

    private enum CyclePhase {
        case menstrual, follicular, ovulation, luteal, none
        var color: Color {
            switch self {
            case .menstrual: return Color(red: 0.95, green: 0.62, blue: 0.68) // pink
            case .follicular: return Color(red: 0.72, green: 0.88, blue: 0.72) // green
            case .ovulation: return Color(red: 0.95, green: 0.80, blue: 0.52) // orange
            case .luteal: return Color(red: 0.62, green: 0.78, blue: 0.95) // blue
            case .none: return Color.clear
            }
        }
    }

    private func cyclePhase(for day: Int) -> CyclePhase {
        if isFutureDay(day) { return .none }
        // Simplified: calculate based on assumed cycle start
        let todayDay = Calendar.current.component(.day, from: Date())
        let dayOffset = day - todayDay
        let cycleDay = ((currentCycleDay + dayOffset - 1) % cycleLength + cycleLength) % cycleLength + 1
        if cycleDay <= periodLength { return .menstrual }
        if cycleDay <= 13 { return .follicular }
        if cycleDay <= 16 { return .ovulation }
        return .luteal
    }
}
