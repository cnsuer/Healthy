# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Healthy is a macOS menubar eye care reminder application. It runs as a background status bar app (no Dock icon) that displays full-screen reminders at configurable intervals to help users take breaks from screen time.

## Build and Run Commands

### Building and Running
**Recommended approach:** Open `Healthy.xcodeproj` in Xcode and press `Cmd + R`

**Command line:**
```bash
# Build the project
xcodebuild -project Healthy.xcodeproj -scheme Healthy -configuration Debug build

# Run the built app
open build/Build/Products/Debug/Healthy.app
```

**Important:** This app is configured as a status bar app with `LSUIElement = 1` (already set in project.pbxproj). This prevents the app from appearing in the Dock - it only shows in the menu bar.

## Architecture

### MVVM Pattern
The codebase follows a clean MVVM architecture with Combine for reactive state management:

- **Model** (`EyeCareSettings.swift`): Data models for intervals and settings persistence via UserDefaults
- **ViewModel** (`EyeCareViewModel.swift`): Business logic, timer management, and state using Combine publishers
- **Views**: SwiftUI views (`EyeCareMenuView.swift`, `FullScreenReminderView.swift`)
- **AppDelegate** (`AppDelegate.swift`): App lifecycle and status bar integration using AppKit APIs

### Key Components

**Status Bar Integration** (`AppDelegate.swift`):
- Uses `NSStatusItem` for menubar presence
- `NSPopover` for dropdown menu display
- Custom `NSPanel` with `screenSaver` level for full-screen reminders

**Timer Management** (`EyeCareViewModel.swift`):
- Separate timers for countdown display and auto-dismiss functionality
- Real-time countdown shown in status bar as "MM:SS" format
- Auto-dismisses full-screen reminder after 60 seconds with progress bar

**User Interface**:
- `EyeCareMenuView`: Controls for enable/disable, interval selection (20/30/45/60 min), test button, quit
- `FullScreenReminderView`: Full-screen overlay with gradient background and "我知道了" (Got it) button

### State Management

Settings are persisted via `UserDefaults.standard` and include:
- Enable/disable state
- Selected reminder interval
- All configuration survives app restarts

State updates are reactive using Combine's `@Published` properties.

## Technology Stack

- Swift 5.0+
- SwiftUI (views)
- AppKit (NSStatusItem, NSPopover, NSPanel)
- Combine (reactive state management)
- macOS 13.6+
- Xcode 15.1+

## File Structure Notes

- `HealthyApp.swift`: Minimal app entry point with no main window
- `ContentView.swift`: Default SwiftUI view (unused in this status bar app)
- `FullScreenWindow.swift`: Custom NSPanel subclass for full-screen reminder window
- `Healthy.entitlements`: App Sandbox enabled with minimal permissions
