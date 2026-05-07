import SwiftUI

struct NutritionManager: View {
    @Binding var entries: [NutritionEntry]

    private let service = NutritionService()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            supportInfoBlock(
                title: "营养补给管理",
                body: "这里只管理 Vitora 可参考的补给上下文，不做销售、不做治疗建议。快捷新增也可以从 Vitora 输入流发生。",
                systemImage: "leaf"
            )

            ComplianceLabel(.nutrition)
                .padding(.horizontal, 4)

            ForEach(entries) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    Text(entry.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Text(entry.contextSummary)
                        .font(.subheadline)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SupportGlassSurface())
                .accessibilityIdentifier("support.nutrition.entry")
            }

            Button {
                let entry = service.quickEntry(name: "下午轻补给", contextSummary: "低谷窗口前可尝试的小份蛋白或坚果")
                entries = service.upsert(entry: entry, into: entries)
            } label: {
                Label("新增一个补给上下文", systemImage: "plus")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .foregroundStyle(.white)
                    .background(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("support.nutrition.add")
        }
    }
}
