import AppIntents
import SwiftUI
import TextClockCore
import TextClockUI
import WidgetKit

enum LanguageOption: String, AppEnum {
    case app, system, dutch, english

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Language"
    static let caseDisplayRepresentations: [LanguageOption: DisplayRepresentation] = [
        .app: "Same as App",
        .system: "System",
        .dutch: "Nederlands",
        .english: "English",
    ]

    var resolved: ClockLanguage {
        switch self {
        case .app: return SharedSettings.language.resolved
        case .system: return .systemDefault
        case .dutch: return .dutch
        case .english: return .english
        }
    }
}

struct ConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Text Clock"
    static let description = IntentDescription("Shows the time in words.")

    @Parameter(title: "Language", default: .app)
    var language: LanguageOption
}

struct ClockEntry: TimelineEntry {
    let date: Date
    let language: ClockLanguage
    let style: ClockStyle
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ClockEntry {
        ClockEntry(date: .now, language: SharedSettings.language.resolved, style: SharedSettings.style)
    }

    func snapshot(for configuration: ConfigurationIntent, in context: Context) async -> ClockEntry {
        ClockEntry(date: .now, language: configuration.language.resolved, style: SharedSettings.style)
    }

    func timeline(for configuration: ConfigurationIntent, in context: Context) async -> Timeline<ClockEntry> {
        let language = configuration.language.resolved
        let style = SharedSettings.style
        let now = Date.now
        // One entry per phrase change for the next 12 hours; WidgetKit asks again afterwards.
        let dates = [now] + TextClock.changeDates(after: now, count: 12 * 12)
        return Timeline(entries: dates.map { ClockEntry(date: $0, language: language, style: style) }, policy: .atEnd)
    }
}

struct TextClockWidgetView: View {
    let entry: ClockEntry
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme

    private var fontSize: CGFloat {
        switch family {
        case .systemSmall: return 22
        case .systemMedium: return 30
        default: return 44
        }
    }

    var body: some View {
        ClockFace(
            phrase: TextClock.phrase(for: entry.date, language: entry.language),
            style: entry.style,
            fontSize: fontSize,
            minimumScaleFactor: 0.5
        )
            .containerBackground(entry.style.backgroundColor(for: colorScheme), for: .widget)
    }
}

@main
struct TextClockWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "TextClockWidget", intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TextClockWidgetView(entry: entry)
        }
        .configurationDisplayName("Text Clock")
        .description("The time in words, in Dutch or English.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
