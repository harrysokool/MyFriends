import SwiftUI
import SwiftData

struct ContactDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    let contact: FriendContact

    @State private var isShowingEditContactSheet = false
    @State private var isShowingInteractionSheet = false
    @State private var isShowingCallConfirmation = false
    @State private var contactForm = ContactFormState()
    @State private var interactionDate = Date()
    @State private var interactionNote = ""

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

                interactionSection
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: contact.resolvedIsFavorite ? "star.fill" : "star")
                }
                .tint(contact.resolvedIsFavorite ? .yellow : .primary)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    startEditingInteraction()
                } label: {
                    Image(systemName: "bubble.left.and.bubble.right")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    contactForm = ContactFormState(contact: contact)
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
                ContactFormView(formState: $contactForm)
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
                        .disabled(!contactForm.canSave)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $isShowingInteractionSheet) {
            NavigationStack {
                Form {
                    Section("Interaction") {
                        DatePicker(
                            "Date",
                            selection: $interactionDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )

                        TextField("Interaction note", text: $interactionNote, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                .navigationTitle("Log Interaction")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            resetInteractionFields()
                            isShowingInteractionSheet = false
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            saveInteraction()
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    @ViewBuilder
    private var interactionSection: some View {
        if let lastInteractedAt = contact.lastInteractedAt {
            detailRow(title: "Last Interaction", value: lastInteractionFormatter.string(from: lastInteractedAt))
        }

        if let interactionNote = displayValue(contact.interactionNote) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Interaction Note")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(interactionNote)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private var trimmedInteractionNote: String {
        interactionNote.trimmingCharacters(in: .whitespacesAndNewlines)
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
        ContactPersistenceService.apply(contactForm, to: contact)

        do {
            try modelContext.save()
            resetFields()
            isShowingEditContactSheet = false
        } catch {
            print("Failed to update contact: \(error)")
        }
    }

    private func resetFields() {
        contactForm.reset()
    }

    private func startEditingInteraction() {
        interactionDate = contact.lastInteractedAt ?? .now
        interactionNote = contact.interactionNote ?? ""
        isShowingInteractionSheet = true
    }

    private func saveInteraction() {
        contact.lastInteractedAt = interactionDate
        contact.interactionNote = optionalValue(from: trimmedInteractionNote)

        do {
            try modelContext.save()
            resetInteractionFields()
            isShowingInteractionSheet = false
        } catch {
            print("Failed to save interaction: \(error)")
        }
    }

    private func resetInteractionFields() {
        interactionDate = .now
        interactionNote = ""
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

    private func toggleFavorite() {
        contact.isFavorite = !contact.resolvedIsFavorite

        do {
            try modelContext.save()
        } catch {
            print("Failed to update favorite status: \(error)")
        }
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

    private var lastInteractionFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
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
                isFavorite: true,
                email: "alex@example.com",
                instagram: "@alex",
                notes: "Met through work."
            )
        )
    }
}
