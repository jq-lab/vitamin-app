import SwiftUI

struct TodayCalendarSheet: View {
    let selectedCycleDay: Int
    let onSelectCycleDay: (Int) -> Void
    let onClose: () -> Void
    let onAskVitora: () -> Void

    @State private var selectedDay: Int = 5
    @State private var monthOffset: Int = 0
    @State private var showsMoreMenu = false

    private let baseDate = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 1))!

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            topBar
            phaseLegend
            calendarGrid
            memoNote
            memorySection
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 24)
        .accessibilityIdentifier("today.calendar.sheet")
        .onAppear {
            let launchArguments = ProcessInfo.processInfo.arguments
            guard launchArguments.contains("-vitoraUITestCompletedOnboarding") else { return }
            selectedDay = 5
            monthOffset = launchArguments.contains("-vitoraUITestCalendarNextMonth") ? 1 : 0
            if launchArguments.contains("-vitoraUITestCalendarMore") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    showsMoreMenu = true
                }
            }
        }
        .confirmationDialog("更多操作", isPresented: $showsMoreMenu, titleVisibility: .visible) {
            Button("编辑周期设置") {}
            Button("告诉 Vitora 日期/感受不准") { onAskVitora() }
            Button("导出当前页图片") {}
            Button("取消", role: .cancel) {}
        }
    }

    private var visibleDate: Date {
        Calendar.current.date(byAdding: .month, value: monthOffset, to: baseDate) ?? baseDate
    }

    private var monthTitle: String {
        let components = Calendar.current.dateComponents([.year, .month], from: visibleDate)
        return "\(components.year ?? 2026) / \(components.month ?? 5)"
    }

    private var monthNumber: Int {
        Calendar.current.component(.month, from: visibleDate)
    }

    private var calendarCells: [Int?] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: visibleDate)
        let firstDay = calendar.date(from: DateComponents(year: components.year, month: components.month, day: 1)) ?? baseDate
        let range = calendar.range(of: .day, in: .month, for: firstDay) ?? 1..<32
        let weekday = calendar.component(.weekday, from: firstDay)
        let mondayOffset = (weekday + 5) % 7
        return Array(repeating: nil, count: mondayOffset) + range.map { Optional($0) }
    }

    private var topBar: some View {
        HStack(alignment: .center) {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.black.opacity(0.86))
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.66), in: Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 9, x: 0, y: 5)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("返回主页")
            .accessibilityIdentifier("today.calendar.close")

            Spacer(minLength: 10)

            HStack(spacing: 16) {
                monthButton(system: "chevron.left", identifier: "today.calendar.month.prev") {
                    withAnimation(.easeInOut(duration: 0.2)) { monthOffset -= 1 }
                }

                Text(monthTitle)
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundStyle(Color.black.opacity(0.92))
                    .tracking(0.6)
                    .frame(minWidth: 82)

                monthButton(system: "chevron.right", identifier: "today.calendar.month.next") {
                    withAnimation(.easeInOut(duration: 0.2)) { monthOffset += 1 }
                }
            }

            Spacer(minLength: 10)

            Button {
                showsMoreMenu = true
            } label: {
                PearlMoreButton()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("更多操作")
            .accessibilityIdentifier("today.calendar.more")
        }
    }

    private func monthButton(system: String, identifier: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.black.opacity(0.72))
                .frame(width: 28, height: 28)
                .background(Color.white.opacity(0.52), in: Circle())
                .overlay(Circle().stroke(Color.black.opacity(0.045), lineWidth: 0.6))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    private var phaseLegend: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                ForEach(CalendarPhase.allCases) { phase in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(phase.dot)
                            .frame(width: 10, height: 10)
                        Text(phase.title)
                            .font(.system(size: 12.5, weight: .regular))
                            .foregroundStyle(Color.black.opacity(0.78))
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(height: 0.7)
        }
        .padding(.top, 2)
    }

    private var calendarGrid: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: calendarColumns, spacing: 0) {
                ForEach(["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 10.5, weight: .regular))
                        .foregroundStyle(Color.black.opacity(0.58))
                        .tracking(0.35)
                        .frame(height: 20)
                }
            }

            LazyVGrid(columns: calendarColumns, spacing: 8) {
                ForEach(Array(calendarCells.enumerated()), id: \.offset) { _, day in
                    if let day {
                        Button {
                            withAnimation(.easeInOut(duration: 0.16)) {
                                selectedDay = day
                            }
                            onSelectCycleDay(cycleDay(forCalendarDay: day))
                        } label: {
                            CalendarDayCircle(
                                day: day,
                                phase: phase(for: day),
                                isSelected: monthOffset == 0 && day == selectedDay,
                                isReferenceOutline: monthOffset == 0 && day == 4
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(monthNumber)月\(day)日")
                        .accessibilityIdentifier("today.calendar.day.\(day)")
                    } else {
                        Color.clear.frame(height: 32)
                    }
                }
            }
        }
        .padding(.top, 2)
    }

    private var calendarColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    }

    private var memoNote: some View {
        ZStack(alignment: .top) {
            TornMemoShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 255 / 255, green: 248 / 255, blue: 244 / 255),
                            Color(red: 248 / 255, green: 232 / 255, blue: 224 / 255),
                            Color(red: 255 / 255, green: 246 / 255, blue: 240 / 255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(CalendarPaperGrain().opacity(0.40).clipShape(TornMemoShape()))
                .shadow(color: Color.black.opacity(0.06), radius: 11, x: 0, y: 8)

            WashiTape()
                .frame(width: 96, height: 28)
                .offset(y: -14)

            VStack(spacing: 13) {
                HStack(spacing: 8) {
                    Text("\(monthNumber) / \(selectedDay)")
                        .font(.system(size: 22, weight: .regular, design: .serif))
                        .foregroundStyle(Color.black.opacity(0.94))
                        .tracking(0.45)

                    Text("\(phaseName(for: selectedDay)) · Day \(cycleDay(forCalendarDay: selectedDay))")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color(red: 18 / 255, green: 100 / 255, blue: 163 / 255))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Color(red: 216 / 255, green: 237 / 255, blue: 255 / 255), in: Capsule())

                    if monthOffset == 0 && selectedDay == 5 {
                        Text("今天")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color.black.opacity(0.86), in: Capsule())
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 13) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(Color(red: 241 / 255, green: 164 / 255, blue: 48 / 255))
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("下午是你的能量高峰")
                            .font(.system(size: 17, weight: .regular, design: .serif))
                            .foregroundStyle(Color.black.opacity(0.93))
                            .tracking(0.2)
                        Text("适合专注与推进重要任务。")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(Color.black.opacity(0.62))
                    }

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 3)

                thinLine

                HStack(spacing: 0) {
                    CalendarMemoMetric(icon: "bolt.fill", tint: Color(red: 235 / 255, green: 170 / 255, blue: 55 / 255), title: "能量", value: "62%", sub: "较昨日 ↓8%")
                    verticalLine
                    CalendarMemoMetric(icon: "moon.fill", tint: Color(red: 109 / 255, green: 134 / 255, blue: 223 / 255), title: "睡眠", value: "6.4h", sub: "浅 38%")
                    verticalLine
                    CalendarMemoMetric(icon: "face.smiling.fill", tint: Color(red: 230 / 255, green: 115 / 255, blue: 131 / 255), title: "心情", value: "6/10", sub: "下午低落")
                }

                thinLine

                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text("今日记录")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 215 / 255, green: 78 / 255, blue: 97 / 255))
                        Spacer()
                        Text("14:32")
                            .font(.system(size: 12.5, weight: .regular))
                            .foregroundStyle(Color.black.opacity(0.58))
                    }

                    HStack(alignment: .bottom, spacing: 10) {
                        Text("下午有点犯困，靠手冲咖啡续命。\n和合作方对齐整体进行。")
                            .font(.system(size: 13.5, weight: .regular))
                            .foregroundStyle(Color.black.opacity(0.88))
                            .lineSpacing(5)

                        Spacer(minLength: 0)

                        Image(systemName: "paperclip")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color.black.opacity(0.62))
                            .frame(width: 28, height: 28)
                    }
                }
            }
            .padding(.top, 28)
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
        }
        .padding(.top, 13)
        .accessibilityIdentifier("today.calendar.memo")
    }

    private var memorySection: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 15, weight: .regular))
                    Text("我的记忆箱")
                        .font(.system(size: 17, weight: .regular, design: .serif))
                        .tracking(0.2)
                }
                .foregroundStyle(Color.black.opacity(0.9))

                Spacer()

                Text("查看全部  ›")
                    .font(.system(size: 12.5, weight: .regular))
                    .foregroundStyle(Color.black.opacity(0.58))
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 18), GridItem(.flexible(), spacing: 18)], spacing: 12) {
                ForEach(memoryBoxes) { box in
                    WoodenMemoryBox(box: box)
                        .accessibilityIdentifier("today.calendar.memoryBox.\(box.id)")
                }
            }
        }
        .padding(.horizontal, 2)
        .padding(.top, 1)
    }

    private var thinLine: some View {
        Rectangle()
            .fill(Color.black.opacity(0.14))
            .frame(height: 0.7)
    }

    private var verticalLine: some View {
        Rectangle()
            .fill(Color.black.opacity(0.12))
            .frame(width: 0.7, height: 52)
    }

    private var memoryBoxes: [MemoryBoxItem] {
        [
            MemoryBoxItem(id: "mood", title: "情绪", count: 5, mark: .mood),
            MemoryBoxItem(id: "sleep", title: "睡眠", count: 7, mark: .sleep),
            MemoryBoxItem(id: "memory", title: "记忆", count: 3, mark: .memory),
            MemoryBoxItem(id: "symptom", title: "症状", count: 4, mark: .symptom)
        ]
    }

    private func phase(for day: Int) -> CalendarPhase {
        guard monthOffset == 0 else { return .luteal }
        switch day {
        case 16...20: return .period
        case 21...28: return .follicular
        case 29...31: return .ovulation
        default: return .luteal
        }
    }

    private func phaseName(for day: Int) -> String {
        phase(for: day).title
    }

    private func cycleDay(forCalendarDay day: Int) -> Int {
        ((day + 12) % 28) + 1
    }
}

