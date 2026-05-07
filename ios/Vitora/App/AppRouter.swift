import SwiftUI

struct AppRouter: View {
    @ObservedObject var environment: AppEnvironment

    var body: some View {
        switch environment.route {
        case .onboarding:
            AppGateView(environment: environment)
        case .today:
            MainTabShell(environment: environment)
        }
    }
}

private struct MainTabShell: View {
    @ObservedObject var environment: AppEnvironment

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch environment.navigationState.selectedTab {
                case .today:
                    TodayView(environment: environment)
                case .vitora:
                    VitoraAssistantSurfaceView(environment: environment)
                case .cycle:
                    CycleView(environment: environment)
                }
            }

            if environment.navigationState.presentation != .vitoraFullContextMode {
                PrimaryTabBar(
                    selectedTab: environment.navigationState.selectedTab,
                    onSelect: environment.selectTab
                )
            }
        }
        .sheet(
            isPresented: Binding(
                get: { environment.navigationState.presentation == .vitoraContextualSheet },
                set: { isPresented in
                    if !isPresented {
                        environment.dismissPresentation()
                    }
                }
            )
        ) {
            VitoraContextualSheet(
                context: environment.vitoraContext,
                onClose: environment.dismissPresentation
            )
            .presentationDetents([.fraction(0.72), .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(
            isPresented: Binding(
                get: { environment.navigationState.presentation == .eveningReview },
                set: { isPresented in
                    if !isPresented {
                        environment.dismissPresentation()
                    }
                }
            )
        ) {
            EveningReviewSheet(
                review: environment.eveningReview,
                learningSignal: environment.reviewLearningSignal,
                onSubmit: environment.submitEveningReview,
                onTellVitora: {
                    environment.openVitoraContext(
                        sourceTitle: "晚间复盘",
                        sourceSummary: environment.eveningReview.afterSummary.isEmpty ? environment.eveningReview.beforeSummary : environment.eveningReview.afterSummary,
                        prompt: "你可以补充今天这个建议后来有没有改变你的状态。"
                    )
                },
                onClose: environment.dismissPresentation
            )
            .presentationDetents([.fraction(0.78), .large])
            .presentationDragIndicator(.visible)
        }
    }
}

private struct PrimaryTabBar: View {
    let selectedTab: PrimaryTab
    let onSelect: (PrimaryTab) -> Void

    var body: some View {
        HStack(alignment: .top) {
            tabButton(tab: .today, title: String(localized: "tab.today"), systemImage: "circle.circle")
                .padding(.top, 10)

            Spacer()

            Button {
                onSelect(.vitora)
            } label: {
                VStack(spacing: 2) {
                    VitoraFaceTabButton(isSelected: selectedTab == .vitora)

                    Text(String(localized: "tab.vitora"))
                        .font(.caption2)
                        .foregroundStyle(selectedTab == .vitora ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.secondaryText)
                }
                .offset(y: -10)
                .frame(width: 74, height: 70, alignment: .top)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("tab.vitora")

            Spacer()

            tabButton(tab: .cycle, title: String(localized: "tab.cycle"), systemImage: "circle.lefthalf.filled")
                .padding(.top, 10)
        }
        .padding(.horizontal, 58)
        .padding(.top, 8)
        .padding(.bottom, 0)
        .frame(height: 82, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .fill(.ultraThinMaterial)
                .background(
                    UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                        .fill(VitoraTheme.ColorToken.paper.opacity(0.58))
                )
                .overlay(
                    UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                        .stroke(Color(red: 232 / 255, green: 232 / 255, blue: 236 / 255).opacity(0.85), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.07), radius: 16, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("primary.tabbar")
    }

    private func tabButton(tab: PrimaryTab, title: String, systemImage: String) -> some View {
        Button {
            onSelect(tab)
        } label: {
            VStack(spacing: 7) {
                Image(systemName: systemImage)
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(selectedTab == tab ? VitoraTheme.ColorToken.primaryText : VitoraTheme.ColorToken.secondaryText)

                Text(title)
                    .font(.caption2.weight(selectedTab == tab ? .medium : .regular))
                    .foregroundStyle(selectedTab == tab ? VitoraTheme.ColorToken.primaryText : VitoraTheme.ColorToken.secondaryText)
            }
            .frame(width: 54)
            .frame(minHeight: VitoraTheme.Size.touchTargetMin)
        }
        .buttonStyle(.plain)
        .frame(width: 54, height: 54)
        .contentShape(Rectangle())
        .accessibilityLabel(title)
        .accessibilityIdentifier("tab.\(tab.rawValue)")
    }
}

private struct PlaceholderScreen: View {
    let titleKey: LocalizedStringKey
    let subtitleKey: LocalizedStringKey
    var badgeKey: LocalizedStringKey?

    var body: some View {
        ZStack {
            VitoraTheme.ColorToken.canvas
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text(titleKey)
                    .font(.title.weight(.semibold))

                if let badgeKey {
                    Text(badgeKey)
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, VitoraTheme.Spacing.sm)
                        .padding(.vertical, VitoraTheme.Spacing.xs)
                        .background(VitoraTheme.ColorToken.softSurface)
                        .clipShape(Capsule())
                        .accessibilityIdentifier("today.lowdata.badge")
                }

                Text(subtitleKey)
                    .font(.body)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .padding(.bottom, VitoraTheme.Size.tabBarHeight)
        }
    }
}
