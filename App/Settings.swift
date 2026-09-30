import SwiftUI
import TextClockCore

/// `UserDefaults` keys shared by the window, the menu bar item and the settings pane.
/// The language and look live in `SharedSettings` instead, so the widget can follow them.
enum SettingsKey {
    static let showInMenuBar = "showInMenuBar"
    static let keepWindowOnTop = "keepWindowOnTop"
}

struct SettingsView: View {
    @AppStorage(SettingsKey.showInMenuBar) private var showInMenuBar = true
    @AppStorage(SettingsKey.keepWindowOnTop) private var keepWindowOnTop = false
    @AppStorage(SharedSettings.languageKey, store: SharedSettings.defaults) private var language = LanguageSetting.system
    @AppStorage(SharedSettings.alignmentKey, store: SharedSettings.defaults) private var alignment = ClockStyle().alignment
    @AppStorage(SharedSettings.appearanceKey, store: SharedSettings.defaults) private var appearance = ClockStyle().appearance
    @AppStorage(SharedSettings.fontKey, store: SharedSettings.defaults) private var font = ClockStyle().font

    var body: some View {
        Form {
            Section("App") {
                Toggle("Show in menu bar", isOn: $showInMenuBar)
                Toggle("Keep window on top", isOn: $keepWindowOnTop)
            }
            Section {
                Picker("Language", selection: $language) {
                    ForEach(LanguageSetting.allCases) { Text($0.title).tag($0) }
                }
                Picker("Alignment", selection: $alignment) {
                    ForEach(TextAlignmentSetting.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                Picker("Appearance", selection: $appearance) {
                    ForEach(AppearanceSetting.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                Picker("Font", selection: $font) {
                    ForEach(FontSetting.allCases) { Text($0.title).tag($0) }
                }
            } header: {
                Text("Clock")
            } footer: {
                Text("The clock window and desktop widgets use these settings. A widget can pick its own language with right-click → “Edit ‘Text Clock’”. To add a widget, right-click the desktop, choose “Edit Widgets…” and search for “Text Clock”.")
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
