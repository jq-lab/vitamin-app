import SwiftUI

struct CycleView: View {
    @ObservedObject var environment: AppEnvironment
    @State private var sheet: CycleSheet?
    @State private var isSidebarOpen = false
    @State private var selectedCycleReportTab: CycleReviewTab = .week

    var body: some View {
        ZStack {
            WaterAuraReferenceBackground(scene: .cycle, intensity: 1.02)

            ScrollView(showsIndicators: false) {
	                VStack(alignment: .leading, spacing: 12) {
	                    cycleTopBar

	                    CycleMapReportFrame(selectedTab: selectedCycleReportTab)
	                }
                .padding(.horizontal, VitoraTheme.Spacing.screenMargin)
                .padding(.top, 4)
                .padding(.bottom, VitoraTheme.Size.tabBarHeight + 42)
            }

            // Sidebar overlay
            if isSidebarOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.24)) { isSidebarOpen = false }
                    }
                    .transition(.opacity)

                SidebarProfileView(
                    onClose: { withAnimation(.easeOut(duration: 0.24)) { isSidebarOpen = false } },
                    onOpenSettings: {
                        withAnimation(.easeOut(duration: 0.24)) { isSidebarOpen = false }
                        sheet = .settings
                    }
                )
                .frame(width: 300)
                .frame(maxHeight: .infinity)
                .transition(.move(edge: .leading))
                .zIndex(10)
            }
        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .phase:
                CurrentPhaseDetailSheet(
                    onClose: { self.sheet = nil },
                    onAskVitora: { openVitora(source: "当前周期阶段", summary: "用户想校准日期或感受") }
                )
            case .energy:
                EnergyDynamicsDetailSheet(
                    onClose: { self.sheet = nil },
                    onAskVitora: { openVitora(source: "能量动态", summary: "解释趋势或某个低点") }
                )
            case .settings:
                SettingsPanel(onClose: { self.sheet = nil })
            case let .insight(insight):
                CycleInsightDetailSheet(
                    insight: insight,
                    onClose: { self.sheet = nil },
                    onAskVitora: { openVitora(source: insight.title, summary: insight.summary) }
                )
            case .sharePreview:
                ShareCardPreviewSheet(
                    onClose: { self.sheet = nil },
                    showsEveningCard: environment.canShowEveningReviewAnalysis
                )
            }
        }
        .preference(key: AppSheetPresentationPreferenceKey.self, value: sheet != nil)
        .accessibilityIdentifier("cycle.pivot.surface")
    }

    private var cycleTopBar: some View {
        GeometryReader { proxy in
            HStack(spacing: 10) {
            // 我的 / 设置
                Button { sheet = .settings } label: {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 23, weight: .medium))
                        .foregroundStyle(FlowerMapPalette.deepGreen)
                        .frame(width: 44, height: 44)
                        .background(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.74), in: Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.70), lineWidth: 0.8))
                        .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.08), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("我的")
                .accessibilityIdentifier("cycle.settings.open")

                Spacer(minLength: 4)

                CycleReportTopSegmentControl(selectedTab: $selectedCycleReportTab)
                    .frame(width: min(max(proxy.size.width * 0.60, 210), 258), height: 44)

                Spacer(minLength: 4)

                // 分享
                Button { sheet = .sharePreview } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(FlowerMapPalette.deepGreen)
                        .frame(width: 44, height: 44)
                        .background(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.74), in: Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.70), lineWidth: 0.8))
                        .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.08), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("分享周期卡片")
                .accessibilityIdentifier("cycle.share.open")
            }
        }
        .frame(height: 44)
    }

    private func openVitora(source: String, summary: String) {
        environment.openVitoraContext(
            sourceTitle: source,
            sourceSummary: summary,
            prompt: "Vitora 会带着这个长期节律上下文来解释或校准。"
        )
        sheet = nil
    }
}

private struct CycleMapReportFrame: View {
    let selectedTab: CycleReviewTab

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FlowerMapView()
                .padding(.top, 8)
                .padding(.horizontal, 2)

            CycleReviewInsightCard(selectedTab: selectedTab, presentation: .embedded)
                .padding(.horizontal, 8)
                .padding(.top, -4)
                .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.40))
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color(red: 0.64, green: 0.67, blue: 0.64).opacity(0.34), lineWidth: 1.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.white.opacity(0.64), lineWidth: 0.7)
                        .padding(1)
                )
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 14, x: 0, y: 7)
        )
        .accessibilityIdentifier("cycle.mapReport.frame")
    }
}

private struct CycleHeaderIllustration: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            VitoraTheme.ColorToken.auraCyan.opacity(0.76),
                            VitoraTheme.ColorToken.auraBlue.opacity(0.82),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 74, height: 58)
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.62))
                        .frame(height: 14)
                        .padding(.horizontal, 7)
                        .offset(y: -2)
                }
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.system(size: 25, weight: .heavy))
                        .foregroundStyle(Color.white.opacity(0.92))
                }
                .shadow(color: VitoraTheme.ColorToken.auraBlue.opacity(0.20), radius: 16, x: 0, y: 8)

            Circle()
                .fill(VitoraTheme.ColorToken.lutealGold)
                .frame(width: 26, height: 26)
                .overlay(Circle().stroke(Color.white.opacity(0.88), lineWidth: 1.2))
                .overlay {
                    Image(systemName: "sparkle")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.88))
                }
                .offset(x: 7, y: 7)

            ForEach([0.18, 0.74], id: \.self) { x in
                Capsule()
                    .fill(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.70))
                    .frame(width: 7, height: 15)
                    .offset(x: -74 * (0.5 - x), y: -49)
            }
        }
        .frame(width: 96, height: 76)
        .accessibilityHidden(true)
    }
}

// MARK: - Flower Map

private struct FlowerMapView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedCityID: FlowerMapCityID = .shenzhen
    @State private var hasPlantedToday = false
    @State private var plantedTileIDs: Set<String> = []
    @State private var sproutingTileIDs: Set<String> = []
    @State private var pulseTileID: String?
    @State private var selectedTile: FlowerMapTile?
    @State private var overlay: FlowerMapOverlay?
    @State private var isHandbookPresented = false
    @State private var isMapTransitioning = false

    private var homeCity: FlowerMapCityConfig {
        CITY_MAPS[.shenzhen] ?? FlowerMapCityConfig.fallback
    }

    private var currentCity: FlowerMapCityConfig {
        CITY_MAPS[selectedCityID] ?? homeCity
    }

    private var homeDisplayedProgress: Int {
        min(homeCity.total, homeBasePlantedCount + (hasPlantedToday ? 1 : 0))
    }

    private var displayedProgress: Int {
        selectedCityID == .shenzhen ? homeDisplayedProgress : currentCity.planted
    }

    private var progressTotal: Int {
        currentCity.total
    }

    private var remainingSteps: Int {
        max(0, homeCity.total - homeDisplayedProgress)
    }

    private var isHomeCityComplete: Bool {
        homeDisplayedProgress >= homeCity.total
    }

    private var isLockedPreview: Bool {
        !currentCity.unlocked && !(selectedCityID == .guangzhou && isHomeCityComplete)
    }

    private var homeBasePlantedCount: Int {
        if let override = plantedCountLaunchOverride {
            return min(homeCity.total, max(0, override))
        }

        return homeCity.planted
    }

    private var plantedCountLaunchOverride: Int? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-vitoraUITestCycleFlowerMapPlantedCount"),
              arguments.indices.contains(index + 1),
              let value = Int(arguments[index + 1])
        else {
            return nil
        }

        return value
    }

    private func basePlantedCount(for city: FlowerMapCityConfig) -> Int {
        city.id == .shenzhen ? homeBasePlantedCount : city.planted
    }

    private var visibleTiles: [FlowerMapTile] {
        FlowerMapTile.tiles(
            for: currentCity,
            plantedCount: basePlantedCount(for: currentCity),
            plantedTileIDs: plantedTileIDs,
            sproutingTileIDs: sproutingTileIDs,
            lockedPreview: isLockedPreview
        )
    }

    private var nextPlantableTile: FlowerMapTile? {
        visibleTiles.first(where: { $0.isTodayTarget && $0.kind == .emptySoil })
            ?? visibleTiles.first(where: { $0.kind == .emptySoil })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            routeBar

            ZStack(alignment: .topTrailing) {
                FlowerIsoMapView(
                    tiles: visibleTiles,
                    pulseTileID: pulseTileID,
                    isTransitioning: isMapTransitioning,
                    onTileTapped: handleTileTap
                )
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .accessibilityIdentifier("cycle.flowerMap.isoMap")

                floatingPlantButton
                    .padding(.top, 8)
                    .padding(.trailing, 4)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        flowerCollectionButton
                    }
                }
                .padding(.trailing, 8)
                .padding(.bottom, 20)

                overlayCard
            }
            .padding(.top, 10)
        }
        .accessibilityIdentifier("cycle.flowerMap")
        .sheet(isPresented: $isHandbookPresented) {
            FlowerHandbookSheetView()
                .presentationDetents([.height(360), .medium])
                .presentationDragIndicator(.visible)
                .accessibilityIdentifier("cycle.flowerMap.handbook.sheet")
        }
    }

    private var routeBar: some View {
        HStack(spacing: 9) {
            Button {
                setCurrentCity()
            } label: {
                FlowerRouteNodeView(
                    title: "深圳",
                    isActive: selectedCityID == .shenzhen,
                    isLocked: false
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("cycle.flowerMap.city.current")

            Button {
                setNextCity(showUnlock: false)
            } label: {
                FlowerRouteProgressDotsView(
                    progress: CGFloat(homeDisplayedProgress) / CGFloat(max(homeCity.total, 1)),
                    isComplete: remainingSteps == 0
                )
                .frame(maxWidth: .infinity)
                .frame(height: 24)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
            .accessibilityIdentifier("cycle.flowerMap.remaining")
            .accessibilityLabel("路线进度，剩余 \(remainingSteps) 格")

            Button {
                setNextCity(showUnlock: true)
            } label: {
                FlowerRouteNodeView(
                    title: "广州",
                    isActive: selectedCityID == .guangzhou,
                    isLocked: !isHomeCityComplete
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("cycle.flowerMap.city.next")
        }
        .padding(.horizontal, 2)
        .frame(height: 44)
        .accessibilityElement(children: .contain)
    }

    private var floatingPlantButton: some View {
        Button {
            plantToday()
        } label: {
            VStack(spacing: 4) {
                FlowerPlantGuideBadge(
                    isPlanted: hasPlantedToday || isHomeCityComplete,
                    isLocked: isLockedPreview
                )
                .frame(width: 68, height: 68)

                Text(isLockedPreview ? "未解锁" : (isHomeCityComplete ? "已点亮" : (hasPlantedToday ? "今日已种下" : "种下今天")))
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(FlowerMapPalette.deepGreen)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
                    .padding(.horizontal, 8)
                    .frame(height: 24)
                    .background(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.88), in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.76), lineWidth: 0.7))
            }
        }
        .buttonStyle(.plain)
        .disabled(hasPlantedToday || isLockedPreview || isHomeCityComplete)
        .accessibilityIdentifier("cycle.flowerMap.plantToday")
        .accessibilityLabel(isLockedPreview ? "未解锁" : (isHomeCityComplete ? "城市已点亮" : (hasPlantedToday ? "今日已种下" : "种下今天")))
    }

    private var flowerCollectionButton: some View {
        Button {
            isHandbookPresented = true
            selectedTile = nil
            overlay = nil
        } label: {
            HStack(spacing: 4) {
                MiniFlowerIconView()
                    .frame(width: 18, height: 18)

                Text("\(displayedProgress)朵")
                    .font(.system(size: 12, weight: .heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(FlowerMapPalette.deepGreen)
            .frame(minWidth: 54, minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("cycle.flowerMap.handbook")
        .accessibilityLabel("已收集 \(displayedProgress) 朵花，打开花朵说明")
    }

    @ViewBuilder
    private var overlayCard: some View {
        if let selectedTile {
            FlowerMapInfoCard(
                title: selectedTile.kind == .locked ? "下一站还未解锁" : (selectedTile.kind == .emptySoil ? "可种地块" : "今天的花"),
                lines: selectedTile.kind == .locked
                    ? ["\(currentCity.name)地图会在深圳进度完成后打开。", "现在还差 \(remainingSteps) 格。"]
                    : ["这一格记录今天的恢复资源。", hasPlantedToday ? "地图进度已更新到 \(homeDisplayedProgress)/\(homeCity.total)。" : "点击空地可以把今天的花种下。"],
                onClose: closeOverlay
            )
            .padding(.leading, 6)
            .padding(.top, 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .transition(.move(edge: .leading).combined(with: .opacity))
        } else if overlay == .help {
            FlowerMapInfoCard(
                title: "花之地图说明",
                lines: ["地图只表达长期节律与恢复资源。", "花朵代表一次温和的身体状态记录。", "点击空地种下今天的花，点击路线查看下一站。"],
                onClose: closeOverlay
            )
            .padding(.leading, 6)
            .padding(.top, 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .transition(.move(edge: .leading).combined(with: .opacity))
        } else if overlay == .cityPreview {
            FlowerMapInfoCard(
                title: "下一站还未解锁",
                lines: ["正在预览广州的真实地图轮廓。", "完成深圳 \(homeCity.total)/\(homeCity.total) 后打开。", "现在还差 \(remainingSteps) 格。"],
                onClose: closeOverlay
            )
            .padding(.leading, 6)
            .padding(.top, 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .transition(.move(edge: .leading).combined(with: .opacity))
        }
    }

    private func setCurrentCity() {
        switchCity(to: .shenzhen, overlay: nil)
    }

    private func setNextCity(showUnlock: Bool) {
        switchCity(to: .guangzhou, overlay: showUnlock ? .cityPreview : nil)
    }

    private func switchCity(to cityID: FlowerMapCityID, overlay nextOverlay: FlowerMapOverlay?) {
        guard selectedCityID != cityID || overlay != nextOverlay || selectedTile != nil else {
            return
        }

        if reduceMotion {
            selectedCityID = cityID
            overlay = nextOverlay
            selectedTile = nil
            isMapTransitioning = false
            return
        }

        withAnimation(.easeInOut(duration: 0.16)) {
            isMapTransitioning = true
            selectedTile = nil
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            selectedCityID = cityID
            overlay = nextOverlay
            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                isMapTransitioning = false
            }
        }
    }

    private func plantToday(on tile: FlowerMapTile? = nil) {
        guard !hasPlantedToday, !isLockedPreview, !isHomeCityComplete else {
            withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.18)) {
                overlay = .cityPreview
                selectedTile = nil
            }
            return
        }

        guard let target = tile ?? nextPlantableTile else {
            withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.18)) {
                overlay = .help
            }
            return
        }

        let targetID = target.id
        let plantingKey = target.plantingKey

        if reduceMotion {
            hasPlantedToday = true
            sproutingTileIDs.insert(plantingKey)
            pulseTileID = targetID
        } else {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.72)) {
                hasPlantedToday = true
                sproutingTileIDs.insert(plantingKey)
                pulseTileID = targetID
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.05 : 0.52)) {
            withAnimation(.spring(response: 0.30, dampingFraction: 0.78)) {
                sproutingTileIDs.remove(plantingKey)
                plantedTileIDs.insert(plantingKey)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
            withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.18)) {
                pulseTileID = nil
            }
        }
    }

    private func handleTileTap(_ tile: FlowerMapTile) {
        guard tile.kind != .void else {
            return
        }

        if tile.kind == .emptySoil, !hasPlantedToday, !isLockedPreview {
            plantToday(on: tile)
            return
        }

        withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.2)) {
            selectedTile = tile
            overlay = nil
        }
    }

    private func closeOverlay() {
        withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.18)) {
            overlay = nil
            selectedTile = nil
        }
    }
}

