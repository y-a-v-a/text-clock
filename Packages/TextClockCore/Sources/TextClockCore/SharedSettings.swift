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

public enum TextAlignmentSetting: String, CaseIterable, Identifiable, Sendable {
    case left, center, right

    public var id: Self { self }

    public var title: String {
        switch self {
        case .left: return "Left"
        case .center: return "Center"
        case .right: return "Right"
        }
    }
}

public enum AppearanceSetting: String, CaseIterable, Identifiable, Sendable {
    case system, light, dark

    public var id: Self { self }

    public var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

/// Apple's system typefaces, which ship with every Mac and render in widgets too.
public enum FontSetting: String, CaseIterable, Identifiable, Sendable {
    case sans, serif, mono

    public var id: Self { self }

    public var title: String {
        switch self {
        case .sans: return "Sans Serif (SF Pro)"
        case .serif: return "Serif (New York)"
        case .mono: return "Monospaced (SF Mono)"
        }
    }
}

/// How the phrase is drawn, in the window and the widget alike.
public struct ClockStyle: Equatable, Sendable {
    public var alignment: TextAlignmentSetting
    public var appearance: AppearanceSetting
    public var font: FontSetting

    public init(alignment: TextAlignmentSetting = .left, appearance: AppearanceSetting = .system, font: FontSetting = .sans) {
        self.alignment = alignment
        self.appearance = appearance
        self.font = font
    }
}

/// Settings shared between the app and the widget through an App Group.
/// The group is prefixed with the team ID, which macOS accepts without a provisioning profile.
public enum SharedSettings {
    public static let appGroup = "HFFHH9CJYF.nl.vincentbruijn.TextClock"
    public static let languageKey = "language"
    public static let alignmentKey = "alignment"
    public static let appearanceKey = "appearance"
    public static let fontKey = "font"

    public static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroup) ?? .standard
    }

    public static var language: LanguageSetting {
        value(forKey: languageKey, in: defaults) ?? .system
    }

    public static var style: ClockStyle {
        style(in: defaults)
    }

    static func style(in defaults: UserDefaults) -> ClockStyle {
        let fallback = ClockStyle()
        return ClockStyle(
            alignment: value(forKey: alignmentKey, in: defaults) ?? fallback.alignment,
            appearance: value(forKey: appearanceKey, in: defaults) ?? fallback.appearance,
            font: value(forKey: fontKey, in: defaults) ?? fallback.font
        )
    }

    /// Reads a setting stored by `@AppStorage`, ignoring values from other versions it doesn't know.
    static func value<T: RawRepresentable>(forKey key: String, in defaults: UserDefaults) -> T? where T.RawValue == String {
        defaults.string(forKey: key).flatMap(T.init(rawValue:))
    }
}
