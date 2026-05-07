import SwiftUI

struct ProfilePanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            supportInfoBlock(
                title: "小雨",
                body: "当前以本地模式使用 Vitora。这个称呼只用于本机界面，不会作为直接身份线索发给 AI。",
                systemImage: "person.crop.circle"
            )

            supportInfoBlock(
                title: "账号状态",
                body: "P0 不要求第三方登录。导出和账号移除会在本机完成，并给出清晰结果反馈。",
                systemImage: "checkmark.shield"
            )

            supportInfoBlock(
                title: "Vitora 如何称呼你",
                body: "AI 上下文只会使用脱敏后的 preferred-label，不发送真实姓名或可识别身份字段。",
                systemImage: "sparkles"
            )
        }
    }
}