private struct CycleReportTopSegmentControl: View {
    @Binding var selectedTab: CycleReviewTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(CycleReviewTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.segmentTitle)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(selectedTab == tab ? Color.white : VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background {
                            if selectedTab == tab {
                                Capsule(style: .continuous)
                                    .fill(FlowerMapPalette.deepGreen)
                                    .shadow(color: FlowerMapPalette.deepGreen.opacity(0.20), radius: 8, x: 0, y: 3)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(tab.accessibilityID)
                .accessibilityLabel(tab.segmentTitle)
            }
        }
        .padding(4)
        .background(
            Capsule(style: .continuous)
                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.68))
                .overlay(Capsule(style: .continuous).stroke(FlowerMapPalette.deepGreen.opacity(0.42), lineWidth: 1))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 5)
        )
    }
}

private enum FlowerMapCityID: String, CaseIterable, Identifiable {
    case shenzhen
    case guangzhou
    case hongkong
    case dongguan
    case huizhou

    var id: String { rawValue }
}

private struct FlowerMapCityConfig {
    let id: FlowerMapCityID
    let name: String
    let nextName: String
    let total: Int
    let planted: Int
    let unlocked: Bool
    let shape: [String]

    static let fallback = FlowerMapCityConfig(
        id: .shenzhen,
        name: "深圳",
        nextName: "广州",
        total: 36,
        planted: 24,
        unlocked: true,
        shape: [
            "000gggg00",
            "00gggggg0",
            "0gggggggg",
            "gggggggg0",
            "0gggggg00",
            "00g000g00",
            "g0000000g",
        ]
    )
}

private enum FlowerMapOverlay: Equatable {
    case help
    case cityPreview
}

private enum FlowerMapTileKind {
    case void
    case emptySoil
    case sprout
    case bloom
    case today
    case locked
}

private enum FlowerDecorationLevel: Equatable {
    case none
    case small
    case medium
    case large
    case featured

    var scale: CGFloat {
        switch self {
        case .none:
            return 1
        case .small:
            return 0.50
        case .medium:
            return 0.64
        case .large:
            return 0.76
        case .featured:
            return 0.82
        }
    }

    var lift: CGFloat {
        switch self {
        case .none:
            return 0
        case .small:
            return 0.48
        case .medium:
            return 0.56
        case .large:
            return 0.64
        case .featured:
            return 0.68
        }
    }
}

private let CITY_MAPS: [FlowerMapCityID: FlowerMapCityConfig] = [
    .shenzhen: .fallback,
    .guangzhou: FlowerMapCityConfig(
        id: .guangzhou,
        name: "广州",
        nextName: "香港",
        total: 42,
        planted: 0,
        unlocked: false,
        shape: [
            "0000gggg00",
            "00gggffg00",
            "0gfgsfgfg0",
            "gffgfgsfg0",
            "0gfgfgffg0",
            "00gfgfg000",
            "000gggg000",
        ]
    ),
    .hongkong: FlowerMapCityConfig(
        id: .hongkong,
        name: "香港",
        nextName: "东莞",
        total: 30,
        planted: 0,
        unlocked: false,
        shape: [
            "000gg000",
            "00gffg00",
            "0gfgfg0",
            "gffgfg0",
            "0gfg000",
            "00gg000",
        ]
    ),
    .dongguan: FlowerMapCityConfig(
        id: .dongguan,
        name: "东莞",
        nextName: "惠州",
        total: 36,
        planted: 0,
        unlocked: false,
        shape: [
            "000ggg000",
            "00gsgfg00",
            "0gfgfgfg0",
            "gfgsfgfg0",
            "0gfgsg000",
            "00ggg0000",
        ]
    ),
    .huizhou: FlowerMapCityConfig(
        id: .huizhou,
        name: "惠州",
        nextName: "中国地图",
        total: 36,
        planted: 0,
        unlocked: false,
        shape: [
            "000gggg00",
            "00gfgfg00",
            "gfgfgsfg0",
            "0gsgfgfg0",
            "00gfgfg00",
            "000gg0000",
        ]
    ),
]

private struct FlowerMapTile: Identifiable {
    let cityID: FlowerMapCityID
    let row: Int
    let col: Int
    var kind: FlowerMapTileKind
    let variant: Int
    let isTodayTarget: Bool
    let showsPlus: Bool
    let decorationLevel: FlowerDecorationLevel

    var id: String { "\(cityID.rawValue)-\(row)-\(col)" }
    var plantingKey: String { id }

    static func tiles(
        for city: FlowerMapCityConfig,
        plantedCount: Int,
        plantedTileIDs: Set<String>,
        sproutingTileIDs: Set<String>,
        lockedPreview: Bool
    ) -> [FlowerMapTile] {
        var tileOrdinal = 0
        let cappedPlantedCount = min(city.total, max(0, plantedCount))

        return city.shape.enumerated().flatMap { rowIndex, row in
            Array(row).enumerated().map { colIndex, char in
                let parsed = parsedTile(for: char)
                let ordinal: Int?
                if parsed.isDrawable {
                    ordinal = tileOrdinal
                    tileOrdinal += 1
                } else {
                    ordinal = nil
                }

                let baseID = "\(city.id.rawValue)-\(rowIndex)-\(colIndex)"
                let isSprouting = sproutingTileIDs.contains(baseID)
                let isPlantedToday = plantedTileIDs.contains(baseID)
                let isNextTarget = ordinal == min(cappedPlantedCount, max(0, city.total - 1))
                let resolvedKind: FlowerMapTileKind
                if !parsed.isDrawable {
                    resolvedKind = .void
                } else if lockedPreview {
                    resolvedKind = .locked
                } else if isSprouting {
                    resolvedKind = .sprout
                } else if isPlantedToday {
                    resolvedKind = .today
                } else if let ordinal, ordinal < cappedPlantedCount {
                    if cappedPlantedCount >= city.total {
                        resolvedKind = .bloom
                    } else if ordinal % 7 == 0 || ordinal >= max(0, cappedPlantedCount - 2) {
                        resolvedKind = .sprout
                    } else {
                        resolvedKind = .bloom
                    }
                } else {
                    resolvedKind = .emptySoil
                }
                let todayTarget = parsed.isTodayTarget || (!lockedPreview && isNextTarget && cappedPlantedCount < city.total)
                let plusVisible = resolvedKind == .emptySoil
                    && (todayTarget || ((ordinal ?? -1) > cappedPlantedCount && ((ordinal ?? 0) - cappedPlantedCount) % 5 == 0))

                return FlowerMapTile(
                    cityID: city.id,
                    row: rowIndex,
                    col: colIndex,
                    kind: resolvedKind,
                    variant: (rowIndex * 5 + colIndex * 3 + city.id.rawValue.count) % 8,
                    isTodayTarget: todayTarget,
                    showsPlus: plusVisible,
                    decorationLevel: decorationLevel(
                        for: resolvedKind,
                        ordinal: ordinal ?? 0,
                        isTodayTarget: todayTarget || isPlantedToday,
                        isComplete: cappedPlantedCount >= city.total
                    )
                )
            }
        }
    }

    private static func parsedTile(for char: Character) -> (isDrawable: Bool, isTodayTarget: Bool) {
        switch char {
        case "g", "f", "s":
            return (true, false)
        case "t":
            return (true, true)
        default:
            return (false, false)
        }
    }

    private static func decorationLevel(
        for kind: FlowerMapTileKind,
        ordinal: Int,
        isTodayTarget: Bool,
        isComplete: Bool
    ) -> FlowerDecorationLevel {
        switch kind {
        case .today:
            return .featured
        case .sprout:
            return isTodayTarget ? .medium : .small
        case .bloom:
            if ordinal == 4 || ordinal == 13 {
                return .large
            }
            return isComplete || ordinal % 3 == 0 ? .medium : .small
        default:
            return .none
        }
    }
}

private enum FlowerMapPalette {
    static let deepGreen = Color(red: 0.13, green: 0.43, blue: 0.20)
    static let leaf = Color(red: 0.38, green: 0.67, blue: 0.20)
    static let leafLight = Color(red: 0.64, green: 0.82, blue: 0.30)
    static let soilTop = Color(red: 0.78, green: 0.60, blue: 0.39)
    static let soilTopDeep = Color(red: 0.66, green: 0.47, blue: 0.27)
    static let soilSideLeft = Color(red: 0.55, green: 0.37, blue: 0.20)
    static let soilSideRight = Color(red: 0.40, green: 0.28, blue: 0.14)
    static let grassTop = Color(red: 0.66, green: 0.84, blue: 0.41)
    static let grassDeep = Color(red: 0.49, green: 0.73, blue: 0.32)
    static let lockedTop = Color(red: 0.78, green: 0.69, blue: 0.54)
    static let flowerPink = Color(red: 0.96, green: 0.45, blue: 0.61)
    static let flowerYellow = Color(red: 0.98, green: 0.81, blue: 0.22)
    static let flowerPurple = Color(red: 0.62, green: 0.45, blue: 0.96)
    static let waterBlue = Color(red: 0.22, green: 0.58, blue: 0.80)
    static let sun = Color(red: 0.96, green: 0.61, blue: 0.10)
}

private struct FlowerIsoMapView: View {
    let tiles: [FlowerMapTile]
    let pulseTileID: String?
    let isTransitioning: Bool
    let onTileTapped: (FlowerMapTile) -> Void

