import SwiftUI
import TextClockCore

/// The phrase laid out and styled according to `ClockStyle`. Callers draw the background.
public struct ClockFace: View {
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
            .foregroundStyle(.white)
            .multilineTextAlignment(style.alignment.textAlignment)
            .minimumScaleFactor(minimumScaleFactor)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: style.alignment.frameAlignment)
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
