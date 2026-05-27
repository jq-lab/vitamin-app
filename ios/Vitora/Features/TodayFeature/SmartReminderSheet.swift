import SwiftUI

struct SmartReminderSheet: View {
    let onSave: () -> Void
    let onClose: () -> Void

    @State private var reminder1Time = Calendar.current.date(from: DateComponents(hour: 13, minute: 20)) ?? Date()
    @State private var reminder2Time = Calendar.current.date(from: DateComponents(hour: 14, minute: 40)) ?? Date()
    @State private var reminder1Enabled = true
    @State private var reminder2Enabled = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            reminderRows
            saveButton
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 20, x: 0, y: -4)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("设置提醒")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text("Vitora 会在这些时间推送通知")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .frame(width: 32, height: 32)
                    .background(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.72), in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var reminderRows: some View {
        VStack(spacing: 12) {
            reminderRow(
                label: "补能提醒",
                subtitle: "午间低谷前准备",
                time: $reminder1Time,
                enabled: $reminder1Enabled
            )

            reminderRow(
                label: "恢复提醒",
                subtitle: "下午恢复窗口",
                time: $reminder2Time,
                enabled: $reminder2Enabled
            )
        }
    }

    private func reminderRow(label: String, subtitle: String, time: Binding<Date>, enabled: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            Spacer()

            DatePicker("", selection: time, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .scaleEffect(0.85)
                .environment(\.locale, Locale(identifier: "zh_CN"))

            Toggle("", isOn: enabled)
                .labelsHidden()
                .tint(VitoraTheme.ColorToken.actionPrimaryDeep)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 245 / 255, green: 245 / 255, blue: 248 / 255))
        )
    }

    private var saveButton: some View {
        Button(action: onSave) {
            Text("保存智能提醒")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(VitoraTheme.ColorToken.actionPrimaryDeep, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("reminder.save")
    }
}