    var body: some View {
        GeometryReader { proxy in
            let visibleTiles = tiles.filter { $0.kind != .void }
            let rowCount = (visibleTiles.map(\.row).max() ?? 0) + 1
            let colCount = (visibleTiles.map(\.col).max() ?? 0) + 1
            let baseTileWidth: CGFloat = 54
            let baseTileHeight: CGFloat = 31
            let baseDepth: CGFloat = 13.5
            let gapX: CGFloat = 1.4
            let gapY: CGFloat = 0.9
            let rawStepX = (baseTileWidth + gapX) * 0.50
            let rawStepY = (baseTileHeight + gapY) * 0.50
            let rawMapWidth = CGFloat(rowCount + colCount) * rawStepX + baseTileWidth
            let rawMapHeight = CGFloat(rowCount + colCount) * rawStepY + baseDepth + 92
            let fittedScale = min((proxy.size.width * 1.08) / rawMapWidth, (proxy.size.height * 0.92) / rawMapHeight)
            let scale = min(1.02, max(0.70, fittedScale))
            let tileWidth = baseTileWidth * scale
            let tileHeight = baseTileHeight * scale
            let depth = baseDepth * scale
            let stepX = (tileWidth + gapX * scale) * 0.50
            let stepY = (tileHeight + gapY * scale) * 0.50
            let centerX = proxy.size.width / 2
            let topY = max(CGFloat(18), (proxy.size.height - rawMapHeight * scale) * 0.32)

            ZStack {
                Ellipse()
                    .fill(Color.black.opacity(0.08))
                    .frame(width: min(proxy.size.width * 0.96, rawMapWidth * scale * 0.82), height: tileHeight * 2.25)
                    .blur(radius: 15)
                    .position(x: centerX + tileWidth * 0.18, y: topY + CGFloat(rowCount + colCount) * stepY * 0.72)

                ForEach(visibleTiles) { tile in
                    let x = centerX + (CGFloat(tile.col) - CGFloat(tile.row)) * stepX
                    let y = topY + (CGFloat(tile.col) + CGFloat(tile.row)) * stepY

                    Button {
                        onTileTapped(tile)
                    } label: {
                        FlowerIsoTileView(
                            tile: tile,
                            tileWidth: tileWidth,
                            tileHeight: tileHeight,
                            depth: depth,
                            isPulsing: pulseTileID == tile.id
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(width: max(44, tileWidth * 1.28), height: max(52, tileHeight * 2.62))
                    .position(x: x, y: y)
                    .zIndex(Double(tile.row + tile.col))
                    .accessibilityLabel(accessibilityLabel(for: tile))
                    .accessibilityIdentifier("cycle.flowerMap.tile.\(tile.id)")
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .opacity(isTransitioning ? 0.18 : 1)
            .scaleEffect(isTransitioning ? 0.96 : 1)
        }
    }

    private func accessibilityLabel(for tile: FlowerMapTile) -> String {
        switch tile.kind {
        case .void:
            return "地图空白"
        case .emptySoil:
            return "可种花的耕地"
        case .sprout:
            return "正在生长的幼苗"
        case .bloom:
            return "已开花的地块"
        case .today:
            return "今天的花"
        case .locked:
            return "未解锁地块"
        }
    }
}

private struct FlowerIsoTileView: View {
    let tile: FlowerMapTile
    let tileWidth: CGFloat
    let tileHeight: CGFloat
    let depth: CGFloat
    let isPulsing: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var topFill: Color {
        switch tile.kind {
        case .emptySoil, .sprout:
            return FlowerMapPalette.soilTop
        case .bloom, .today:
            return FlowerMapPalette.grassTop
        case .locked:
            return FlowerMapPalette.lockedTop
        case .void:
            return Color.clear
        }
    }

    private var topHighlight: Color {
        switch tile.kind {
        case .emptySoil, .sprout:
            return Color(red: 0.86, green: 0.66, blue: 0.43)
        case .locked:
            return Color(red: 0.78, green: 0.80, blue: 0.74)
        default:
            return Color(red: 0.70, green: 0.88, blue: 0.32)
        }
    }

    var body: some View {
        ZStack {
            if isPulsing {
                DiamondShape()
                    .stroke(FlowerMapPalette.flowerYellow.opacity(0.78), lineWidth: 3)
                    .frame(width: tileWidth * 1.26, height: tileHeight * 1.26)
                    .scaleEffect(reduceMotion ? 1.05 : 1.34)
                    .opacity(reduceMotion ? 0.55 : 0.22)
                    .offset(y: -tileHeight * 0.14)
            }

            DiamondShape()
                .fill(Color.black.opacity(0.13))
                .frame(width: tileWidth * 1.04, height: tileHeight * 1.03)
                .blur(radius: 1.8)
                .offset(x: tileWidth * 0.08, y: tileHeight * 0.62)

            IsoSideShape(side: .left, depthRatio: depth / (tileHeight + depth))
                .fill(
                    tile.kind == .locked
                        ? AnyShapeStyle(Color.gray.opacity(0.38))
                        : AnyShapeStyle(LinearGradient(
                            colors: [
                                FlowerMapPalette.soilSideLeft,
                                Color(red: 0.27, green: 0.18, blue: 0.09),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                )
                .frame(width: tileWidth, height: tileHeight + depth)

            IsoSideShape(side: .right, depthRatio: depth / (tileHeight + depth))
                .fill(
                    tile.kind == .locked
                        ? AnyShapeStyle(Color.gray.opacity(0.28))
                        : AnyShapeStyle(LinearGradient(
                            colors: [
                                FlowerMapPalette.soilSideRight,
                                Color(red: 0.34, green: 0.22, blue: 0.11),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                )
                .frame(width: tileWidth, height: tileHeight + depth)

            DiamondShape()
                .fill(
                    LinearGradient(
                        colors: [
                            topHighlight,
                            topFill,
                            tile.kind == .emptySoil || tile.kind == .sprout ? FlowerMapPalette.soilTopDeep : topFill.opacity(0.88),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: tileWidth, height: tileHeight)
                .overlay {
                    IsoTileTextureView(kind: tile.kind, variant: tile.variant)
                        .clipShape(DiamondShape())
                }
                .overlay(
                    DiamondShape()
                        .stroke(Color.black.opacity(tile.kind == .locked ? 0.06 : 0.065), lineWidth: 0.6)
                        .offset(y: 0.2)
                )
                .overlay(
                    DiamondShape()
                        .stroke(Color.white.opacity(tile.kind == .locked ? 0.06 : 0.075), lineWidth: 0.4)
                )
                .offset(y: -depth * 0.50)

            tileOverlay
                .frame(width: tileWidth * 1.18, height: tileHeight * 2.10)
                .scaleEffect(tile.decorationLevel.scale)
                .offset(y: -tileHeight * tile.decorationLevel.lift)
        }
        .scaleEffect(isPulsing && !reduceMotion ? 1.06 : 1)
        .animation(.spring(response: 0.34, dampingFraction: 0.74), value: isPulsing)
    }

    @ViewBuilder
    private var tileOverlay: some View {
        switch tile.kind {
        case .emptySoil:
            if tile.showsPlus {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(Color.white.opacity(0.88))
            }
        case .sprout:
            SproutPatchGlyph(variant: tile.variant, isTodayTarget: tile.isTodayTarget)
        case .bloom:
            FlowerPatchGlyph(variant: tile.variant, level: tile.decorationLevel, isToday: false)
        case .today:
            FlowerPatchGlyph(variant: tile.variant, level: tile.decorationLevel, isToday: true)
        case .locked:
            Image(systemName: "lock.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.58))
        case .void:
            EmptyView()
        }
    }
}

private struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

private struct IsoSideShape: Shape {
    enum Side {
        case left
        case right
    }

    let side: Side
    let depthRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        let depth = max(1, rect.height * min(0.55, max(0.12, depthRatio)))
        let topHeight = rect.height - depth
        var path = Path()
        switch side {
        case .left:
            path.move(to: CGPoint(x: rect.minX, y: topHeight * 0.50))
            path.addLine(to: CGPoint(x: rect.midX, y: topHeight))
            path.addLine(to: CGPoint(x: rect.midX, y: topHeight + depth))
            path.addLine(to: CGPoint(x: rect.minX, y: topHeight * 0.50 + depth))
        case .right:
            path.move(to: CGPoint(x: rect.maxX, y: topHeight * 0.50))
            path.addLine(to: CGPoint(x: rect.midX, y: topHeight))
            path.addLine(to: CGPoint(x: rect.midX, y: topHeight + depth))
            path.addLine(to: CGPoint(x: rect.maxX, y: topHeight * 0.50 + depth))
        }
        path.closeSubpath()
        return path
    }
}

private struct IsoTileTextureView: View {
    let kind: FlowerMapTileKind
    let variant: Int

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let isGreen = kind == .bloom || kind == .today
            let isDirt = kind == .emptySoil || kind == .sprout

            for index in 0..<24 {
                let seed = CGFloat((index * 31 + variant * 17) % 97) / 97
                let seedB = CGFloat((index * 47 + variant * 23) % 89) / 89
                let point = CGPoint(x: size.width * (0.12 + seed * 0.76), y: size.height * (0.16 + seedB * 0.66))
                let inside = abs(point.x - center.x) / (size.width / 2) + abs(point.y - center.y) / (size.height / 2) < 0.88
                guard inside else {
                    continue
                }

                if isGreen {
                    let radius = size.width * (0.016 + CGFloat(index % 3) * 0.004)
                    context.fill(
                        Path(ellipseIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)),
                        with: .color((index % 2 == 0 ? Color.white : FlowerMapPalette.deepGreen).opacity(index % 2 == 0 ? 0.16 : 0.18))
                    )

                    if index % 4 == 0 {
                        var blade = Path()
                        blade.move(to: CGPoint(x: point.x, y: point.y + size.height * 0.10))
                        blade.addQuadCurve(
                            to: CGPoint(x: point.x + CGFloat(index % 2 == 0 ? -1 : 1) * size.width * 0.045, y: point.y - size.height * 0.12),
                            control: CGPoint(x: point.x, y: point.y)
                        )
                        context.stroke(blade, with: .color(FlowerMapPalette.deepGreen.opacity(0.34)), style: StrokeStyle(lineWidth: 0.9, lineCap: .round))
                    }
                } else if isDirt {
                    let dot = CGRect(x: point.x - 1, y: point.y - 0.8, width: 2.2, height: 1.6)
                    let dotColor = index % 3 == 0 ? Color(red: 0.38, green: 0.25, blue: 0.13) : Color.white
                    context.fill(Path(ellipseIn: dot), with: .color(dotColor.opacity(index % 3 == 0 ? 0.18 : 0.11)))
                } else if kind == .locked {
                    context.fill(
                        Path(ellipseIn: CGRect(x: point.x - 0.8, y: point.y - 0.8, width: 1.6, height: 1.6)),
                        with: .color(Color.white.opacity(0.10))
                    )
                }
            }

            if isDirt {
                for index in 0..<4 {
                    let y = size.height * (0.28 + CGFloat(index) * 0.12)
                    var ridge = Path()
                    ridge.move(to: CGPoint(x: size.width * (0.23 + CGFloat(index % 2) * 0.04), y: y))
                    ridge.addQuadCurve(
                        to: CGPoint(x: size.width * (0.72 - CGFloat(index % 2) * 0.04), y: y + size.height * 0.04),
                        control: CGPoint(x: size.width * 0.48, y: y - size.height * 0.06)
                    )
                    context.stroke(
                        ridge,
                        with: .color(Color(red: 0.46, green: 0.30, blue: 0.16).opacity(0.30)),
                        style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
                    )
                }
            }

            if isGreen {
                var edge = Path()
                edge.move(to: CGPoint(x: size.width * 0.08, y: center.y))
                edge.addLine(to: CGPoint(x: center.x, y: size.height * 0.92))
                edge.addLine(to: CGPoint(x: size.width * 0.92, y: center.y))
                context.stroke(edge, with: .color(FlowerMapPalette.deepGreen.opacity(0.22)), style: StrokeStyle(lineWidth: 1.1, lineCap: .round, dash: [2, 3]))
            }
        }
    }
}

private struct SproutPatchGlyph: View {
    let variant: Int
    let isTodayTarget: Bool

    var body: some View {
        Canvas { context, size in
            let base = CGPoint(x: size.width * 0.50, y: size.height * 0.76)
            let stemTop = CGPoint(x: size.width * 0.50, y: size.height * 0.34)
            var stem = Path()
            stem.move(to: base)
            stem.addQuadCurve(
                to: stemTop,
                control: CGPoint(x: size.width * (variant % 2 == 0 ? 0.45 : 0.55), y: size.height * 0.54)
            )
            context.stroke(stem, with: .color(FlowerMapPalette.deepGreen.opacity(0.82)), style: StrokeStyle(lineWidth: 2.4, lineCap: .round))

            let leftLeaf = CGRect(x: size.width * 0.25, y: size.height * 0.34, width: size.width * 0.25, height: size.height * 0.18)
            let rightLeaf = CGRect(x: size.width * 0.50, y: size.height * 0.31, width: size.width * 0.27, height: size.height * 0.19)
            context.fill(Path(ellipseIn: leftLeaf), with: .color(FlowerMapPalette.leafLight.opacity(0.90)))
            context.fill(Path(ellipseIn: rightLeaf), with: .color(FlowerMapPalette.leaf.opacity(0.88)))
            context.stroke(Path(ellipseIn: leftLeaf), with: .color(Color.white.opacity(0.24)), lineWidth: 0.7)
            context.stroke(Path(ellipseIn: rightLeaf), with: .color(Color.white.opacity(0.22)), lineWidth: 0.7)

            let soilShadow = CGRect(x: size.width * 0.34, y: size.height * 0.72, width: size.width * 0.32, height: size.height * 0.08)
            context.fill(Path(ellipseIn: soilShadow), with: .color(Color(red: 0.37, green: 0.24, blue: 0.12).opacity(0.20)))

            if isTodayTarget {
                let glowRect = CGRect(x: size.width * 0.28, y: size.height * 0.20, width: size.width * 0.44, height: size.width * 0.44)
                context.stroke(Path(ellipseIn: glowRect), with: .color(FlowerMapPalette.flowerYellow.opacity(0.42)), lineWidth: 1.3)
            }
        }
    }
}

private struct FlowerPatchGlyph: View {
    let variant: Int
    let level: FlowerDecorationLevel
    let isToday: Bool

    private var flowerColor: Color {
        switch variant % 4 {
        case 0:
            return FlowerMapPalette.flowerYellow
        case 1:
            return FlowerMapPalette.flowerPink
        case 2:
            return FlowerMapPalette.flowerPurple
        default:
            return Color.white
        }
    }

    var body: some View {
        Canvas { context, size in
            switch variant % 6 {
            case 0:
                drawFlowerCluster(context: &context, size: size, color: FlowerMapPalette.flowerYellow, count: 5)
            case 1:
                drawFlowerCluster(context: &context, size: size, color: FlowerMapPalette.flowerPink, count: 6)
            case 2:
                drawBlueBloom(context: &context, size: size)
            case 3 where level == .large || level == .featured:
                drawSmallTree(context: &context, size: size)
            case 4:
                drawFlowerCluster(context: &context, size: size, color: Color.white, count: 7)
            default:
                if level == .large {
                    drawMushroomBloom(context: &context, size: size)
                } else {
                    drawFlowerCluster(context: &context, size: size, color: FlowerMapPalette.flowerYellow, count: 4)
                }
            }

            if isToday {
                let glowRect = CGRect(x: size.width * 0.18, y: size.height * 0.08, width: size.width * 0.64, height: size.width * 0.64)
                context.stroke(Path(ellipseIn: glowRect), with: .color(FlowerMapPalette.flowerYellow.opacity(0.54)), lineWidth: 1.6)
            }
        }
    }

    private func drawFlowerCluster(context: inout GraphicsContext, size: CGSize, color: Color, count: Int) {
        let usesWhitePetals = count >= 7
        let positions: [CGPoint] = [
            CGPoint(x: 0.31, y: 0.52),
            CGPoint(x: 0.47, y: 0.36),
            CGPoint(x: 0.62, y: 0.48),
            CGPoint(x: 0.39, y: 0.26),
            CGPoint(x: 0.55, y: 0.25),
            CGPoint(x: 0.69, y: 0.34),
            CGPoint(x: 0.26, y: 0.36),
        ]

        for index in 0..<min(count, positions.count) {
            let point = CGPoint(x: size.width * positions[index].x, y: size.height * positions[index].y)
            var stem = Path()
            stem.move(to: CGPoint(x: point.x, y: size.height * 0.82))
            stem.addQuadCurve(
                to: point,
                control: CGPoint(x: point.x + CGFloat(index % 2 == 0 ? -1 : 1) * size.width * 0.05, y: size.height * 0.58)
            )
            context.stroke(stem, with: .color(FlowerMapPalette.deepGreen.opacity(0.82)), style: StrokeStyle(lineWidth: 1.3, lineCap: .round))

            let petalRadius = size.width * 0.045
            for angle in stride(from: 0.0, to: Double.pi * 2, by: Double.pi / 4) {
                let petalCenter = CGPoint(x: point.x + cos(angle) * petalRadius * 1.5, y: point.y + sin(angle) * petalRadius * 1.1)
                context.fill(
                    Path(ellipseIn: CGRect(x: petalCenter.x - petalRadius, y: petalCenter.y - petalRadius, width: petalRadius * 1.9, height: petalRadius * 1.9)),
                    with: .color(color.opacity(usesWhitePetals ? 0.95 : 0.92))
                )
            }
            context.fill(
                Path(ellipseIn: CGRect(x: point.x - petalRadius * 0.58, y: point.y - petalRadius * 0.58, width: petalRadius * 1.16, height: petalRadius * 1.16)),
                with: .color(usesWhitePetals ? FlowerMapPalette.flowerYellow : Color.white.opacity(0.88))
            )
        }
    }

    private func drawBlueBloom(context: inout GraphicsContext, size: CGSize) {
        let base = CGPoint(x: size.width * 0.50, y: size.height * 0.82)
        for index in 0..<6 {
            let angle = -Double.pi * 0.78 + Double(index) * Double.pi * 0.28
            let end = CGPoint(
                x: base.x + cos(angle) * size.width * 0.32,
                y: base.y + sin(angle) * size.height * 0.48
            )
            var branch = Path()
            branch.move(to: base)
            branch.addQuadCurve(to: end, control: CGPoint(x: size.width * 0.50, y: size.height * 0.44))
            context.stroke(branch, with: .color(Color(red: 0.22, green: 0.58, blue: 0.92)), style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
            context.fill(Path(ellipseIn: CGRect(x: end.x - 3, y: end.y - 3, width: 6, height: 6)), with: .color(FlowerMapPalette.flowerPink.opacity(0.88)))
        }

        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.26, y: size.height * 0.72, width: size.width * 0.48, height: size.height * 0.12)), with: .color(FlowerMapPalette.flowerPurple.opacity(0.74)))
    }

    private func drawSmallTree(context: inout GraphicsContext, size: CGSize) {
        var trunk = Path()
        trunk.move(to: CGPoint(x: size.width * 0.50, y: size.height * 0.86))
        trunk.addLine(to: CGPoint(x: size.width * 0.50, y: size.height * 0.36))
        context.stroke(trunk, with: .color(Color(red: 0.28, green: 0.18, blue: 0.10)), style: StrokeStyle(lineWidth: 3.8, lineCap: .round))

        let blossom = Color(red: 0.96, green: 0.64, blue: 0.72)
        let crowns = [
            CGRect(x: size.width * 0.34, y: size.height * 0.23, width: size.width * 0.24, height: size.height * 0.19),
            CGRect(x: size.width * 0.48, y: size.height * 0.18, width: size.width * 0.25, height: size.height * 0.20),
            CGRect(x: size.width * 0.42, y: size.height * 0.30, width: size.width * 0.31, height: size.height * 0.18),
        ]
        for rect in crowns {
            context.fill(Path(ellipseIn: rect), with: .color(blossom.opacity(0.88)))
            context.stroke(Path(ellipseIn: rect), with: .color(Color.white.opacity(0.32)), lineWidth: 0.8)
        }
    }

    private func drawMushroomBloom(context: inout GraphicsContext, size: CGSize) {
        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.28, y: size.height * 0.44, width: size.width * 0.25, height: size.height * 0.36)), with: .color(Color(red: 0.48, green: 0.24, blue: 0.16)))
        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.46, y: size.height * 0.48, width: size.width * 0.22, height: size.height * 0.30)), with: .color(Color(red: 0.48, green: 0.24, blue: 0.16)))
        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.18, y: size.height * 0.20, width: size.width * 0.42, height: size.height * 0.30)), with: .color(Color(red: 0.07, green: 0.42, blue: 0.48)))
        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.45, y: size.height * 0.26, width: size.width * 0.36, height: size.height * 0.28)), with: .color(FlowerMapPalette.flowerPink))
        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.58, y: size.height * 0.36, width: 5, height: 5)), with: .color(Color.white.opacity(0.86)))
    }
}

