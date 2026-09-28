import XCTest
@testable import TextClockCore

final class TextClockTests: XCTestCase {
    private var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }()

    private func date(_ h: Int, _ m: Int, _ s: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: 28, hour: h, minute: m, second: s))!
    }

    func testDutch() {
        XCTAssertEqual(TextClock.phrase(hour: 11, minute: 25, language: .dutch), "het is vijf voor half twaalf")
        XCTAssertEqual(TextClock.phrase(hour: 13, minute: 0, language: .dutch), "het is één uur")
        XCTAssertEqual(TextClock.phrase(hour: 9, minute: 45, language: .dutch), "het is kwart voor tien")
        XCTAssertEqual(TextClock.phrase(hour: 23, minute: 30, language: .dutch), "het is half twaalf")
        XCTAssertEqual(TextClock.phrase(hour: 0, minute: 0, language: .dutch), "het is twaalf uur")
    }

    func testEnglish() {
        XCTAssertEqual(TextClock.phrase(hour: 9, minute: 45, language: .english), "it’s quarter to ten")
        XCTAssertEqual(TextClock.phrase(hour: 22, minute: 30, language: .english), "it’s half past ten")
        XCTAssertEqual(TextClock.phrase(hour: 11, minute: 55, language: .english), "it’s five to twelve")
        XCTAssertEqual(TextClock.phrase(hour: 12, minute: 0, language: .english), "it’s twelve o’clock")
    }

    func testRounding() {
        XCTAssertTrue(TextClock.rounded(date(10, 2, 29), calendar: calendar) == (10, 0))
        XCTAssertTrue(TextClock.rounded(date(10, 2, 30), calendar: calendar) == (10, 5))
        XCTAssertTrue(TextClock.rounded(date(10, 57, 31), calendar: calendar) == (11, 0))
        XCTAssertTrue(TextClock.rounded(date(23, 58, 0), calendar: calendar) == (0, 0))
    }

    func testChangeDates() {
        let dates = TextClock.changeDates(after: date(10, 1, 0), count: 3, calendar: calendar)
        XCTAssertEqual(dates, [date(10, 2, 30), date(10, 7, 30), date(10, 12, 30)])
        // Exactly on a boundary moves to the next one.
        XCTAssertEqual(TextClock.changeDates(after: date(10, 2, 30), count: 1, calendar: calendar), [date(10, 7, 30)])
    }
}
