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
}
