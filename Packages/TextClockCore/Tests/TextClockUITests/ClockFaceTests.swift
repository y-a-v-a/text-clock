import SwiftUI
import TextClockCore
import TextClockUI
import XCTest

final class ClockFaceTests: XCTestCase {
    func testAlignment() {
        XCTAssertEqual(TextAlignmentSetting.left.textAlignment, .leading)
        XCTAssertEqual(TextAlignmentSetting.center.textAlignment, .center)
        XCTAssertEqual(TextAlignmentSetting.right.textAlignment, .trailing)

        XCTAssertEqual(TextAlignmentSetting.left.frameAlignment, .leading)
        XCTAssertEqual(TextAlignmentSetting.center.frameAlignment, .center)
        XCTAssertEqual(TextAlignmentSetting.right.frameAlignment, .trailing)
    }

    func testSystemAppearanceFollowsTheSystem() {
        let style = ClockStyle(appearance: .system)
        XCTAssertEqual(style.colorScheme(system: .light), .light)
        XCTAssertEqual(style.colorScheme(system: .dark), .dark)
    }

    func testAppearanceOverridesTheSystem() {
        for system in [ColorScheme.light, .dark] {
            XCTAssertEqual(ClockStyle(appearance: .light).colorScheme(system: system), .light)
            XCTAssertEqual(ClockStyle(appearance: .dark).colorScheme(system: system), .dark)
        }
    }

    func testColors() {
        let dark = ClockStyle(appearance: .dark)
        XCTAssertEqual(dark.foregroundColor(for: .light), .white)
        XCTAssertEqual(dark.backgroundColor(for: .light), .black)

        let light = ClockStyle(appearance: .light)
        XCTAssertEqual(light.foregroundColor(for: .dark), .black)
        XCTAssertEqual(light.backgroundColor(for: .dark), .white)
    }

    func testFontDesign() {
        // Sans stays the default system font the clock always used.
        XCTAssertEqual(FontSetting.sans.design, .default)
        XCTAssertEqual(FontSetting.serif.design, .serif)
        XCTAssertEqual(FontSetting.mono.design, .monospaced)
    }
}
