import SwiftUI
import TextClockCore

/// The phrase laid out and styled according to `ClockStyle`. Callers draw the background
/// with `ClockStyle.backgroundColor(for:)`.
public struct ClockFace: View {
    @Environment(\.colorScheme) private var colorScheme

    private let phrase: String
    private let style: ClockStyle
    private let fontSize: CGFloat
    private let minimumScaleFactor: CGFloat

    public init(phrase: String, style: ClockStyle, fontSize: CGFloat, minimumScaleFactor: CGFloat) {
        self.phrase = phrase
        self.style = style
        self.fontSize = fontSize
        self.minimumScaleFactor = minimumScaleFactor
    }

    public var body: some View {
        Text(phrase)
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundStyle(style.foregroundColor(for: colorScheme))
            .multilineTextAlignment(style.alignment.textAlignment)
            .minimumScaleFactor(minimumScaleFactor)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: style.alignment.frameAlignment)
    }
}

extension ClockStyle {
    /// The scheme to draw in, given the system's.
    public func colorScheme(system: ColorScheme) -> ColorScheme {
        switch appearance {
        case .system: return system
        case .light: return .light
        case .dark: return .dark
        }
    }

    public func foregroundColor(for system: ColorScheme) -> Color {
        colorScheme(system: system) == .dark ? .white : .black
    }

    public func backgroundColor(for system: ColorScheme) -> Color {
        colorScheme(system: system) == .dark ? .black : .white
    }
}

extension TextAlignmentSetting {
    /// How wrapped lines line up with each other.
    public var textAlignment: TextAlignment {
        switch self {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        }
    }

    /// Where the text block sits in the available space.
    public var frameAlignment: Alignment {
        switch self {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        }
    }
}