private enum CalendarPhase: String, CaseIterable, Identifiable {
    case period
    case follicular
    case ovulation
    case luteal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .period: return "经期"
        case .follicular: return "卵泡期"
        case .ovulation: return "排卵期"
        case .luteal: return "黄体期"
        }
    }

    var dot: Color {
        switch self {
        case .period: return Color(red: 233 / 255, green: 120 / 255, blue: 135 / 255)
        case .follicular: return Color(red: 144 / 255, green: 174 / 255, blue: 99 / 255)
        case .ovulation: return Color(red: 235 / 255, green: 170 / 255, blue: 65 / 255)
        case .luteal: return Color(red: 126 / 255, green: 174 / 255, blue: 211 / 255)
        }
    }

    var fill: Color {
        switch self {
        case .period: return Color(red: 254 / 255, green: 238 / 255, blue: 241 / 255)
        case .follicular: return Color(red: 241 / 255, green: 247 / 255, blue: 226 / 255)
        case .ovulation: return Color(red: 255 / 255, green: 246 / 255, blue: 232 / 255)
        case .luteal: return Color(red: 244 / 255, green: 250 / 255, blue: 255 / 255)
        }
    }

    var ring: Color { dot.opacity(0.72) }
}

private struct CalendarDayCircle: View {
    let day: Int
    let phase: CalendarPhase
    let isSelected: Bool
    let isReferenceOutline: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.black.opacity(0.86) : (isReferenceOutline ? Color.clear : phase.fill.opacity(0.72)))
                .frame(width: 31, height: 31)
                .overlay(
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.white.opacity(0.56) : (isReferenceOutline ? Color(red: 83 / 255, green: 139 / 255, blue: 196 / 255) : phase.ring),
                            style: StrokeStyle(lineWidth: isSelected || isReferenceOutline ? 1.45 : 1.0, dash: isSelected || isReferenceOutline ? [] : [3, 3])
                        )
                )
                .shadow(color: isSelected ? Color.black.opacity(0.17) : .clear, radius: 4, x: 0, y: 2)

            Text("\(day)")
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular, design: .serif))
                .foregroundStyle(isSelected ? Color.white : phase.dot.opacity(isReferenceOutline ? 0.92 : 0.96))
        }
        .frame(height: 32)
    }
}

