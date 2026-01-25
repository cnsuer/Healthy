# Healthy - macOS护眼提醒应用

## 功能特点

- ✅ 自定义护眼提醒时间间隔（20/30/45/60分钟）
- ✅ 状态栏显示，不占用Dock空间
- ✅ 实时倒计时显示
- ✅ 一键开关控制
- ✅ 全屏提醒界面
- ✅ 自动退出全屏提醒（60秒后自动关闭）
- ✅ 手动退出按钮
- ✅ 测试功能（立即查看全屏效果）
- ✅ 设置持久化保存

## MVVM架构

### Models
- `EyeCareSettings.swift`: 数据模型和设置管理

### ViewModel
- `EyeCareViewModel.swift`: 业务逻辑和状态管理

### Views
- `EyeCareMenuView.swift`: 状态栏弹出菜单
- `FullScreenReminderView.swift`: 全屏提醒界面

### App Delegate
- `AppDelegate.swift`: 应用生命周期管理和状态栏控制

## 项目配置

### 必须配置：应用不在Dock中显示

在Xcode中进行以下配置：

1. 选择项目 target "Healthy"
2. 选择 "Info" 标签
3. 点击 "Custom macOS Application Target Properties" 下的 "+"
4. 添加新条目：
   - Key: `Application is agent (LSUIElement)`
   - Value: `YES` (或者勾选复选框)

或者直接编辑 `project.pbxproj`，在对应的配置中添加：
```xml
LSUIElement = 1;
```

**注意**：此配置已在项目中完成！

## 使用说明

1. **启动应用**：在Xcode中按 `Cmd + R` 运行，应用会在状态栏显示眼睛图标
2. **点击图标**：显示控制菜单，可以：
   - 开启/关闭护眼提醒（使用开关控制）
   - 选择提醒间隔（20/30/45/60分钟）
   - 测试全屏提醒效果
   - 退出应用
3. **倒计时**：开启后，状态栏图标旁会显示倒计时（格式：MM:SS）
4. **全屏提醒**：倒计时结束后会自动显示全屏提醒，带有倒计时进度条
5. **退出提醒**：可以点击"我知道了"按钮或等待60秒自动退出

## 运行方式

### 在Xcode中运行（推荐）
1. 打开 `Healthy.xcodeproj`
2. 按 `Cmd + R` 运行
3. 应用启动后在状态栏找到眼睛图标

### 命令行运行
```bash
cd /Users/restver/Desktop/Ai/Healthy
xcodebuild -project Healthy.xcodeproj -scheme Healthy -configuration Debug build
open build/Build/Products/Debug/Healthy.app
```

## 技术栈

- SwiftUI
- Combine
- AppKit (NSStatusItem, NSPopover)
- MVVM架构模式

## 开发环境

- macOS 13.6+
- Xcode 15.1+
- Swift 5.0+

## 文件结构

```
Healthy/
├── Healthy/
│   ├── HealthyApp.swift           # 应用入口
│   ├── AppDelegate.swift          # 应用代理（状态栏管理）
│   ├── EyeCareSettings.swift      # 数据模型
│   ├── EyeCareViewModel.swift     # 视图模型（业务逻辑）
│   ├── EyeCareMenuView.swift      # 菜单视图
│   ├── FullScreenReminderView.swift # 全屏提醒视图
│   ├── ContentView.swift          # 默认视图（未使用）
│   ├── Assets.xcassets            # 资源文件
│   └── Healthy.entitlements       # 权限配置
├── Healthy.xcodeproj/             # Xcode项目文件
└── README.md                      # 本文件
```

