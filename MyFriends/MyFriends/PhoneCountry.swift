import Foundation

struct PhoneCountry: Identifiable, Hashable {
    let regionCode: String
    let name: String
    let dialingCode: String

    var id: String { regionCode }
    var displayName: String { "\(name) (\(dialingCode))" }

    static let all: [PhoneCountry] = [
        PhoneCountry(regionCode: "US", name: "United States", dialingCode: "+1"),
        PhoneCountry(regionCode: "CA", name: "Canada", dialingCode: "+1"),
        PhoneCountry(regionCode: "GB", name: "United Kingdom", dialingCode: "+44"),
        PhoneCountry(regionCode: "AU", name: "Australia", dialingCode: "+61"),
        PhoneCountry(regionCode: "HK", name: "Hong Kong", dialingCode: "+852"),
        PhoneCountry(regionCode: "SG", name: "Singapore", dialingCode: "+65"),
        PhoneCountry(regionCode: "JP", name: "Japan", dialingCode: "+81"),
        PhoneCountry(regionCode: "KR", name: "South Korea", dialingCode: "+82"),
        PhoneCountry(regionCode: "IN", name: "India", dialingCode: "+91"),
        PhoneCountry(regionCode: "DE", name: "Germany", dialingCode: "+49"),
        PhoneCountry(regionCode: "FR", name: "France", dialingCode: "+33")
    ]

    static let defaultCountry: PhoneCountry = {
        all.first(where: { $0.regionCode == "US" }) ?? all[0]
    }()

    static func country(for regionCode: String) -> PhoneCountry {
        all.first(where: { $0.regionCode == regionCode }) ?? defaultCountry
    }
}

enum PhoneNumberValidator {
    private static let allowedCharacters = CharacterSet(charactersIn: "+0123456789 -()")

    static func normalizedInput(_ input: String) -> String {
        input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

    static func validationMessage(for input: String) -> String? {
        let normalized = normalizedInput(input)

        guard !normalized.isEmpty else {
            return "Enter a phone number."
        }

        if normalized.unicodeScalars.contains(where: { !allowedCharacters.contains($0) }) {
            return "Use only digits, spaces, hyphens, parentheses, or a leading +."
        }

        let plusCount = normalized.filter { $0 == "+" }.count
        if plusCount > 1 || (plusCount == 1 && !normalized.hasPrefix("+")) {
            return "The + sign is only allowed at the beginning."
        }

        let digitCount = digitsOnly(from: normalized).count
        if digitCount < 7 || digitCount > 15 {
            return "Phone numbers should contain 7 to 15 digits."
        }

        return nil
    }

    static func storageValue(from input: String, dialingCode: String) -> String {
        let normalized = normalizedInput(input)
        let digits = digitsOnly(from: normalized)
        let dialingDigits = digitsOnly(from: dialingCode)

        if normalized.hasPrefix("+"), digits.hasPrefix(dialingDigits), digits.count > dialingDigits.count {
            return String(digits.dropFirst(dialingDigits.count))
        }

        return digits
    }

    static func digitsOnly(from input: String) -> String {
        input.filter(\.isNumber)
    }
}
