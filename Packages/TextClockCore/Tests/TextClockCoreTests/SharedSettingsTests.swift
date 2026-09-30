import XCTest
@testable import TextClockCore

final class SharedSettingsTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suite = "TextClockCoreTests.SharedSettings"

    override func setUp() {
        defaults = UserDefaults(suiteName: suite)
        defaults.removePersistentDomain(forName: suite)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suite)
    }

    func testStyleDefaultsWhenNothingIsStored() {
        XCTAssertEqual(SharedSettings.style(in: defaults), ClockStyle())
        XCTAssertEqual(ClockStyle().alignment, .left)
    }

    func testStyleReadsStoredValues() {
        defaults.set("center", forKey: SharedSettings.alignmentKey)
        XCTAssertEqual(SharedSettings.style(in: defaults).alignment, .center)
    }

    func testStyleIgnoresUnknownValues() {
        defaults.set("justified", forKey: SharedSettings.alignmentKey)
        XCTAssertEqual(SharedSettings.style(in: defaults), ClockStyle())
    }

    func testRawValuesAreStable() {
        // These are stored in shared defaults, so renaming a case would reset users' settings.
        XCTAssertEqual(TextAlignmentSetting.allCases.map(\.rawValue), ["left", "center", "right"])
    }
}