private struct GrassPatchGlyph: View {
    let variant: Int

    var body: some View {
        Canvas { context, size in
            for index in 0..<5 {
                let frac = CGFloat(index) / 4
                var blade = Path()
                let x = size.width * (0.24 + frac * 0.52)
                blade.move(to: CGPoint(x: x, y: size.height * 0.76))
                blade.addQuadCurve(
                    to: CGPoint(x: x + CGFloat((index % 2 == 0) ? -1 : 1) * size.width * 0.08, y: size.height * (0.36 + CGFloat((variant + index) % 3) * 0.06)),
                    control: CGPoint(x: x, y: size.height * 0.54)
                )
                context.stroke(blade, with: .color(FlowerMapPalette.deepGreen.opacity(0.52)), style: StrokeStyle(lineWidth: 1.3, lineCap: .round))
            }
        }
    }
}

private struct FlowerCitySkylineView: View {
    let isLocked: Bool

    var body: some View {
        Canvas { context, size in
            let tint = isLocked ? Color.gray.opacity(0.42) : FlowerMapPalette.deepGreen.opacity(0.40)
            let baseY = size.height * 0.92
            var ground = Path()
            ground.move(to: CGPoint(x: 0, y: baseY))
            ground.addLine(to: CGPoint(x: size.width, y: baseY))
            context.stroke(ground, with: .color(tint.opacity(0.32)), lineWidth: 1)

            let buildings: [(CGFloat, CGFloat, CGFloat)] = [
                (0.12, 0.38, 0.08),
                (0.25, 0.62, 0.10),
                (0.40, 0.48, 0.12),
                (0.58, 0.78, 0.08),
                (0.74, 0.50, 0.10),
                (0.88, 0.36, 0.11),
            ]
            for building in buildings {
                let width = size.width * building.2
                let height = size.height * building.1
                let rect = CGRect(x: size.width * building.0 - width / 2, y: baseY - height, width: width, height: height)
                context.fill(Path(roundedRect: rect, cornerRadius: width * 0.18), with: .color(tint))
                var spire = Path()
                spire.move(to: CGPoint(x: rect.midX, y: rect.minY - height * 0.24))
                spire.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
                context.stroke(spire, with: .color(tint), lineWidth: 1.4)
            }

            var bridge = Path()
            bridge.move(to: CGPoint(x: size.width * 0.04, y: baseY))
            bridge.addQuadCurve(to: CGPoint(x: size.width * 0.96, y: baseY), control: CGPoint(x: size.width * 0.50, y: size.height * 0.54))
            context.stroke(bridge, with: .color(tint.opacity(0.56)), style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
        }
        .opacity(isLocked ? 0.62 : 1)
    }
}

private struct SeedlingBadgeView: View {
    let isPlanted: Bool

    var body: some View {
        Canvas { context, size in
            let bowl = CGRect(x: size.width * 0.16, y: size.height * 0.62, width: size.width * 0.68, height: size.height * 0.22)
            context.fill(Path(ellipseIn: bowl), with: .color(Color(red: 0.70, green: 0.54, blue: 0.28)))
            context.stroke(Path(ellipseIn: bowl.insetBy(dx: -1, dy: -1)), with: .color(Color.white.opacity(0.48)), lineWidth: 1.2)

            let soil = CGRect(x: size.width * 0.26, y: size.height * 0.59, width: size.width * 0.48, height: size.height * 0.16)
            context.fill(Path(ellipseIn: soil), with: .color(Color(red: 0.47, green: 0.34, blue: 0.18)))

            var stem = Path()
            stem.move(to: CGPoint(x: size.width * 0.50, y: size.height * 0.62))
            stem.addQuadCurve(to: CGPoint(x: size.width * 0.50, y: size.height * 0.20), control: CGPoint(x: size.width * 0.46, y: size.height * 0.42))
            context.stroke(stem, with: .color(Color.white.opacity(0.92)), style: StrokeStyle(lineWidth: 2.4, lineCap: .round))

            let leafColor = isPlanted ? Color(red: 0.80, green: 0.94, blue: 0.46) : Color(red: 0.68, green: 0.86, blue: 0.42)
            context.fill(Path(ellipseIn: CGRect(x: size.width * 0.24, y: size.height * 0.22, width: size.width * 0.30, height: size.height * 0.20)), with: .color(leafColor))
            context.fill(Path(ellipseIn: CGRect(x: size.width * 0.50, y: size.height * 0.20, width: size.width * 0.32, height: size.height * 0.21)), with: .color(leafColor.opacity(0.92)))

            if isPlanted {
                context.fill(Path(ellipseIn: CGRect(x: size.width * 0.13, y: size.height * 0.18, width: 4, height: 4)), with: .color(Color.white.opacity(0.86)))
                context.fill(Path(ellipseIn: CGRect(x: size.width * 0.84, y: size.height * 0.30, width: 4, height: 4)), with: .color(Color.white.opacity(0.86)))
            }
        }
        .accessibilityHidden(true)
    }
}

private struct FlowerPlantGuideBadge: View {
    let isPlanted: Bool
    let isLocked: Bool

    private var ringColor: Color {
        if isLocked {
            return VitoraTheme.ColorToken.secondaryText.opacity(0.38)
        }

        return isPlanted ? FlowerMapPalette.sun.opacity(0.82) : FlowerMapPalette.deepGreen.opacity(0.58)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(isPlanted ? 0.26 : 0.42))
                .overlay(
                    Circle()
                        .stroke(
                            ringColor,
                            style: StrokeStyle(lineWidth: 1.8, lineCap: .round, dash: [3.2, 5.4])
                        )
                )
                .shadow(color: FlowerMapPalette.deepGreen.opacity(isPlanted ? 0.03 : 0.12), radius: 14, x: 0, y: 8)

