import SwiftUI
import TextClockCore

/// `UserDefaults` keys shared by the window, the menu bar item and the settings pane.
enum SettingsKey {
    static let showInMenuBar = "showInMenuBar"
    static let keepWindowOnTop = "keepWindowOnTop"
    static let language = "language"
}

enum LanguageSetting: String, CaseIterable, Identifiable {
    case system, dutch, english

    var id: Self { self }

    var title: String {
        switch self {
        case .system: return "System"
        case .dutch: return "Nederlands"
        case .english: return "English"
        }
    }

    var resolved: ClockLanguage {
        switch self {
        case .system: return .systemDefault
        case .dutch: return .dutch
        case .english: return .english
        }
    }
}

struct SettingsView: View {
    @AppStorage(SettingsKey.showInMenuBar) private var showInMenuBar = true
    @AppStorage(SettingsKey.keepWindowOnTop) private var keepWindowOnTop = false
    @AppStorage(SettingsKey.language) private var language = LanguageSetting.system

    var body: some View {
        Form {
            Toggle("Show in menu bar", isOn: $showInMenuBar)
            Toggle("Keep window on top", isOn: $keepWindowOnTop)
            Picker("Language", selection: $language) {
                ForEach(LanguageSetting.allCases) { Text($0.title).tag($0) }
            }
            Section {
                Text("The desktop widget has its own language setting. To add it, right-click the desktop, choose “Edit Widgets…” and search for “Text Clock”.")
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
