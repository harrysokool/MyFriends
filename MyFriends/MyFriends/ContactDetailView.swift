import SwiftUI
import SwiftData

struct ContactDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let contact: FriendContact

    @State private var isShowingEditContactSheet = false
    @State private var contactName = ""
    @State private var phoneNumber = ""

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text(contact.name)
                .font(.title2)
                .fontWeight(.semibold)

            Text(contact.phoneNumber)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    contactName = contact.name
                    phoneNumber = contact.phoneNumber
                    isShowingEditContactSheet = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $isShowingEditContactSheet) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Name", text: $contactName)
                        TextField("Phone Number", text: $phoneNumber)
                            .keyboardType(.phonePad)
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

    private func saveContact() {
        contact.name = trimmedContactName
        contact.phoneNumber = trimmedPhoneNumber

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
    }
}

#Preview {
    NavigationStack {
        ContactDetailView(contact: FriendContact(name: "Alex", phoneNumber: "555-123-4567"))
    }
}