            if isPlanted {
                SunflowerGuideGlyph()
                    .frame(width: 43, height: 48)
                    .opacity(isLocked ? 0.32 : 0.70)
            } else {
                SeedlingBadgeView(isPlanted: false)
                    .frame(width: 42, height: 42)
                    .opacity(isLocked ? 0.30 : 0.96)
            }
        }
        .overlay(alignment: .bottom) {
            Image(systemName: "chevron.compact.down")
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(ringColor.opacity(isPlanted ? 0.58 : 0.86))
                .offset(y: 13)
                .opacity(isLocked ? 0 : 1)
        }
        .accessibilityHidden(true)
    }
}

private struct SunflowerGuideGlyph: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width * 0.50, y: size.height * 0.28)
            let petalColor = Color(red: 0.96, green: 0.67, blue: 0.12)
            let petalSize = CGSize(width: size.width * 0.17, height: size.height * 0.27)

            for index in 0..<12 {
                let angle = CGFloat(index) * .pi * 2 / 12
                let petalCenter = CGPoint(
                    x: center.x + cos(angle) * size.width * 0.19,
                    y: center.y + sin(angle) * size.height * 0.15
                )
                let rect = CGRect(
                    x: petalCenter.x - petalSize.width / 2,
                    y: petalCenter.y - petalSize.height / 2,
                    width: petalSize.width,
                    height: petalSize.height
                )
                context.fill(Path(ellipseIn: rect), with: .color(petalColor.opacity(0.92)))
            }

            context.fill(
                Path(ellipseIn: CGRect(x: center.x - size.width * 0.14, y: center.y - size.width * 0.14, width: size.width * 0.28, height: size.width * 0.28)),
                with: .color(Color(red: 0.70, green: 0.36, blue: 0.11))
            )
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - size.width * 0.07, y: center.y - size.width * 0.07, width: size.width * 0.14, height: size.width * 0.14)),
                with: .color(Color(red: 0.86, green: 0.51, blue: 0.13))
            )

            var stem = Path()
            stem.move(to: CGPoint(x: center.x, y: center.y + size.height * 0.16))
            stem.addLine(to: CGPoint(x: center.x, y: size.height * 0.84))
            context.stroke(stem, with: .color(Color(red: 0.28, green: 0.56, blue: 0.22)), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))

            context.fill(
                Path(ellipseIn: CGRect(x: size.width * 0.17, y: size.height * 0.57, width: size.width * 0.30, height: size.height * 0.18)),
                with: .color(Color(red: 0.45, green: 0.74, blue: 0.30))
            )
            context.fill(
                Path(ellipseIn: CGRect(x: size.width * 0.53, y: size.height * 0.53, width: size.width * 0.30, height: size.height * 0.18)),
                with: .color(Color(red: 0.53, green: 0.79, blue: 0.34))
            )
        }
        .accessibilityHidden(true)
    }
}

private struct FlowerRouteNodeView: View {
    let title: String
    let isActive: Bool
    let isLocked: Bool

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(
                    isActive
                        ? FlowerMapPalette.deepGreen
                        : (isLocked ? VitoraTheme.ColorToken.secondaryText.opacity(0.28) : FlowerMapPalette.leaf.opacity(0.62))
                )
                .frame(width: 13, height: 13)
                .shadow(color: FlowerMapPalette.deepGreen.opacity(isActive ? 0.18 : 0.04), radius: 6, x: 0, y: 3)

            Text(title)
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(isActive ? FlowerMapPalette.deepGreen : VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}

private struct FlowerRouteProgressDotsView: View {
    let progress: CGFloat
    let isComplete: Bool

    private let dotCount = 12

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<dotCount, id: \.self) { index in
                let filledCount = Int((progress * CGFloat(dotCount)).rounded(.down))
                let isFilled = isComplete || index < filledCount

                Circle()
                    .fill(isFilled ? FlowerMapPalette.deepGreen.opacity(0.76) : VitoraTheme.ColorToken.secondaryText.opacity(0.24))
                    .frame(width: 5.6, height: 5.6)
                    .shadow(color: FlowerMapPalette.deepGreen.opacity(isFilled ? 0.10 : 0), radius: 3, x: 0, y: 1)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }
}

private struct FlowerRouteLineView: View {
    let isComplete: Bool

    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: 2, y: size.height / 2))
            path.addLine(to: CGPoint(x: size.width - 2, y: size.height / 2))
            context.stroke(
                path,
                with: .color((isComplete ? FlowerMapPalette.deepGreen : FlowerMapPalette.deepGreen.opacity(0.58))),
                style: StrokeStyle(lineWidth: 2.2, lineCap: .round, dash: isComplete ? [] : [5, 5])
            )
        }
        .accessibilityHidden(true)
    }
}

private struct MiniFlowerIconView: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width * 0.50, y: size.height * 0.36)
            let petal = CGSize(width: size.width * 0.22, height: size.height * 0.25)
            let petalColor = Color(red: 0.93, green: 0.46, blue: 0.64)

            for index in 0..<6 {
                let angle = CGFloat(index) * .pi * 2 / 6
                let point = CGPoint(
                    x: center.x + cos(angle) * size.width * 0.17,
                    y: center.y + sin(angle) * size.height * 0.15
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: point.x - petal.width / 2, y: point.y - petal.height / 2, width: petal.width, height: petal.height)),
                    with: .color(petalColor)
                )
            }

            context.fill(
                Path(ellipseIn: CGRect(x: center.x - size.width * 0.09, y: center.y - size.width * 0.09, width: size.width * 0.18, height: size.width * 0.18)),
                with: .color(FlowerMapPalette.sun)
            )

            var stem = Path()
            stem.move(to: CGPoint(x: center.x, y: size.height * 0.50))
            stem.addLine(to: CGPoint(x: center.x, y: size.height * 0.88))
            context.stroke(stem, with: .color(FlowerMapPalette.deepGreen.opacity(0.74)), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))

            context.fill(
                Path(ellipseIn: CGRect(x: size.width * 0.25, y: size.height * 0.62, width: size.width * 0.22, height: size.height * 0.12)),
                with: .color(FlowerMapPalette.leaf.opacity(0.84))
            )
        }
        .accessibilityHidden(true)
    }
}

private struct FlowerRouteDotsView: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: 2, y: size.height / 2))
            path.addLine(to: CGPoint(x: size.width - 12, y: size.height / 2))
            context.stroke(path, with: .color(FlowerMapPalette.deepGreen.opacity(0.75)), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [2, 8]))

            var arrow = Path()
            arrow.move(to: CGPoint(x: size.width - 13, y: size.height / 2 - 5))
            arrow.addLine(to: CGPoint(x: size.width - 4, y: size.height / 2))
            arrow.addLine(to: CGPoint(x: size.width - 13, y: size.height / 2 + 5))
            context.stroke(arrow, with: .color(FlowerMapPalette.deepGreen.opacity(0.82)), style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
        }
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }
}

private struct FlowerMapInfoCard: View {
    let title: String
    let lines: [String]
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(FlowerMapPalette.deepGreen)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("关闭")
            }

            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(width: 188, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.94))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.86), lineWidth: 0.8)
                )
                .shadow(color: Color.black.opacity(0.10), radius: 16, x: 0, y: 8)
        )
    }
}

private struct FlowerHandbookSheetView: View {
    private let flowerTypes = [
        ("黄花", "恢复资源", "常见"),
        ("粉花", "情绪回暖", "常见"),
        ("蓝紫花", "睡眠线索", "稀有"),
        ("小树", "阶段节点", "稀有"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Capsule()
                .fill(VitoraTheme.ColorToken.secondaryText.opacity(0.22))
                .frame(width: 42, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("花朵说明")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(FlowerMapPalette.deepGreen)
                    Text("已收集 1 / 34")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }

                Spacer()

                SeedlingBadgeView(isPlanted: true)
                    .frame(width: 48, height: 48)
            }

            VStack(spacing: 10) {
                ForEach(flowerTypes, id: \.0) { flower in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(FlowerMapPalette.deepGreen.opacity(0.10))
                            .frame(width: 34, height: 34)
                            .overlay {
                                Image(systemName: flower.2 == "稀有" ? "sparkles" : "leaf.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(FlowerMapPalette.deepGreen)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(flower.0)
                                .font(.system(size: 15, weight: .heavy))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            Text(flower.1)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        }

                        Spacer()

                        Text(flower.2)
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(FlowerMapPalette.deepGreen)
                            .padding(.horizontal, 9)
                            .frame(height: 24)
                            .background(FlowerMapPalette.deepGreen.opacity(0.08), in: Capsule())
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.72))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.78), lineWidth: 0.8)
                            )
                    )
                }
            }

            Text("这里只说明花朵类型、稀有度和已收集预览。")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .background(WaterAuraReferenceBackground(scene: .cycle, intensity: 0.72))
    }
}

private enum FlowerProgressIcon {
    case seedling
    case city(isLocked: Bool)
}

private struct FlowerProgressCard: View {
    let icon: FlowerProgressIcon
    let title: String
    let primary: String
    let caption: String?
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 5) {
            iconView
                .frame(width: 38, height: 30)

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Text(primary)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(isSelected ? FlowerMapPalette.deepGreen : VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            if let caption {
                Text(caption)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(isSelected ? FlowerMapPalette.deepGreen : VitoraTheme.ColorToken.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity)
        .frame(height: 88)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(isSelected ? 0.94 : 0.78))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(isSelected ? FlowerMapPalette.deepGreen.opacity(0.82) : Color.white.opacity(0.78), lineWidth: isSelected ? 1.2 : 0.8)
                )
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(isSelected ? 0.12 : 0.06), radius: 12, x: 0, y: 5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title)，\(primary)\(caption.map { "，\($0)" } ?? "")")
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .seedling:
            SeedlingBadgeView(isPlanted: false)
        case let .city(isLocked):
            FlowerCitySkylineView(isLocked: isLocked)
        }
    }
}

private enum CycleReviewCardPresentation {
    case standalone
    case embedded
}

private struct CycleReviewInsightCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let selectedTab: CycleReviewTab
    var presentation: CycleReviewCardPresentation = .standalone

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                if selectedTab != .week {
                    reportHeader
                }

                Group {
                    switch selectedTab {
                    case .week:
                        CycleReportWeekContent(accent: selectedTab.accent)
                    case .trend:
                        CycleReportTrendContent(accent: selectedTab.accent)
                    case .recent:
                        CycleReportRecentContent(accent: selectedTab.accent)
                    }
                }
                .id(selectedTab)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
            }
            .padding(presentation == .embedded ? 8 : 16)
            .background(
                Group {
                    if presentation == .standalone {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(selectedTab.paperFill)
                            .overlay(
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .stroke(Color.white.opacity(0.78), lineWidth: 0.9)
                            )
                            .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.08), radius: 14, x: 0, y: 7)
                    }
                }
            )
            .accessibilityIdentifier("cycle.review.insights")
        }
    }

    private var reportHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(selectedTab.title)
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Text(selectedTab.subtitle)
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(selectedTab.accent)
                }

                Spacer()

                Text(selectedTab.badge)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(selectedTab.accent)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(selectedTab.accent.opacity(0.12), in: Capsule())
            }

            HStack(spacing: 7) {
                ForEach(selectedTab.statusItems, id: \.self) { status in
                    Text(status)
                        .font(.system(size: 10.5, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                        .padding(.horizontal, 8)
                        .frame(height: 26)
                        .background(Color.white.opacity(0.56), in: Capsule())
                }
            }
        }
    }
}

private enum CycleReviewTab: String, CaseIterable, Identifiable {
    case week
    case trend
    case recent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .week:
            return "本周"
        case .trend:
            return "趋势（对比）"
        case .recent:
            return "近期"
        }
    }

    var segmentTitle: String {
        switch self {
        case .week:
            return "本周"
        case .trend:
            return "趋势对比"
        case .recent:
            return "近期"
        }
    }

    var subtitle: String {
        switch self {
        case .week:
            return "This Week"
        case .trend:
            return "Trend Comparison"
        case .recent:
            return "Recent"
        }
    }

    var badge: String {
        switch self {
        case .week:
            return "恢复 A-"
        case .trend:
            return "恢复 B+"
        case .recent:
            return "状态良好"
        }
    }

    var statusItems: [String] {
        switch self {
        case .week:
            return ["黄体期 D18", "低谷时段 14-16 点", "恢复 A-"]
        case .trend:
            return ["较上月改善", "整体上升", "恢复 B+"]
        case .recent:
            return ["黄体期中后段", "能量回升中", "状态良好"]
        }
    }

    var accent: Color {
        switch self {
        case .week:
            return Color(red: 0.86, green: 0.42, blue: 0.54)
        case .trend:
            return VitoraTheme.ColorToken.actionPrimaryDeep
        case .recent:
            return Color(red: 0.76, green: 0.58, blue: 0.20)
        }
    }

    var paperFill: Color {
        switch self {
        case .week:
            return Color(red: 1.00, green: 0.97, blue: 0.96).opacity(0.92)
        case .trend:
            return Color(red: 0.95, green: 0.98, blue: 1.00).opacity(0.92)
        case .recent:
            return Color(red: 1.00, green: 0.98, blue: 0.91).opacity(0.92)
        }
    }

    var accessibilityID: String {
        switch self {
        case .week:
            return "cycle.review.tab.week"
        case .trend:
            return "cycle.review.tab.trend"
        case .recent:
            return "cycle.review.tab.recent"
        }
    }
}

