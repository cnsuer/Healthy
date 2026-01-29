import SwiftUI

struct EyeCareMenuView: View {
    @ObservedObject var viewModel: EyeCareViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 状态信息
            VStack(alignment: .leading, spacing: 8) {
                Text("护眼提醒")
                    .font(.headline)
                    .padding(.bottom, 4)

                Text(viewModel.statusMessage)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)

                if viewModel.settings.isEnabled {
                    Text("当前设置: \(viewModel.settings.selectedInterval.displayNameWithUnit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // 开关
            Button(action: {
                viewModel.toggleEnabled()
            }) {
                HStack {
                    Image(systemName: viewModel.settings.isEnabled ? "power" : "power")
                        .foregroundColor(viewModel.settings.isEnabled ? .green : .red)
                    Text(viewModel.settings.isEnabled ? "停止提醒" : "开始提醒")
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { viewModel.settings.isEnabled },
                        set: { _ in viewModel.toggleEnabled() }
                    ))
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle())
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // 时间选择
            VStack(alignment: .leading, spacing: 4) {
                Text("选择间隔")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                ForEach(EyeCareSettings.availableIntervals) { interval in
                    Button(action: {
                        viewModel.selectInterval(interval)
                    }) {
                        HStack {
                            Text(interval.displayNameWithUnit)
                                .font(.system(.body, design: .rounded))
                            Spacer()
                            if interval.minutes == viewModel.settings.selectedInterval.minutes {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        interval.minutes == viewModel.settings.selectedInterval.minutes ?
                        Color.accentColor.opacity(0.1) : Color.clear
                    )
                }
            }

            Divider()

            // 测试按钮
            Button(action: {
                viewModel.testFullScreen()
            }) {
                HStack {
                    Image(systemName: "lifepreserver")
                    Text("测试全屏提醒")
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // 退出
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "xmark.circle")
                    Text("退出")
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(minWidth: 250)
    }
}

struct EyeCareMenuView_Previews: PreviewProvider {
    static var previews: some View {
        EyeCareMenuView(viewModel: EyeCareViewModel())
    }
}
