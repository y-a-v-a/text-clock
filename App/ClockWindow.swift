import AppKit
import SwiftUI
import TextClockCore

/// The phrase in white on black, scaled to fill the window.
struct ClockWindowView: View {
    @Environment(ClockModel.self) private var clock
    @AppStorage(SettingsKey.keepWindowOnTop) private var keepWindowOnTop = false
    @AppStorage(SharedSettings.languageKey, store: SharedSettings.defaults) private var language = LanguageSetting.system

    var body: some View {
        Text(TextClock.phrase(for: clock.now, language: language.resolved))
            .font(.system(size: 72, weight: .semibold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.leading)
            .minimumScaleFactor(0.1)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(minWidth: 180, maxWidth: .infinity, minHeight: 70, maxHeight: .infinity, alignment: .leading)
            .background(.black)
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