private struct CycleReportWeekContent: View {
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            CycleWeeklyReviewHero(accent: accent)

            CycleWeeklyReviewInfoPanel(accent: accent)
        }
    }
}

private struct CycleWeeklyReviewHero: View {
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("05.21 — 05.27 2026")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 8)

                CycleReportMiniCounters()
            }

            HStack(spacing: 7) {
                ForEach(["黄体期 D18", "低谷 14-16 点", "恢复 A-"], id: \.self) { status in
                    Text(status)
                        .font(.system(size: 10.5, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                        .padding(.horizontal, 8)
                        .frame(height: 26)
                        .background(Color.white.opacity(0.56), in: Capsule())
                }
            }

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("本周复盘")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Text("用高低变化看本周能量，不把它变成任务。")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 0) {
                    Text("62")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Text("/100")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("本周平均六十二分")
            }

            CycleWeeklyEnergyBarsView(accent: accent)
                .frame(height: 168)
        }
    }
}

private struct CycleReportMiniCounters: View {
    var body: some View {
        HStack(spacing: 10) {
            miniCounter(systemName: "leaf.circle.fill", value: "24")
            miniCounter(systemName: "flame.circle.fill", value: "0")
        }
        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("花朵二十四，待确认零")
    }

    private func miniCounter(systemName: String, value: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .bold))
            Text(value)
                .font(.system(size: 12, weight: .heavy))
                .monospacedDigit()
        }
    }
}

private struct CycleWeeklyEnergyBarsView: View {
    let accent: Color

    private var data: [CycleEnergyBarDatum] {
        [
            .init(day: "一", value: 68, color: Color(red: 0.98, green: 0.73, blue: 0.20), icon: "sun.max.fill"),
            .init(day: "二", value: 54, color: Color(red: 0.98, green: 0.53, blue: 0.20), icon: "leaf.fill"),
            .init(day: "三", value: 72, color: Color(red: 0.20, green: 0.58, blue: 0.92), icon: "equal.circle.fill"),
            .init(day: "四", value: 42, color: Color(red: 0.65, green: 0.48, blue: 0.95), icon: "moon.fill"),
            .init(day: "五", value: 58, color: Color(red: 0.45, green: 0.86, blue: 0.20), icon: "wind"),
            .init(day: "六", value: 48, color: Color(red: 1.00, green: 0.35, blue: 0.28), icon: "exclamationmark.circle.fill"),
            .init(day: "日", value: 65, color: accent, icon: "heart.fill"),
        ]
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(data) { item in
                VStack(spacing: 6) {
                    Text("\(item.value)%")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(Color.white.opacity(0.94))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                        .padding(.horizontal, 4)
                        .frame(height: 24)
                        .background(item.color.opacity(0.88), in: Capsule())

                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    item.color.opacity(0.95),
                                    item.color.opacity(0.52),
                                    item.color.opacity(0.12),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: max(26, CGFloat(item.value) * 1.02))
                        .overlay(alignment: .bottom) {
                            Image(systemName: item.icon)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(item.color.opacity(0.86))
                                .frame(width: 24, height: 24)
                                .background(Color.white.opacity(0.28), in: Circle())
                                .padding(.bottom, 7)
                        }

                    Text(item.day)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("本周能量柱状复盘，最高七十二，最低四十二")
    }
}

private struct CycleEnergyBarDatum: Identifiable {
    var id: String { day }
    let day: String
    let value: Int
    let color: Color
    let icon: String
}

private struct CycleWeeklyReviewInfoPanel: View {
    let accent: Color

    private let distributionRows: [CycleDistributionDatum] = [
        .init(title: "稳定恢复", value: "42%", detail: "上午更稳", color: Color(red: 0.63, green: 0.74, blue: 0.30), percent: 0.42),
        .init(title: "低谷窗口", value: "31%", detail: "14-16 点", color: Color(red: 0.90, green: 0.43, blue: 0.34), percent: 0.31),
        .init(title: "睡眠影响", value: "24%", detail: "2 晚偏低", color: Color(red: 0.39, green: 0.77, blue: 0.82), percent: 0.24),
        .init(title: "待校准", value: "3%", detail: "继续观察", color: Color(red: 0.47, green: 0.76, blue: 0.59), percent: 0.03),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 16) {
                CycleReportDonutView(segments: distributionRows.map { ($0.percent, $0.color) })
                    .frame(width: 112, height: 112)

                VStack(alignment: .leading, spacing: 9) {
                    Text("影响来源分布")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    ForEach(distributionRows, id: \.title) { row in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(row.color)
                                .frame(width: 8, height: 8)

                            Text(row.title)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                                .lineLimit(1)

                            Spacer(minLength: 4)

                            Text(row.value)
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                                .monospacedDigit()

                            Text(row.detail)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                                .lineLimit(1)
                        }
                    }
                }
            }

            Divider()
                .overlay(VitoraTheme.ColorToken.secondaryText.opacity(0.13))

            CycleReportThreeLines(
                rows: [
                    ("重点发现", "高低差主要集中在午后，上午恢复更稳定。"),
                    ("为什么", "睡眠、HRV 和黄体期位置一起解释这周波动。"),
                    ("下周建议", "保留周一缓冲，把高强度安排拆成更小块。"),
                ],
                accent: accent,
                showsBackground: false
            )

            CycleReportMetricGrid(
                items: [
                    ("平均", "62%"),
                    ("低谷", "14-16"),
                    ("校准", "3 天"),
                    ("周期", "D18"),
                ],
                accent: accent
            )

            CycleReportProgressLine(title: "当前周期进度", value: "黄体期 D18", progress: 0.64, accent: accent)
        }
        .padding(14)
        .background(Color.white.opacity(0.34), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(VitoraTheme.ColorToken.secondaryText.opacity(0.26), lineWidth: 0.9)
        )
    }
}

private struct CycleDistributionDatum: Identifiable {
    var id: String { title }
    let title: String
    let value: String
    let detail: String
    let color: Color
    let percent: CGFloat
}

private struct CycleReportDonutView: View {
    let segments: [(value: CGFloat, color: Color)]

    var body: some View {
        Canvas { context, size in
            let lineWidth = min(size.width, size.height) * 0.18
            let radius = min(size.width, size.height) * 0.40
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            var startAngle = -CGFloat.pi / 2

            for segment in segments {
                let endAngle = startAngle + segment.value * 2 * .pi
                var path = Path()
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .radians(Double(startAngle)),
                    endAngle: .radians(Double(endAngle)),
                    clockwise: false
                )
                context.stroke(
                    path,
                    with: .color(segment.color.opacity(0.88)),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                )
                startAngle = endAngle
            }
        }
        .overlay {
            Circle()
                .stroke(VitoraTheme.ColorToken.secondaryText.opacity(0.18), lineWidth: 1)
        }
        .accessibilityHidden(true)
    }
}

private struct CycleReportTrendContent: View {
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(accent)
                    .frame(width: 40, height: 40)
                    .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text("月度综合对比")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Text("平均能量、低谷天和深睡恢复都比上月更稳。")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(spacing: 10) {
                CycleReportProgressLine(title: "平均能量", value: "62%", progress: 0.62, accent: accent)
                CycleReportProgressLine(title: "深睡恢复", value: "B+", progress: 0.74, accent: accent)
                CycleReportProgressLine(title: "低谷减少", value: "-3 天", progress: 0.68, accent: accent)
                CycleReportProgressLine(title: "周期稳定", value: "28 天", progress: 0.78, accent: accent)
            }

            CycleReportThreeLines(
                rows: [
                    ("归因解释", "深睡增加和轻运动反馈让午后低谷缩短。"),
                    ("本月总结", "整体节律向上，但仍保留三天校准窗口。"),
                ],
                accent: accent
            )
        }
    }
}

private struct CycleReportRecentContent: View {
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("近期能量")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            CycleReportLineChart(accent: accent)
                .frame(height: 126)

            CycleReportThreeLines(
                rows: [
                    ("监测到了什么", "黄体期中后段开始回升，低谷没有继续加深。"),
                    ("近期结论", "这几天适合稳住恢复，不需要强行加量。"),
                    ("下一步", "继续观察睡眠和午后反馈。"),
                ],
                accent: accent
            )

            Button {} label: {
                HStack(spacing: 8) {
                    Text("告诉 Vitora 近期感受")
                        .font(.system(size: 13, weight: .heavy))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .heavy))
                }
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(Color.white.opacity(0.42), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(accent.opacity(0.54), lineWidth: 1.2)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("告诉 Vitora 近期感受")
        }
    }
}

private struct CycleReportBarChart: View {
    let accent: Color
    private let values: [CGFloat] = [0.48, 0.58, 0.42, 0.66, 0.72, 0.64, 0.70]
    private let labels = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(values.indices, id: \.self) { index in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [accent.opacity(0.90), accent.opacity(0.34)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 78 * values[index])
                        .frame(maxHeight: 86, alignment: .bottom)

                    Text(labels[index])
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.44), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct CycleReportLineChart: View {
    let accent: Color
    private let values: [CGFloat] = [0.42, 0.46, 0.40, 0.55, 0.62, 0.68, 0.73]

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack(alignment: .topLeading) {
                Canvas { context, _ in
                    let gridFractions: [CGFloat] = [0.25, 0.50, 0.75]
                    for frac in gridFractions {
                        var grid = Path()
                        grid.move(to: CGPoint(x: 0, y: height * frac))
                        grid.addLine(to: CGPoint(x: width, y: height * frac))
                        context.stroke(grid, with: .color(VitoraTheme.ColorToken.secondaryText.opacity(0.14)), style: StrokeStyle(lineWidth: 1, dash: [4, 5]))
                    }

                    var path = Path()
                    for index in values.indices {
                        let point = chartPoint(index: index, width: width, height: height)
                        if index == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                    context.stroke(path, with: .color(accent), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                }

                ForEach(values.indices, id: \.self) { index in
                    Circle()
                        .fill(index == values.count - 1 ? accent : Color.white)
                        .overlay(Circle().stroke(accent.opacity(0.82), lineWidth: 2))
                        .frame(width: index == values.count - 1 ? 12 : 9, height: index == values.count - 1 ? 12 : 9)
                        .position(chartPoint(index: index, width: width, height: height))
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.42), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func chartPoint(index: Int, width: CGFloat, height: CGFloat) -> CGPoint {
        let value = values[index]
        return CGPoint(
            x: width * CGFloat(index) / CGFloat(values.count - 1),
            y: height * (1 - value) * 0.72 + height * 0.12
        )
    }
}

private struct CycleReportThreeLines: View {
    let rows: [(title: String, body: String)]
    let accent: Color
    var showsBackground = true

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(rows, id: \.title) { row in
                HStack(alignment: .top, spacing: 9) {
                    Circle()
                        .fill(accent.opacity(0.78))
                        .frame(width: 7, height: 7)
                        .offset(y: 6)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.title)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        Text(row.body)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(showsBackground ? 12 : 0)
        .background {
            if showsBackground {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.42))
            }
        }
    }
}

private struct CycleReportMetricGrid: View {
    let items: [(title: String, value: String)]
    let accent: Color

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            ForEach(items, id: \.title) { item in
                VStack(spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    Text(item.value)
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white.opacity(0.46), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(accent.opacity(0.12), lineWidth: 0.8)
                )
            }
        }
    }
}

private struct CycleReportProgressLine: View {
    let title: String
    let value: String
    let progress: CGFloat
    let accent: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            GeometryReader { proxy in
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.56))
                    .overlay(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(accent.opacity(0.82))
                            .frame(width: max(12, proxy.size.width * min(1, max(0, progress))))
                    }
            }
            .frame(height: 8)

            Text(value)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .frame(width: 52, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
    }
}

private struct CycleReviewSnapshotGrid: View {
    private let primaryItems: [CycleReviewSnapshotItem] = [
        .init(title: "当前阶段", value: "黄体期 D18", caption: "以今天的位置理解波动"),
        .init(title: "本周平均", value: "62%", caption: "较上周 ↑5%"),
    ]
    private let secondaryItems: [CycleReviewSnapshotItem] = [
        .init(title: "低谷窗口", value: "14:00-16:00", caption: "午后保留余量"),
        .init(title: "待确认", value: "3 天", caption: "继续用记录校准"),
    ]

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                CycleReviewSnapshotMetric(item: primaryItems[0], prominence: .primary)

