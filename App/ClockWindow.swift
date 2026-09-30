import AppKit
import SwiftUI
import TextClockCore
import TextClockUI

/// The phrase scaled to fill the window.
struct ClockWindowView: View {
    @Environment(ClockModel.self) private var clock
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(SettingsKey.keepWindowOnTop) private var keepWindowOnTop = false
    @AppStorage(SharedSettings.languageKey, store: SharedSettings.defaults) private var language = LanguageSetting.system

    var body: some View {
        ClockFace(
            phrase: TextClock.phrase(for: clock.now, language: language.resolved),
            style: clock.style,
            fontSize: 72,
            minimumScaleFactor: 0.1
        )
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(minWidth: 180, minHeight: 70)
            .background(clock.style.backgroundColor(for: colorScheme))
            .background(WindowLevel(keepOnTop: keepWindowOnTop))
            .contextMenu {
                Toggle("Keep on Top", isOn: $keepWindowOnTop)
                SettingsLink { Text("Settings…") }
            }
    }
}

/// SwiftUI has no window-level modifier before macOS 15, so reach the NSWindow directly.
private struct WindowLevel: NSViewRepresentable {
    var keepOnTop: Bool

    func makeNSView(context: Context) -> WindowLevelView { WindowLevelView() }

    func updateNSView(_ view: WindowLevelView, context: Context) {
        view.keepOnTop = keepOnTop
    }

    final class WindowLevelView: NSView {
        var keepOnTop = false {
            didSet { apply() }
        }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            apply()
        }

        private func apply() {
            guard let window else { return }
            window.level = keepOnTop ? .floating : .normal
            // Like Activity Monitor's CPU windows: stay visible on every Space while floating.
            window.collectionBehavior = keepOnTop ? [.canJoinAllSpaces, .fullScreenAuxiliary] : []
            window.isMovableByWindowBackground = true
        }
    }
}

struct ClockCommands: Commands {
    @AppStorage(SettingsKey.keepWindowOnTop) private var keepWindowOnTop = false

    var body: some Commands {
        CommandGroup(after: .windowArrangement) {
            Toggle("Keep Clock on Top", isOn: $keepWindowOnTop)
                .keyboardShortcut("t", modifiers: [.command, .option])
        }
    }
}
