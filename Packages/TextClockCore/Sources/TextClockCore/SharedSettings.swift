import Foundation

/// The app's language choice, stored where the widget can read it too.
public enum LanguageSetting: String, CaseIterable, Identifiable, Sendable {
    case system, dutch, english

    public var id: Self { self }

    public var title: String {
        switch self {
        case .system: return "System"
        case .dutch: return "Nederlands"
        case .english: return "English"
        }
    }

    public var resolved: ClockLanguage {
        switch self {
        case .system: return .systemDefault
        case .dutch: return .dutch
        case .english: return .english
        }
    }
}

/// Settings shared between the app and the widget through an App Group.
/// The group is prefixed with the team ID, which macOS accepts without a provisioning profile.
public enum SharedSettings {
    public static let appGroup = "HFFHH9CJYF.nl.vincentbruijn.TextClock"
    public static let languageKey = "language"

    public static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroup) ?? .standard
    }

    public static var language: LanguageSetting {
        defaults.string(forKey: languageKey).flatMap(LanguageSetting.init(rawValue:)) ?? .system
    }
}
