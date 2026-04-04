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
