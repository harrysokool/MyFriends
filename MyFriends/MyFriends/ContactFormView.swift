import SwiftUI

struct ContactFormState {
    var name = ""
    var regionCode = PhoneCountry.defaultCountry.regionCode
    var phoneNumber = ""
    var email = ""
    var instagram = ""
    var notes = ""

    init() {}

    init(contact: FriendContact) {
        name = contact.name
        regionCode = contact.resolvedPhoneRegionCode
        phoneNumber = contact.phoneNumber
        email = contact.email ?? ""
        instagram = contact.instagram ?? ""
        notes = contact.notes ?? ""
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var selectedCountry: PhoneCountry {
        PhoneCountry.country(for: regionCode)
    }

    var normalizedPhoneNumber: String {
        PhoneNumberValidator.normalizedInput(phoneNumber)
    }

    var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedInstagram: String {
        instagram.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedNotes: String {
        notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var phoneValidationMessage: String? {
        PhoneNumberValidator.validationMessage(for: phoneNumber)
    }

    var canSave: Bool {
        !trimmedName.isEmpty && phoneValidationMessage == nil
    }

    var storedPhoneNumber: String {
        PhoneNumberValidator.storageValue(
            from: normalizedPhoneNumber,
            dialingCode: selectedCountry.dialingCode
        )
    }

    func optionalValue(_ value: String) -> String? {
        value.isEmpty ? nil : value
    }

    mutating func reset() {
        self = ContactFormState()
    }
}

struct ContactFormView: View {
    @Binding var formState: ContactFormState

    var body: some View {
        Form {
            Section("Contact Info") {
                TextField("Name", text: $formState.name)
                Picker("Country", selection: $formState.regionCode) {
                    ForEach(PhoneCountry.all) { country in
                        Text(country.displayName).tag(country.regionCode)
                    }
                }

                HStack(spacing: 12) {
                    Text(formState.selectedCountry.dialingCode)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))

                    TextField("Phone Number", text: $formState.phoneNumber)
                        .keyboardType(.phonePad)
                }

                if let phoneValidationMessage = formState.phoneValidationMessage {
                    Text(phoneValidationMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                TextField("Email", text: $formState.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Instagram", text: $formState.instagram)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Section("Notes") {
                TextField("Notes", text: $formState.notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
    }
}
