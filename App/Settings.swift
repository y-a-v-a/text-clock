import SwiftUI
import TextClockCore

/// `UserDefaults` keys shared by the window, the menu bar item and the settings pane.
/// The language lives in `SharedSettings` instead, so the widget can follow it.
enum SettingsKey {
    static let showInMenuBar = "showInMenuBar"
    static let keepWindowOnTop = "keepWindowOnTop"
}

struct SettingsView: View {
    @AppStorage(SettingsKey.showInMenuBar) private var showInMenuBar = true
    @AppStorage(SettingsKey.keepWindowOnTop) private var keepWindowOnTop = false
    @AppStorage(SharedSettings.languageKey, store: SharedSettings.defaults) private var language = LanguageSetting.system

    var body: some View {
        Form {
            Toggle("Show in menu bar", isOn: $showInMenuBar)
            Toggle("Keep window on top", isOn: $keepWindowOnTop)
            Picker("Language", selection: $language) {
                ForEach(LanguageSetting.allCases) { Text($0.title).tag($0) }
            }
            Section {
                Text("Desktop widgets follow this language unless you pick another one with right-click → “Edit ‘Text Clock’”. To add a widget, right-click the desktop, choose “Edit Widgets…” and search for “Text Clock”.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .formStyle(.grouped)
        .frame(width: 400)
        .fixedSize(horizontal: false, vertical: true)
    }
}
