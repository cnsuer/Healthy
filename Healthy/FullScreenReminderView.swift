import SwiftUI

struct FullScreenReminderView: View {
    @ObservedObject var viewModel: EyeCareViewModel

    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.cyan.opacity(0.8),
                    Color.green.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)

            VStack(spacing: 40) {
                Spacer()

                // 图标
                Image(systemName: "eye.circle.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.white)
                    .shadow(radius: 20)

                // 主要文字
                VStack(spacing: 20) {
                    Text("休息时间到了!")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)

                    Text("远离屏幕，保护眼睛")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.9))

                    Text("建议远眺或闭目养神")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                // 自动退出进度条
                VStack(spacing: 12) {
                    Text("自动退出: \(Int(viewModel.fullScreenRemainingTime))秒")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .frame(
                                    width: geometry.size.width * max(0, viewModel.fullScreenRemainingTime / 60),
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
                }
                .frame(maxWidth: 400)
                .padding(.bottom, 20)

                // 退出按钮
                Button(action: {
                    // 延迟执行，确保按钮点击事件完成
                    DispatchQueue.main.async {
                        viewModel.dismissFullScreen()
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("我知道了")
                    }
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 60)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(50)
                    .shadow(radius: 10)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 60)
            }
            .frame(minWidth: 800, minHeight: 600)
        }
    }
}

struct FullScreenReminderView_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenReminderView(viewModel: EyeCareViewModel())
    }
}
