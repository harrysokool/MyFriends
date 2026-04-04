import Foundation

enum ContactPersistenceService {
    static func apply(_ formState: ContactFormState, to contact: FriendContact) {
        contact.name = formState.trimmedName
        contact.phoneNumber = formState.storedPhoneNumber
        contact.phoneRegionCode = formState.selectedCountry.regionCode
        contact.phoneDialingCode = formState.selectedCountry.dialingCode
        contact.email = formState.optionalValue(formState.trimmedEmail)
        contact.instagram = formState.optionalValue(formState.trimmedInstagram)
        contact.notes = formState.optionalValue(formState.trimmedNotes)
    }

    static func makeContact(from formState: ContactFormState, in folder: Folder) -> FriendContact {
        FriendContact(
            name: formState.trimmedName,
            phoneNumber: formState.storedPhoneNumber,
            phoneRegionCode: formState.selectedCountry.regionCode,
            phoneDialingCode: formState.selectedCountry.dialingCode,
            email: formState.optionalValue(formState.trimmedEmail),
            instagram: formState.optionalValue(formState.trimmedInstagram),
            notes: formState.optionalValue(formState.trimmedNotes),
            folder: folder
        )
    }
}