private struct CalendarMemoMetric: View {
    let icon: String
    let tint: Color
    let title: String
    let value: String
    let sub: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.system(size: 11.5, weight: .regular))
                    .foregroundStyle(Color.black.opacity(0.58))
            }

            Text(value)
                .font(.system(size: 23, weight: .regular, design: .serif))
                .foregroundStyle(Color.black.opacity(0.92))

            Text(sub)
                .font(.system(size: 11.5, weight: .regular))
                .foregroundStyle(Color.black.opacity(0.54))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 9)
    }
}

private struct TornMemoShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 12))
        path.addQuadCurve(to: CGPoint(x: 30, y: 8), control: CGPoint(x: 12, y: 2))
        path.addLine(to: CGPoint(x: rect.width * 0.42, y: 10))
        path.addQuadCurve(to: CGPoint(x: rect.width * 0.62, y: 8), control: CGPoint(x: rect.width * 0.5, y: 3))
        path.addLine(to: CGPoint(x: rect.width - 20, y: 11))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: 14), control: CGPoint(x: rect.width - 8, y: 6))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - 12))

        let steps = 18
        for step in stride(from: steps, through: 0, by: -1) {
            let x = rect.width * CGFloat(step) / CGFloat(steps)
            let nextX = rect.width * CGFloat(max(step - 1, 0)) / CGFloat(steps)
            let wave = CGFloat((step * 37) % 9) - 4
            path.addQuadCurve(
                to: CGPoint(x: nextX, y: rect.height - 10 + wave * 0.45),
                control: CGPoint(x: (x + nextX) / 2, y: rect.height + 2)
            )
        }

        path.closeSubpath()
        return path
    }
}

