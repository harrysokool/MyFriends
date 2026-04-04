import SwiftUI
import SwiftData

struct ContactDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    let contact: FriendContact

    @State private var isShowingEditContactSheet = false
    @State private var isShowingCallConfirmation = false
    @State private var contactName = ""
    @State private var contactRegionCode = PhoneCountry.defaultCountry.regionCode
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var instagram = ""
    @State private var notes = ""

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                        .frame(width: 56, height: 56)
                        .background(Color.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(contact.name)
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(contact.formattedPhoneNumber)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }

            Section("Details") {
                phoneRow

                if let email = displayValue(contact.email) {
                    detailRow(title: "Email", value: email)
                }

                if let instagram = displayValue(contact.instagram) {
                    instagramRow(displayValue: instagram)
                }

                if let notes = displayValue(contact.notes) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    contactName = contact.name
                    contactRegionCode = contact.resolvedPhoneRegionCode
                    phoneNumber = contact.phoneNumber
                    email = contact.email ?? ""
                    instagram = contact.instagram ?? ""
                    notes = contact.notes ?? ""
                    isShowingEditContactSheet = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .alert("Call \(contact.name)?", isPresented: $isShowingCallConfirmation) {
            Button("Cancel", role: .cancel) {}

            Button("Call") {
                callContact()
            }
        } message: {
            Text("This will open the Phone app.")
        }
        .sheet(isPresented: $isShowingEditContactSheet) {
            NavigationStack {
                Form {
                    Section("Contact Info") {
                        TextField("Name", text: $contactName)
                        Picker("Country", selection: $contactRegionCode) {
                            ForEach(PhoneCountry.all) { country in
                                Text(country.displayName).tag(country.regionCode)
                            }
                        }
                        HStack(spacing: 12) {
                            Text(selectedCountry.dialingCode)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))

                            TextField("Phone Number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                        }

                        if let phoneValidationMessage {
                            Text(phoneValidationMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }

                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        TextField("Instagram", text: $instagram)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    Section("Notes") {
                        TextField("Notes", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                .navigationTitle("Edit Contact")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            resetFields()
                            isShowingEditContactSheet = false
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            saveContact()
                        }
                        .disabled(!canSaveContact)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var trimmedContactName: String {
        contactName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var selectedCountry: PhoneCountry {
        PhoneCountry.country(for: contactRegionCode)
    }

    private var trimmedPhoneNumber: String {
        PhoneNumberValidator.normalizedInput(phoneNumber)
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedInstagram: String {
        instagram.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedNotes: String {
        notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var phoneValidationMessage: String? {
        PhoneNumberValidator.validationMessage(for: phoneNumber)
    }

    private var canSaveContact: Bool {
        !trimmedContactName.isEmpty && phoneValidationMessage == nil
    }

    private var callablePhoneNumber: String? {
        let allowedCharacters = CharacterSet(charactersIn: "+0123456789")
        let rawNumber = "\(contact.resolvedPhoneDialingCode)\(contact.phoneNumber)"
        let sanitized = rawNumber.unicodeScalars.filter { allowedCharacters.contains($0) }
        let result = String(String.UnicodeScalarView(sanitized))

        return result.isEmpty ? nil : result
    }

    private var instagramUsername: String? {
        guard let instagram = displayValue(contact.instagram) else { return nil }

        let trimmedUsername = instagram
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "@"))

        guard !trimmedUsername.isEmpty else { return nil }

        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._"))
        let isValid = trimmedUsername.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }

        guard isValid else { return nil }

        return trimmedUsername
    }

    @ViewBuilder
    private var phoneRow: some View {
        if callablePhoneNumber != nil {
            Button {
                isShowingCallConfirmation = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Phone")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(contact.formattedPhoneNumber)
                            .font(.body)
                            .foregroundStyle(.blue)
                    }

                    Spacer()

                    Image(systemName: "phone.fill")
                        .font(.footnote)
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        } else {
            detailRow(title: "Phone", value: contact.phoneNumber)
        }
    }

    @ViewBuilder
    private func instagramRow(displayValue: String) -> some View {
        if let instagramUsername {
            Button {
                openInstagramProfile(username: instagramUsername)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Instagram")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(displayValue)
                            .font(.body)
                            .foregroundStyle(.blue)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right.square.fill")
                        .font(.footnote)
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        } else {
            detailRow(title: "Instagram", value: displayValue)
        }
    }

    private func saveContact() {
        contact.name = trimmedContactName
        contact.phoneRegionCode = selectedCountry.regionCode
        contact.phoneDialingCode = selectedCountry.dialingCode
        contact.phoneNumber = PhoneNumberValidator.storageValue(
            from: trimmedPhoneNumber,
            dialingCode: selectedCountry.dialingCode
        )
        contact.email = optionalValue(from: trimmedEmail)
        contact.instagram = optionalValue(from: trimmedInstagram)
        contact.notes = optionalValue(from: trimmedNotes)

        do {
            try modelContext.save()
            resetFields()
            isShowingEditContactSheet = false
        } catch {
            print("Failed to update contact: \(error)")
        }
    }

    private func resetFields() {
        contactName = ""
        contactRegionCode = PhoneCountry.defaultCountry.regionCode
        phoneNumber = ""
        email = ""
        instagram = ""
        notes = ""
    }

    @ViewBuilder
    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(value)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func displayValue(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func optionalValue(from value: String) -> String? {
        value.isEmpty ? nil : value
    }

    private func callContact() {
        guard
            let callablePhoneNumber,
            let url = URL(string: "tel://\(callablePhoneNumber)")
        else {
            return
        }

        openURL(url)
    }

    private func openInstagramProfile(username: String) {
        guard
            let appURL = URL(string: "instagram://user?username=\(username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? username)"),
            let webURL = URL(string: "https://www.instagram.com/\(username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? username)/")
        else {
            return
        }

        openURL(appURL) { accepted in
            if !accepted {
                openURL(webURL)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContactDetailView(
            contact: FriendContact(
                name: "Alex",
                phoneNumber: "555-123-4567",
                phoneRegionCode: "US",
                phoneDialingCode: "+1",
                email: "alex@example.com",
                instagram: "@alex",
                notes: "Met through work."
            )
        )
    }
}
