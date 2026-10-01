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
        XCTAssertEqual(ClockStyle().appearance, .system)
        XCTAssertEqual(ClockStyle().font, .sans)
    }

    func testStyleReadsStoredValues() {
        defaults.set("center", forKey: SharedSettings.alignmentKey)
        defaults.set("dark", forKey: SharedSettings.appearanceKey)
        defaults.set("serif", forKey: SharedSettings.fontKey)
        XCTAssertEqual(SharedSettings.style(in: defaults), ClockStyle(alignment: .center, appearance: .dark, font: .serif))
    }

    func testStyleIgnoresUnknownValues() {
        defaults.set("justified", forKey: SharedSettings.alignmentKey)
        defaults.set("sepia", forKey: SharedSettings.appearanceKey)
        defaults.set("comic", forKey: SharedSettings.fontKey)
        XCTAssertEqual(SharedSettings.style(in: defaults), ClockStyle())
    }

    func testRawValuesAreStable() {
        // These are stored in shared defaults, so renaming a case would reset users' settings.
        XCTAssertEqual(TextAlignmentSetting.allCases.map(\.rawValue), ["left", "center", "right"])
        XCTAssertEqual(AppearanceSetting.allCases.map(\.rawValue), ["system", "light", "dark"])
        XCTAssertEqual(FontSetting.allCases.map(\.rawValue), ["sans", "serif", "mono"])
    }
}
