import Foundation

enum ContactPersistenceService {
    // Keeps form-to-model mapping in one place so the views can stay focused on UI flow.
    static func apply(_ formState: ContactFormState, to contact: FriendContact) {
        let selectedCountry = formState.selectedCountry

        contact.name = formState.trimmedName
        contact.phoneNumber = formState.storedPhoneNumber
        contact.phoneRegionCode = selectedCountry.regionCode
        contact.phoneDialingCode = selectedCountry.dialingCode
        contact.email = optionalValue(formState.trimmedEmail, from: formState)
        contact.instagram = optionalValue(formState.trimmedInstagram, from: formState)
        contact.notes = optionalValue(formState.trimmedNotes, from: formState)
    }

    static func makeContact(from formState: ContactFormState, in folder: Folder) -> FriendContact {
        let selectedCountry = formState.selectedCountry

        return FriendContact(
            name: formState.trimmedName,
            phoneNumber: formState.storedPhoneNumber,
            phoneRegionCode: selectedCountry.regionCode,
            phoneDialingCode: selectedCountry.dialingCode,
            email: optionalValue(formState.trimmedEmail, from: formState),
            instagram: optionalValue(formState.trimmedInstagram, from: formState),
            notes: optionalValue(formState.trimmedNotes, from: formState),
            folder: folder
        )
    }

    private static func optionalValue(_ value: String, from formState: ContactFormState) -> String? {
        formState.optionalValue(value)
    }
}
