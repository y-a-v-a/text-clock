import Foundation

public enum ClockLanguage: String, CaseIterable, Sendable {
    case dutch = "nl"
    case english = "en"

    /// Picks Dutch when the user's preferred language is Dutch, English otherwise.
    public static var systemDefault: ClockLanguage {
        let code = Locale.preferredLanguages.first.flatMap { Locale(identifier: $0).language.languageCode?.identifier }
        return code == "nl" ? .dutch : .english
    }
}

public enum TextClock {
    /// Rounds a time to the nearest 5 minutes and returns (hour 0...23, minute 0...55).
    public static func rounded(_ date: Date, calendar: Calendar = .current) -> (hour: Int, minute: Int) {
        let c = calendar.dateComponents([.hour, .minute, .second], from: date)
        let seconds = (c.hour ?? 0) * 3600 + (c.minute ?? 0) * 60 + (c.second ?? 0)
        let minutes = ((seconds + 150) / 300 * 5) % (24 * 60)
        return (minutes / 60, minutes % 60)
    }

    public static func phrase(for date: Date, language: ClockLanguage, calendar: Calendar = .current) -> String {
        let (hour, minute) = rounded(date, calendar: calendar)
        return phrase(hour: hour, minute: minute, language: language)
    }

    /// `minute` must be a multiple of 5.
    public static func phrase(hour: Int, minute: Int, language: ClockLanguage) -> String {
        switch language {
        case .dutch: return dutch(hour: hour, minute: minute)
        case .english: return english(hour: hour, minute: minute)
        }
    }

    // MARK: - Dutch

    private static let dutchHours = [
        "twaalf", "één", "twee", "drie", "vier", "vijf", "zes",
        "zeven", "acht", "negen", "tien", "elf",
    ]

    private static func dutch(hour: Int, minute: Int) -> String {
        let current = dutchHours[hour % 12]
        let next = dutchHours[(hour + 1) % 12]
        let time: String
        switch minute {
        case 0: time = "\(current) uur"
        case 5: time = "vijf over \(current)"
        case 10: time = "tien over \(current)"
        case 15: time = "kwart over \(current)"
        case 20: time = "tien voor half \(next)"
        case 25: time = "vijf voor half \(next)"
        case 30: time = "half \(next)"
        case 35: time = "vijf over half \(next)"
        case 40: time = "tien over half \(next)"
        case 45: time = "kwart voor \(next)"
        case 50: time = "tien voor \(next)"
        case 55: time = "vijf voor \(next)"
        default: preconditionFailure("minute must be a multiple of 5")
        }
        return "het is \(time)"
    }

    // MARK: - English

    private static let englishHours = [
        "twelve", "one", "two", "three", "four", "five", "six",
        "seven", "eight", "nine", "ten", "eleven",
    ]

    private static func english(hour: Int, minute: Int) -> String {
        let current = englishHours[hour % 12]
        let next = englishHours[(hour + 1) % 12]
        let time: String
        switch minute {
        case 0: time = "\(current) o’clock"
        case 5: time = "five past \(current)"
        case 10: time = "ten past \(current)"
        case 15: time = "quarter past \(current)"
        case 20: time = "twenty past \(current)"
        case 25: time = "twenty-five past \(current)"
        case 30: time = "half past \(current)"
        case 35: time = "twenty-five to \(next)"
        case 40: time = "twenty to \(next)"
        case 45: time = "quarter to \(next)"
        case 50: time = "ten to \(next)"
        case 55: time = "five to \(next)"
        default: preconditionFailure("minute must be a multiple of 5")
        }
        return "it’s \(time)"
    }

    // MARK: - Timeline support

    /// The instants at which the rounded phrase changes (hh:m2:30 and hh:m7:30),
    /// starting after `date`.
    public static func changeDates(after date: Date, count: Int, calendar: Calendar = .current) -> [Date] {
        let whole = Date(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate.rounded(.down))
        let c = calendar.dateComponents([.minute, .second], from: whole)
        let secondsIntoSlot = ((c.minute ?? 0) * 60 + (c.second ?? 0) + 150) % 300
        let first = whole.addingTimeInterval(TimeInterval(300 - secondsIntoSlot))
        return (0..<count).map { first.addingTimeInterval(TimeInterval($0 * 300)) }
    }
}