private struct WashiTape: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color(red: 255 / 255, green: 248 / 255, blue: 249 / 255).opacity(0.96))
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

            Canvas { context, size in
                let dotColor = Color(red: 246 / 255, green: 154 / 255, blue: 176 / 255).opacity(0.72)
                for y in stride(from: CGFloat(5), through: size.height - 4, by: 8) {
                    for x in stride(from: CGFloat(5), through: size.width - 4, by: 8) {
                        context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 3.2, height: 3.2)), with: .color(dotColor))
                    }
                }
            }
            .padding(2)
        }
        .rotationEffect(.degrees(-1.5))
    }
}

private struct PearlMoreButton: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white,
                            Color(red: 238 / 255, green: 232 / 255, blue: 223 / 255),
                            Color(red: 214 / 255, green: 201 / 255, blue: 187 / 255)
                        ],
                        center: .topLeading,
                        startRadius: 1,
                        endRadius: 24
                    )
                )
                .frame(width: 42, height: 42)
                .shadow(color: Color.black.opacity(0.11), radius: 8, x: 0, y: 5)

            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(Color.black.opacity(0.45))
                        .frame(width: 3.3, height: 3.3)
                }
            }
        }
    }
}

private struct CalendarPaperGrain: View {
    var body: some View {
        Canvas { context, size in
            for i in 0..<900 {
                let x = CGFloat((i * 47) % 997) / 997 * size.width
                let y = CGFloat((i * 83) % 1499) / 1499 * size.height
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 0.65, height: 0.65)), with: .color(Color.black.opacity(0.018)))
            }
        }
        .allowsHitTesting(false)
    }
}

private struct MemoryBoxItem: Identifiable {
    let id: String
    let title: String
    let count: Int
    let mark: MemoryBoxMark
}

private enum MemoryBoxMark {
    case mood
    case sleep
    case memory
    case symptom
}

private struct WoodenMemoryBox: View {
    let box: MemoryBoxItem

