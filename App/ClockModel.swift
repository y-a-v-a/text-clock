import AppKit
import Observation
import TextClockCore
import WidgetKit

/// Publishes the current time, updated only when the rounded phrase changes,
/// so the window and menu bar item redraw every five minutes instead of every second.
@MainActor
@Observable
final class ClockModel {
    private(set) var now = Date.now
    private(set) var style = SharedSettings.style

    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var widgetReload: Task<Void, Never>?
    @ObservationIgnored private var language = SharedSettings.language

    init() {
        schedule()
        applyAppearance()
        // Timers drift across sleep and manual clock changes, and the display, screen saver,
        // lock screen or another user's session can hide the clock for hours, so resync after each.
        let workspace = NSWorkspace.shared.notificationCenter
        let distributed = DistributedNotificationCenter.default()
        let names: [(NotificationCenter, Notification.Name)] = [
            (workspace, NSWorkspace.didWakeNotification),
            (workspace, NSWorkspace.screensDidWakeNotification),
            (workspace, NSWorkspace.sessionDidBecomeActiveNotification),
            // Undocumented, but posted by the screen saver and loginwindow for many macOS releases.
            (distributed, Notification.Name("com.apple.screensaver.didstop")),
            (distributed, Notification.Name("com.apple.screenIsUnlocked")),
            (NotificationCenter.default, .NSSystemClockDidChange),
            (NotificationCenter.default, .NSSystemTimeZoneDidChange),
        ]
        for (center, name) in names {
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.resync() }
            }
        }
        // Widgets only redraw when asked, so reload them when a setting they use changes.
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.settingsMayHaveChanged() }
        }
    }

    private func settingsMayHaveChanged() {
        let language = SharedSettings.language
        let style = SharedSettings.style
        guard language != self.language || style != self.style else { return }
        self.language = language
        self.style = style
        applyAppearance()
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Makes the window chrome, menus and Settings match the clock's light or dark override.
    private func applyAppearance() {
        switch style.appearance {
        case .system: NSApplication.shared.appearance = nil
        case .light: NSApplication.shared.appearance = NSAppearance(named: .aqua)
        case .dark: NSApplication.shared.appearance = NSAppearance(named: .darkAqua)
        }
    }

    /// Redraws the clock now, and the widgets too: their timeline may have run out during a long sleep,
    /// and entries drawn before a time zone change can show the old hour.
    private func resync() {
        refresh()
        // A wake posts several of these at once; reload the widgets once for the lot to spare their daily budget.
        widgetReload?.cancel()
        widgetReload = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func refresh() {
        now = .now
        schedule()
    }

    private func schedule() {
        timer?.invalidate()
        let next = TextClock.changeDates(after: .now, count: 1)[0]
        let timer = Timer(fire: next, interval: 0, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
}
