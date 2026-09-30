import AppKit
import Observation
import TextClockCore

/// Publishes the current time, updated only when the rounded phrase changes,
/// so the window and menu bar item redraw every five minutes instead of every second.
@MainActor
@Observable
final class ClockModel {
    private(set) var now = Date.now

    @ObservationIgnored private var timer: Timer?

    init() {
        schedule()
        // Timers drift across sleep and manual clock changes, so resync on both.
        let names: [(NotificationCenter, Notification.Name)] = [
            (NSWorkspace.shared.notificationCenter, NSWorkspace.didWakeNotification),
            (NotificationCenter.default, .NSSystemClockDidChange),
            (NotificationCenter.default, .NSSystemTimeZoneDidChange),
        ]
        for (center, name) in names {
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.refresh() }
            }
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