                Divider()
                    .overlay(VitoraTheme.ColorToken.secondaryText.opacity(0.16))
                    .frame(height: 46)
                    .padding(.horizontal, 10)

                CycleReviewSnapshotMetric(item: primaryItems[1], prominence: .primary)
            }

            Divider()
                .overlay(VitoraTheme.ColorToken.secondaryText.opacity(0.12))

            HStack(spacing: 0) {
                CycleReviewSnapshotMetric(item: secondaryItems[0], prominence: .secondary)

                Divider()
                    .overlay(VitoraTheme.ColorToken.secondaryText.opacity(0.12))
                    .frame(height: 28)
                    .padding(.horizontal, 10)

                CycleReviewSnapshotMetric(item: secondaryItems[1], prominence: .secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(VitoraTheme.ColorToken.paper.opacity(0.50), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.68), lineWidth: 0.7)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("周期摘要，黄体期第十八天，本周平均百分之六十二，低谷窗口十四点到十六点，仍需三天确认")
    }
}

private struct CycleReviewSnapshotMetric: View {
    enum Prominence {
        case primary
        case secondary
    }

    let item: CycleReviewSnapshotItem
    let prominence: Prominence

    var body: some View {
        VStack(alignment: .leading, spacing: prominence == .primary ? 4 : 2) {
            Text(item.title)
                .font(.system(size: prominence == .primary ? 10.5 : 9.5, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Text(item.value)
                .font(.system(size: prominence == .primary ? 18 : 13, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            Text(item.caption)
                .font(.system(size: prominence == .primary ? 10 : 9.5, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CycleReviewSnapshotItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let caption: String
}

private struct CycleReviewRowModel: Identifiable {
    var id: String { title }
    let icon: String
    let title: String
    let caption: String
    let value: String
    let tint: Color
}

private struct CycleReviewInsightRow: View {
    let row: CycleReviewRowModel

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: row.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(row.tint)
                .frame(width: 25, height: 25)
                .background(row.tint.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(row.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text(row.caption)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 8)

            Text(row.value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.64))
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(row.title)，\(row.caption)，\(row.value)")
    }
}

private enum CycleRhythmInsight: String, CaseIterable, Identifiable {
    case regularity
    case support
    case adjustment

    var id: String { rawValue }

    var title: String {
        switch self {
        case .regularity:
            return "规律模式"
        case .support:
            return "有效助力"
        case .adjustment:
            return "下周期调整"
        }
    }

    var summary: String {
        switch self {
        case .regularity:
            return "稳定波动"
        case .support:
            return "轻量运动"
        case .adjustment:
            return "周一缓冲"
        }
    }

    var body: String {
        switch self {
        case .regularity:
            return "过去 30 天里，能量低谷更常集中在 14:00-16:00，上午恢复感通常更稳。"
        case .support:
            return "轻量运动和提前补充蛋白更容易让晚间反馈变成“有帮助”。"
        case .adjustment:
            return "下个周期的周一建议先留缓冲，把高强度安排放到上午。"
        }
    }

    var evidence: [String] {
        switch self {
        case .regularity:
            return ["低谷集中窗口 14:00-16:00", "恢复较好时段 上午", "仍需 3 天确认"]
        case .support:
            return ["轻走 10 分钟后反馈更好", "蛋白补充靠近低谷前", "只作为身体观察"]
        case .adjustment:
            return ["黄体期中段更需要余量", "周三后恢复变慢", "下周期先保留周一缓冲"]
        }
    }

    var recommendation: String {
        switch self {
        case .regularity:
            return "今天先把需要专注的事放到上午，午后只保留一件轻安排。"
        case .support:
            return "继续保留轻走和蛋白补充，但不把它变成每日压力。"
        case .adjustment:
            return "下周期第 1 周先把强安排拆小，等 Vitora 再确认三天趋势。"
        }
    }

    var symbol: String {
        switch self {
        case .regularity:
            return "calendar"
        case .support:
            return "leaf"
        case .adjustment:
            return "slider.horizontal.3"
        }
    }

    var tint: Color {
        switch self {
        case .regularity:
            return VitoraTheme.ColorToken.auraBlue
        case .support:
            return VitoraTheme.ColorToken.success
        case .adjustment:
            return VitoraTheme.ColorToken.actionPrimaryDeep
        }
    }
}

private struct CycleInsightSwitcher: View {
    @State private var selected: CycleRhythmInsight = .regularity
    let onOpenDetail: (CycleRhythmInsight) -> Void
    let onAskVitora: (CycleRhythmInsight) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 3) {
                ForEach(CycleRhythmInsight.allCases) { insight in
                    Button {
                        withAnimation(.easeOut(duration: 0.18)) {
                            selected = insight
                        }
                    } label: {
                        Text(insight.title)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(selected == insight ? VitoraTheme.ColorToken.strongText : VitoraTheme.ColorToken.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(selected == insight ? VitoraTheme.ColorToken.paper.opacity(0.86) : Color.clear, in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(selected == insight ? Color.white.opacity(0.72) : Color.clear, lineWidth: 0.7)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("cycle.insight.tab.\(insight.id)")
                }
            }
            .padding(4)
            .background(GlassSurface(cornerRadius: 20, opacity: 0.52, shadowStrength: 0.16, variant: .cleanResting))

            Button {
                onOpenDetail(selected)
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: selected.symbol)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(selected.tint)
                            .frame(width: 34, height: 34)
                            .background(selected.tint.opacity(0.13), in: Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(selected.title)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            Text(selected.summary)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(selected.tint)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.62))
                    }

                    Text(selected.body)
                        .font(.system(size: 14, weight: .semibold))
                        .lineSpacing(3)
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 7) {
                        ForEach(selected.evidence.prefix(2), id: \.self) { evidence in
                            Text(evidence)
                                .font(.system(size: 10.5, weight: .bold))
                                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                                .padding(.horizontal, 8)
                                .frame(height: 26)
                                .background(VitoraTheme.ColorToken.paper.opacity(0.42), in: Capsule())
                        }
                    }
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(GlassSurface(cornerRadius: 24, opacity: 0.66, shadowStrength: 0.34, variant: .cleanResting))
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button("问 Vitora", action: { onAskVitora(selected) })
                Button("查看详情", action: { onOpenDetail(selected) })
            }
            .id(selected)
            .transition(.opacity)
            .accessibilityIdentifier("cycle.insight.open")
        }
        .padding(14)
        .background(GlassSurface(cornerRadius: 26, opacity: 0.66, shadowStrength: 0.42, variant: .cleanElevated))
    }
}
private struct CycleInsightDetailSheet: View {
    let insight: CycleRhythmInsight
    let onClose: () -> Void
    let onAskVitora: () -> Void

    var body: some View {
        cycleDetailContainer(title: insight.title, subtitle: "Vitora 如何把这条洞察联动到今天", onClose: onClose) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: insight.symbol)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(insight.tint)
                        .frame(width: 38, height: 38)
                        .background(insight.tint.opacity(0.13), in: Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text(insight.summary)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        Text("基于能量动态、周期阶段和晚间复盘。")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }
                }

                Text(insight.body)
                    .font(.subheadline.weight(.semibold))
                    .lineSpacing(4)
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GlassSurface(cornerRadius: 24, opacity: 0.70, shadowStrength: 0.32, variant: .cleanElevated))

            cycleInfoBlock(title: "Vitora 看到的证据", lines: insight.evidence)
            cycleInfoBlock(title: "今天怎么联动", lines: [insight.recommendation])

            Button(action: onAskVitora) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .bold))
                    Text("告诉 Vitora 这条洞察不准")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                }
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .padding(.horizontal, 15)
                .frame(minHeight: 48)
                .background(GlassSurface(cornerRadius: 20, opacity: 0.68, shadowStrength: 0.24, variant: .cleanResting))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("cycle.insight.askVitora")
        }
        .accessibilityIdentifier("cycle.insight.detail.sheet")
    }
}
private enum CycleSheet: Identifiable {
    case phase
    case energy
    case settings
    case insight(CycleRhythmInsight)
    case sharePreview

    var id: String {
        switch self {
        case .phase: return "phase"
        case .energy: return "energy"
        case .settings: return "settings"
        case let .insight(insight): return "insight.\(insight.id)"
        case .sharePreview: return "sharePreview"
        }
    }
}

// MARK: - Weekly Energy Curve

private struct CycleWeeklyEnergyCurve: View {
    @State private var selectedPoint: Int? = nil

    private struct PointData {
        let day: String
        let pct: Int
        let tag: String
        let tagColor: Color
        let relation: String
        let observation: String
    }

    private let points: [PointData] = [
        PointData(day: "周日", pct: 68, tag: "", tagColor: .clear, relation: "状态平稳", observation: "基线水平"),
        PointData(day: "周一", pct: 48, tag: "低谷", tagColor: Color(red: 0.95, green: 0.72, blue: 0.28), relation: "睡眠偏短 · HRV 回落", observation: "恢复变慢"),
        PointData(day: "周二", pct: 64, tag: "恢复", tagColor: Color(red: 0.38, green: 0.78, blue: 0.52), relation: "深睡增加", observation: "开始回升"),
        PointData(day: "周三", pct: 36, tag: "", tagColor: .clear, relation: "睡眠偏短 · HRV 回落", observation: "恢复变慢"),
        PointData(day: "周四", pct: 82, tag: "高点", tagColor: Color(red: 0.92, green: 0.52, blue: 0.52), relation: "运动 + 深睡充足", observation: "能量峰值"),
        PointData(day: "周五", pct: 72, tag: "", tagColor: .clear, relation: "节奏平稳", observation: "维持较好"),
        PointData(day: "周六", pct: 70, tag: "今天", tagColor: Color(red: 0.42, green: 0.62, blue: 0.90), relation: "周期黄体期", observation: "适合留余量"),
    ]

    private var values: [CGFloat] { points.map { CGFloat($0.pct) / 100.0 } }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { proxy in
                let w = proxy.size.width
                let h = proxy.size.height
                let padL: CGFloat = 36, padR: CGFloat = 8, padT: CGFloat = 28, padB: CGFloat = 24
                let chartW = w - padL - padR, chartH = h - padT - padB

                ZStack(alignment: .topLeading) {
                    // Y-axis
                    ForEach([("100%", 0.0), ("50%", 0.5), ("0%", 1.0)], id: \.0) { label, frac in
                        Text(label).font(.system(size: 9, weight: .medium)).foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                            .position(x: 16, y: padT + chartH * frac)
                    }

                    // Grid + curve
                    Canvas { ctx, _ in
                        for frac in [0.0, 0.5, 1.0] {
                            let y = padT + chartH * frac
                            var p = Path(); p.move(to: CGPoint(x: padL, y: y)); p.addLine(to: CGPoint(x: w - padR, y: y))
                            ctx.stroke(p, with: .color(Color.gray.opacity(0.12)), style: StrokeStyle(lineWidth: 0.8, dash: [3, 5]))
                        }
                        var curve = Path()
                        for (i, val) in values.enumerated() {
                            let x = padL + chartW * CGFloat(i) / CGFloat(values.count - 1)
                            let y = padT + chartH * (1 - val)
                            if i == 0 { curve.move(to: CGPoint(x: x, y: y)) } else { curve.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        ctx.stroke(curve, with: .color(VitoraTheme.ColorToken.actionPrimaryDeep), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    }

                    // Dots + tap targets
                    ForEach(0..<points.count, id: \.self) { i in
                        let pt = points[i]
                        let x = padL + chartW * CGFloat(i) / CGFloat(values.count - 1)
                        let y = padT + chartH * (1 - values[i])
                        let hasTag = !pt.tag.isEmpty

                        // Dot
                        Circle().fill(hasTag ? pt.tagColor : VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.6))
                            .frame(width: hasTag ? 10 : 6, height: hasTag ? 10 : 6)
                            .position(x: x, y: y)

                        // Tag above dot
                        if hasTag {
                            Text(pt.tag).font(.system(size: 10, weight: .bold)).foregroundStyle(pt.tagColor)
                                .position(x: x, y: y - 16)
                        }

                        // Tap area
                        Color.clear.frame(width: 44, height: 44).contentShape(Rectangle())
                            .position(x: x, y: y)
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.18)) {
                                    selectedPoint = selectedPoint == i ? nil : i
                                }
                            }

                        // X-axis label
                        Text(pt.day).font(.system(size: 9, weight: .medium)).foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                            .position(x: x, y: h - 6)
                    }

                    // Bubble popup
                    if let sel = selectedPoint, sel < points.count {
                        let pt = points[sel]
                        let x = padL + chartW * CGFloat(sel) / CGFloat(values.count - 1)
                        let y = padT + chartH * (1 - values[sel])
                        let bubbleX = min(max(x, 90), w - 90)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(pt.day).font(.system(size: 15, weight: .bold)).foregroundStyle(VitoraTheme.ColorToken.strongText)
                                Text("\(pt.pct)%").font(.system(size: 15, weight: .bold)).foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                            }
                            Text("可能关联：\(pt.relation)")
                                .font(.system(size: 12, weight: .medium)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            Text("Vitora 看到：\(pt.observation)")
                                .font(.system(size: 12, weight: .medium)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            Text("问 Vitora >")
                                .font(.system(size: 13, weight: .bold)).foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
                        )
                        .position(x: bubbleX, y: max(8, y - 72))
                        .transition(.opacity)
                    }
                }
            }
            .frame(height: 190)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.82))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .accessibilityIdentifier("cycle.weekly.energy.curve")
    }
}

