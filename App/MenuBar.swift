import AppKit
import SwiftUI
import TextClockCore

struct MenuBarLabel: View {
    @Environment(ClockModel.self) private var clock
    @AppStorage(SharedSettings.languageKey, store: SharedSettings.defaults) private var language = LanguageSetting.system

    var body: some View {
        Text(TextClock.phrase(for: clock.now, language: language.resolved))
    }
}

struct MenuBarMenu: View {
    @Environment(\.openWindow) private var openWindow
    @AppStorage(SettingsKey.showInMenuBar) private var showInMenuBar = true
    @AppStorage(SettingsKey.keepWindowOnTop) private var keepWindowOnTop = false
    @AppStorage(SharedSettings.languageKey, store: SharedSettings.defaults) private var language = LanguageSetting.system

    var body: some View {
        Button("Show Clock Window") {
            openWindow(id: TextClockApp.windowID)
            NSApp.activate()
        }
        Toggle("Keep Window on Top", isOn: $keepWindowOnTop)
        Picker("Language", selection: $language) {
            ForEach(LanguageSetting.allCases) { Text($0.title).tag($0) }
        }
        Divider()
        Toggle("Show in Menu Bar", isOn: $showInMenuBar)
        SettingsLink { Text("Settings…") }
            .keyboardShortcut(",")
        Divider()
        Button("Quit Text Clock") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}
