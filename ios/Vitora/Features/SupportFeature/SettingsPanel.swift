import SwiftUI

struct SettingsPanel: View {
    let onClose: () -> Void

    @State private var route: SupportRoute?
    @State private var nutritionEntries: [NutritionEntry]
    @State private var reminderPreference: ReminderPreference

    private let service = SupportService()
    private let dataAuthorization = DataSourceAuthorization(state: .skipped)

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        _nutritionEntries = State(initialValue: [
            NutritionEntry(name: "蛋白补给", contextSummary: "下午低谷前可作为轻补充"),
            NutritionEntry(name: "镁 + B 族", contextSummary: "夜间放松前的可选补给"),
        ])
        _reminderPreference = State(initialValue: ReminderPreference(isEnabled: true, intentionReminderHour: 13, reviewReminderHour: 21))
    }

    var body: some View {
        ZStack {
            AuraBackground(intensity: 0.82)

            if let route {
                childPanel(route)
            } else {
                homePanel
            }
        }
        .accessibilityIdentifier("support.settings.panel")
    }

    private var homePanel: some View {
        supportPanelContainer(title: "我的", onBack: nil, onClose: onClose) {
            VStack(alignment: .leading, spacing: 5) {
                Text("小雨")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Text("本地模式 / 账号状态")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
            .padding(.bottom, 2)

            VStack(spacing: 10) {
                ForEach(service.visibleItems(), id: \.self) { item in
                    Button {
                        route = item.route
                    } label: {
                        supportRow(item)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("support.route.\(item.route.rawValue)")
                }
            }
        }
    }

    @ViewBuilder
    private func childPanel(_ route: SupportRoute) -> some View {
        supportPanelContainer(title: route.title, onBack: { self.route = nil }, onClose: onClose) {
            switch route {
            case .profile:
                ProfilePanel()
            case .dataSources:
                DataSourcePanel(summary: service.dataSourceSummary(for: dataAuthorization))
            case .nutrition:
                NutritionManager(entries: $nutritionEntries)
            case .reminders:
                ReminderPreferencePanel(preference: reminderPreference) { preference in
                    reminderPreference = preference
                }
            case .dataExport:
                DataExportPanel()
            case .privacyAndAccountRemoval:
                LegalAccountPanel()
            }
        }
    }

    private func supportRow(_ item: SupportItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.systemImage)
                .font(.headline.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(width: 38, height: 38)
                .background(VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.64))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Text(item.subtitle)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        }
        .padding(14)
        .background(SupportGlassSurface())
    }
}

@MainActor
func supportPanelContainer<Content: View>(
    title: String,
    onBack: (() -> Void)?,
    onClose: @escaping () -> Void,
    @ViewBuilder content: () -> Content
) -> some View {
    ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                if let onBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.semibold))
                            .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .accessibilityHidden(true)
                    }
                    .buttonStyle(.plain)
                    .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                    .contentShape(Circle())
                    .accessibilityLabel("返回")
                    .accessibilityIdentifier("support.back")
                } else {
                    Color.clear.frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                }

                Spacer()

                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Spacer()

                Button(action: onClose) {
                    Text("关闭")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                }
                .buttonStyle(.plain)
                .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                .contentShape(Rectangle())
                .accessibilityLabel("关闭")
                .accessibilityIdentifier("support.close")
            }

            content()
        }
        .padding(20)
        .padding(.bottom, 36)
    }
}

@MainActor
func supportInfoBlock(title: String, body: String, systemImage: String? = nil) -> some View {
    HStack(alignment: .top, spacing: 11) {
        if let systemImage {
            Image(systemName: systemImage)
                .font(.headline.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(width: 34, height: 34)
                .background(VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.62))
                .clipShape(Circle())
        }

        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
            Text(body)
                .font(.subheadline)
                .lineSpacing(3)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        }
    }
    .padding(15)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(SupportGlassSurface())
}