// MARK: - Period Tab Content

private struct CyclePeriodTabContent: View {
    private let cardBg = VitoraTheme.ColorToken.surfacePearlMain.opacity(0.82)
    private let cardRadius: CGFloat = 22

    var body: some View {
        VStack(spacing: 14) {
            // Combined phase + dominance card
            phaseOverviewCard

            // Nutrient supplement card
            nutrientCard

            // CTA
            Button {} label: {
                HStack {
                    Text("告诉 Vitora 这个阶段不准")
                        .font(.subheadline.weight(.bold))
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(maxWidth: .infinity).frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.38), lineWidth: 1.5)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white.opacity(0.52)))
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Phase Overview (merged phase + dominance)

    private var phaseOverviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("当前周期阶段与今天")
                .font(.caption.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            Text("Day 18 · 黄体期中段")
                .font(.title2.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            phaseAxis

            Divider().overlay(Color.white.opacity(0.5))

            // Dominance inline
            HStack(alignment: .top, spacing: 10) {
                PixelVitoraView(state: .idle, size: 30, showsGlow: false)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("黄体期占比")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        Text("57%")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color(red: 0.90, green: 0.68, blue: 0.22))
                    }
                    Text("能量波动更多出现在黄体期中后段，建议稳定补给。")
                        .font(.caption)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous).fill(cardBg)
                .overlay(RoundedRectangle(cornerRadius: cardRadius, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }

    private var phaseAxis: some View {
        VStack(spacing: 14) {
            Text("阶段节律")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Arc with phase icons
            GeometryReader { proxy in
                let w = proxy.size.width
                let arcH: CGFloat = 36
                Canvas { ctx, size in
                    var path = Path()
                    path.move(to: CGPoint(x: 12, y: arcH))
                    path.addQuadCurve(to: CGPoint(x: w - 12, y: arcH), control: CGPoint(x: w / 2, y: -8))

                    ctx.stroke(path, with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 0.92, green: 0.52, blue: 0.58),
                            Color(red: 0.55, green: 0.75, blue: 0.90),
                            Color(red: 0.60, green: 0.80, blue: 0.56),
                            Color(red: 0.95, green: 0.78, blue: 0.38),
                        ]),
                        startPoint: CGPoint(x: 0, y: arcH),
                        endPoint: CGPoint(x: w, y: arcH)
                    ), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                }
                .frame(height: arcH + 4)

                // Phase icons along the arc
                let phases: [(x: CGFloat, emoji: String)] = [
                    (0.05, "🩸"), (0.30, "🌱"), (0.55, "✨"), (0.85, "💛")
                ]
                ForEach(0..<phases.count, id: \.self) { i in
                    let p = phases[i]
                    let px = 12 + (w - 24) * p.x
                    let t = p.x
                    let py = arcH - sin(t * .pi) * (arcH + 8)
                    Text(p.emoji)
                        .font(.system(size: 18))
                        .position(x: px, y: max(0, py))
                }
            }
            .frame(height: 44)

            // Phase labels with day ranges
            HStack(spacing: 0) {
                phaseLabel(name: "月经期", days: "3-6天", color: Color(red: 0.92, green: 0.52, blue: 0.58), active: false)
                phaseLabel(name: "卵泡期", days: "7-14天", color: Color(red: 0.55, green: 0.75, blue: 0.90), active: false)
                phaseLabel(name: "排卵期", days: "1-2天", color: Color(red: 0.60, green: 0.80, blue: 0.56), active: false)
                phaseLabel(name: "黄体期 D18", days: "12-14天", color: Color(red: 0.95, green: 0.68, blue: 0.22), active: true)
            }

            // Bottom insight
            Text("本阶段更需要留余量，Vitora 会结合睡眠和 HRV 继续校准。")
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func phaseLabel(name: String, days: String, color: Color, active: Bool) -> some View {
        VStack(spacing: 3) {
            Text(name)
                .font(.caption2.weight(active ? .bold : .medium))
                .foregroundStyle(active ? color : VitoraTheme.ColorToken.secondaryText)
            Text(days)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Nutrient Supplement Card

    private struct NutrientItem {
        let symbol: String
        let name: String
        let effect: String
        let color: Color
    }

    private let nutrients: [NutrientItem] = [
        NutrientItem(symbol: "drop.fill", name: "铁", effect: "补充经期流失，改善疲惫感", color: Color(red: 0.85, green: 0.38, blue: 0.38)),
        NutrientItem(symbol: "leaf.fill", name: "镁", effect: "缓解痛经和肌肉紧张", color: Color(red: 0.38, green: 0.72, blue: 0.52)),
        NutrientItem(symbol: "circle.hexagongrid.fill", name: "钙", effect: "稳定情绪，减轻经前不适", color: Color(red: 0.52, green: 0.68, blue: 0.88)),
        NutrientItem(symbol: "bolt.fill", name: "维生素 B6", effect: "调节激素平衡，减少水肿", color: Color(red: 0.92, green: 0.72, blue: 0.32)),
    ]

    private var nutrientCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                Text("经期营养补充建议")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }

            Text("黄体期中后段，这些微量元素对身体恢复尤为重要：")
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            ForEach(nutrients, id: \.name) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(item.color)
                        .frame(width: 36, height: 36)
                        .background(item.color.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        Text(item.effect)
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            .lineLimit(2)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous).fill(cardBg)
                .overlay(RoundedRectangle(cornerRadius: cardRadius, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }
}


// MARK: - Phase Distribution Bar

private struct CyclePhaseDistributionBar: View {
    private let phases: [(label: String, pct: Double, color: Color)] = [
        ("月经", 0.00, Color(red: 0.88, green: 0.42, blue: 0.44)),
        ("卵泡", 0.29, Color(red: 0.55, green: 0.75, blue: 0.90)),
        ("排卵", 0.14, Color(red: 0.72, green: 0.62, blue: 0.88)),
        ("黄体", 0.57, Color(red: 0.95, green: 0.78, blue: 0.38)),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("阶段分布")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            // Bar
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    ForEach(phases, id: \.label) { phase in
                        if phase.pct > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(phase.color)
                                .frame(width: max(4, proxy.size.width * phase.pct))
                        }
                    }
                }
                .clipShape(Capsule())
            }
            .frame(height: 10)

            // Legend
            HStack(spacing: 14) {
                ForEach(phases, id: \.label) { phase in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(phase.color)
                            .frame(width: 8, height: 8)
                        Text("\(phase.label) \(Int(phase.pct * 100))%")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.82))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .accessibilityIdentifier("cycle.phase.distribution")
    }
}

// MARK: - Month Comparison View

private struct CycleMonthComparisonView: View {
    private let cardBg = VitoraTheme.ColorToken.surfacePearlMain.opacity(0.82)
    private let cardRadius: CGFloat = 22

    private struct CompareRow {
        let label: String
        let icon: String
        let lastMonth: String
        let thisMonth: String
        let trend: Trend

        enum Trend { case up, down, same }
    }

    private let rows: [CompareRow] = [
        CompareRow(label: "平均能量", icon: "bolt.fill", lastMonth: "58%", thisMonth: "62%", trend: .up),
        CompareRow(label: "低谷天数", icon: "arrow.down.right", lastMonth: "8 天", thisMonth: "5 天", trend: .up),
        CompareRow(label: "深睡平均", icon: "moon.fill", lastMonth: "1.2h", thisMonth: "1.5h", trend: .up),
        CompareRow(label: "HRV 均值", icon: "waveform.path.ecg", lastMonth: "42 ms", thisMonth: "48 ms", trend: .up),
        CompareRow(label: "痛经天数", icon: "cross.fill", lastMonth: "3 天", thisMonth: "2 天", trend: .up),
        CompareRow(label: "周期长度", icon: "calendar", lastMonth: "30 天", thisMonth: "28 天", trend: .same),
    ]

    var body: some View {
        VStack(spacing: 14) {
            summaryCard
            comparisonTable
            vitoraInsight
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 12) {
            PixelVitoraView(state: .idle, size: 30, showsGlow: false)
            VStack(alignment: .leading, spacing: 4) {
                Text("本月整体优于上月")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text("平均能量 ↑4%，低谷天数减少 3 天，深睡改善明显。")
                    .font(.caption)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous).fill(cardBg)
                .overlay(RoundedRectangle(cornerRadius: cardRadius, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }

    private var comparisonTable: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("上月")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                    .frame(width: 60)
                Text("本月")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .frame(width: 60)
                Text("")
                    .frame(width: 28)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            ForEach(rows, id: \.label) { row in
                VStack(spacing: 0) {
                    Divider().overlay(Color.white.opacity(0.5))
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: row.icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                                .frame(width: 24)
                            Text(row.label)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Text(row.lastMonth)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                            .frame(width: 60)

                        Text(row.thisMonth)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            .frame(width: 60)

                        Image(systemName: trendIcon(row.trend))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(trendColor(row.trend))
                            .frame(width: 28)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous).fill(cardBg)
                .overlay(RoundedRectangle(cornerRadius: cardRadius, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }

    private var vitoraInsight: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vitora 看到的变化")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            VStack(alignment: .leading, spacing: 6) {
                insightBullet("深睡时长增加约 15 分钟，恢复弹性改善")
                insightBullet("低谷天从上月 8 天降到 5 天，节奏更稳")
                insightBullet("痛经天数减少，可能与补铁和轻运动有关")
                insightBullet("周期长度回到 28 天，接近你的平均水平")
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous).fill(cardBg)
                .overlay(RoundedRectangle(cornerRadius: cardRadius, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }

    private func insightBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.6))
                .frame(width: 5, height: 5)
                .offset(y: 6)
            Text(text)
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func trendIcon(_ trend: CompareRow.Trend) -> String {
        switch trend {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .same: return "equal"
        }
    }

    private func trendColor(_ trend: CompareRow.Trend) -> Color {
        switch trend {
        case .up: return Color(red: 0.28, green: 0.76, blue: 0.52)
        case .down: return Color(red: 0.92, green: 0.48, blue: 0.42)
        case .same: return VitoraTheme.ColorToken.tertiaryText
        }
    }
}

// MARK: - Sidebar Profile

private struct SidebarProfileView: View {
    let onClose: () -> Void
    let onOpenSettings: () -> Void

    private struct MenuItem {
        let icon: String
        let title: String
        let color: Color
    }

    private let items: [MenuItem] = [
        MenuItem(icon: "heart.text.square", title: "数据来源", color: Color(red: 0.88, green: 0.44, blue: 0.62)),
        MenuItem(icon: "leaf.fill", title: "营养管理", color: Color(red: 0.42, green: 0.76, blue: 0.52)),
        MenuItem(icon: "bell.fill", title: "提醒设置", color: Color(red: 0.92, green: 0.72, blue: 0.32)),
        MenuItem(icon: "square.and.arrow.up", title: "数据导出", color: Color(red: 0.52, green: 0.68, blue: 0.88)),
        MenuItem(icon: "lock.shield", title: "隐私与账号", color: Color(red: 0.62, green: 0.58, blue: 0.82)),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    }
                    Spacer()
                    Text("我的")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Spacer()
                    Color.clear.frame(width: 18)
                }

                // Profile row
                HStack(spacing: 14) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.76, blue: 0.92),
                                    Color(red: 0.72, green: 0.82, blue: 0.95),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)
                        .overlay(
                            Text("🌸")
                                .font(.system(size: 26))
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text("小雨")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                        }
                        Text("本地模式")
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }

                    Spacer()
                }

                // VIP-style card
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vitora Pro")
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)
                        Text("解锁完整营养分析与长周期对比")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.78))
                    }

                    Spacer()

                    Text("了解更多")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(red: 0.22, green: 0.18, blue: 0.14))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(Color(red: 0.95, green: 0.88, blue: 0.72))
                        )
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.18, green: 0.16, blue: 0.22),
                                    Color(red: 0.28, green: 0.24, blue: 0.32),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .padding(20)
            .padding(.top, 8)

            Divider().padding(.horizontal, 20)

            // Menu items
            VStack(spacing: 0) {
                ForEach(items, id: \.title) { item in
                    Button(action: onOpenSettings) {
                        HStack(spacing: 14) {
                            Image(systemName: item.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(item.color)
                                .frame(width: 34, height: 34)
                                .background(item.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                            Text(item.title)
                                .font(.body.weight(.medium))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)

            Spacer()
        }
        .background(VitoraTheme.ColorToken.surfacePearlMain)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 24, topTrailingRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.14), radius: 20, x: 8, y: 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("sidebar.profile")
    }
}