    var body: some View {
        VStack(spacing: 5) {
            ZStack(alignment: .bottomLeading) {
                WoodenBoxCanvas(mark: box.mark)
            }
            .frame(height: 82)

            Text(box.title)
                .font(.system(size: 13.5, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.86))

            Text("\(box.count) 张")
                .font(.system(size: 11.5, weight: .regular))
                .foregroundStyle(Color.black.opacity(0.58))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(box.title)记忆箱，\(box.count)张")
    }
}

private struct WoodenBoxCanvas: View {
    let mark: MemoryBoxMark

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack(alignment: .bottomLeading) {
                ForEach(0..<6, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(LinearGradient(colors: [Color.white, Color(red: 235 / 255, green: 234 / 255, blue: 230 / 255)], startPoint: .top, endPoint: .bottom))
                        .frame(width: width * 0.58, height: 8)
                        .offset(x: width * 0.23, y: -height * 0.43 + CGFloat(index) * 5)
                        .shadow(color: Color.black.opacity(0.045), radius: 1, x: 0, y: 1)
                }

                Canvas { context, size in
                    let w = size.width
                    let h = size.height

                    var back = Path()
                    back.move(to: CGPoint(x: w * 0.18, y: h * 0.24))
                    back.addLine(to: CGPoint(x: w * 0.94, y: h * 0.06))
                    back.addLine(to: CGPoint(x: w * 0.94, y: h * 0.60))
                    back.addLine(to: CGPoint(x: w * 0.18, y: h * 0.80))
                    back.closeSubpath()
                    context.fill(back, with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 211 / 255, green: 171 / 255, blue: 121 / 255),
                            Color(red: 184 / 255, green: 141 / 255, blue: 88 / 255)
                        ]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: w, y: h)
                    ))

                    let front = CGRect(x: w * 0.08, y: h * 0.38, width: w * 0.78, height: h * 0.54)
                    context.fill(Path(roundedRect: front, cornerRadius: 5), with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 218 / 255, green: 184 / 255, blue: 130 / 255),
                            Color(red: 197 / 255, green: 154 / 255, blue: 97 / 255)
                        ]),
                        startPoint: front.origin,
                        endPoint: CGPoint(x: front.maxX, y: front.maxY)
                    ))
                    context.stroke(Path(roundedRect: front, cornerRadius: 5), with: .color(Color.black.opacity(0.07)), lineWidth: 0.8)

                    let plate = CGRect(x: w * 0.36, y: h * 0.51, width: w * 0.20, height: 7)
                    context.fill(Path(roundedRect: plate, cornerRadius: 3), with: .color(Color.white.opacity(0.88)))

                    for line in 0..<6 {
                        let y = front.minY + 9 + CGFloat(line) * 7
                        var grain = Path()
                        grain.move(to: CGPoint(x: front.minX + 7, y: y))
                        grain.addQuadCurve(
                            to: CGPoint(x: front.maxX - 8, y: y + CGFloat(line.isMultiple(of: 2) ? 2 : -1)),
                            control: CGPoint(x: front.midX, y: y - 3)
                        )
                        context.stroke(grain, with: .color(Color.white.opacity(0.13)), lineWidth: 0.7)
                    }
                }

                markView
                    .padding(.leading, 12)
                    .padding(.bottom, 12)
            }
        }
    }

    @ViewBuilder
    private var markView: some View {
        switch mark {
        case .mood:
            Image(systemName: "face.smiling")
                .font(.system(size: 19, weight: .light))
                .foregroundStyle(Color.black.opacity(0.50))
        case .sleep:
            Image(systemName: "moon")
                .font(.system(size: 19, weight: .light))
                .foregroundStyle(Color.black.opacity(0.50))
        case .memory:
            VStack(alignment: .leading, spacing: 3) {
                Text("A")
                    .font(.system(size: 22, weight: .light, design: .serif))
                Rectangle()
                    .frame(width: 28, height: 1)
            }
            .foregroundStyle(Color.black.opacity(0.52))
        case .symptom:
            Image(systemName: "cross.case")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(Color.black.opacity(0.50))
        }
    }
}
