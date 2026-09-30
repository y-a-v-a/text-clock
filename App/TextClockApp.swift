import SwiftUI

/// Hosts the widget (macOS only offers widgets whose app has been launched once),
/// plus a clock window that can float above other windows and an optional menu bar item.
@main
struct TextClockApp: App {
    static let windowID = "clock"

    @State private var clock = ClockModel()
    @AppStorage(SettingsKey.showInMenuBar) private var showInMenuBar = true

    var body: some Scene {
        Window("Text Clock", id: Self.windowID) {
            ClockWindowView()
                .environment(clock)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 340, height: 120)
        .commands { ClockCommands() }

        MenuBarExtra(isInserted: $showInMenuBar) {
            MenuBarMenu()
        } label: {
            MenuBarLabel()
                .environment(clock)
        }

        Settings {
            SettingsView()
        }
    }
}
