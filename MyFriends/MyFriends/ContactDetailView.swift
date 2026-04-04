import SwiftUI
import SwiftData

struct ContactDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let contact: FriendContact

    @State private var isShowingEditContactSheet = false
    @State private var contactName = ""
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

                        Text(contact.phoneNumber)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }

            Section("Details") {
                detailRow(title: "Phone", value: contact.phoneNumber)

                if let email = displayValue(contact.email) {
                    detailRow(title: "Email", value: email)
                }

                if let instagram = displayValue(contact.instagram) {
                    detailRow(title: "Instagram", value: instagram)
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
        .sheet(isPresented: $isShowingEditContactSheet) {
            NavigationStack {
                Form {
                    Section("Contact Info") {
                        TextField("Name", text: $contactName)
                        TextField("Phone Number", text: $phoneNumber)
                            .keyboardType(.phonePad)
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
                        .disabled(trimmedContactName.isEmpty || trimmedPhoneNumber.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var trimmedContactName: String {
        contactName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedPhoneNumber: String {
        phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
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

    private func saveContact() {
        contact.name = trimmedContactName
        contact.phoneNumber = trimmedPhoneNumber
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
}

#Preview {
    NavigationStack {
        ContactDetailView(
            contact: FriendContact(
                name: "Alex",
                phoneNumber: "555-123-4567",
                email: "alex@example.com",
                instagram: "@alex",
                notes: "Met through work."
            )
        )
    }
}
