import SwiftUI
import TextClockCore

/// Host app for the widget. macOS only offers widgets whose containing app has
/// been launched at least once, so this just shows a preview and instructions.
@main
struct TextClockApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(ClockLanguage.allCases, id: \.self) { language in
                        Text(TextClock.phrase(for: context.date, language: language))
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.black, in: RoundedRectangle(cornerRadius: 20))
            }
            Text("To add the widget, right-click the desktop, choose “Edit Widgets…” and search for “Text Clock”.")
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(width: 460)
    }
}
