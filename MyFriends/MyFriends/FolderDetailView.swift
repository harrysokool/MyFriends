import SwiftUI
import SwiftData

struct FolderDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let folder: Folder

    @State private var isShowingAddSubfolderAlert = false
    @State private var isShowingEditFolderAlert = false
    @State private var isShowingContactSheet = false
    @State private var newSubfolderName = ""
    @State private var editedFolderName = ""
    @State private var contactName = ""
    @State private var contactPhoneNumber = ""
    @State private var contactBeingEdited: FriendContact?
    @State private var folderBeingEdited: Folder?

    private var subfolders: [Folder] {
        folder.childFolders.sorted { $0.createdAt < $1.createdAt }
    }

    private var contacts: [FriendContact] {
        folder.contacts.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        List {
            Section("Subfolders") {
                if subfolders.isEmpty {
                    sectionPlaceholder("No subfolders yet")
                } else {
                    ForEach(subfolders) { subfolder in
                        NavigationLink {
                            FolderDetailView(folder: subfolder)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "folder.fill")
                                    .foregroundStyle(.blue)

                                Text(subfolder.name)
                                    .font(.body)
                            }
                            .padding(.vertical, 6)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteFolder(subfolder)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                startEditing(folder: subfolder)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }

            Section("Contacts") {
                if contacts.isEmpty {
                    sectionPlaceholder("No contacts yet")
                } else {
                    ForEach(contacts) { contact in
                        NavigationLink {
                            ContactDetailView(contact: contact)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact.name)
                                    .font(.body)
                                    .fontWeight(.medium)

                                Text(contact.phoneNumber)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteContact(contact)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                startEditing(contact: contact)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    startEditing(folder: folder)
                } label: {
                    Image(systemName: "pencil")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("New Subfolder", systemImage: "folder.badge.plus") {
                        newSubfolderName = ""
                        isShowingAddSubfolderAlert = true
                    }

                    Button("New Contact", systemImage: "person.badge.plus") {
                        startAddingContact()
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("New Subfolder", isPresented: $isShowingAddSubfolderAlert) {
            TextField("Subfolder name", text: $newSubfolderName)

            Button("Cancel", role: .cancel) {
                newSubfolderName = ""
            }

            Button("Save") {
                addSubfolder()
            }
            .disabled(trimmedSubfolderName.isEmpty)
        } message: {
            Text("Enter a name for the subfolder.")
        }
        .alert("Edit Folder", isPresented: $isShowingEditFolderAlert) {
            TextField("Folder name", text: $editedFolderName)

            Button("Cancel", role: .cancel) {
                resetFolderEditing()
            }

            Button("Save") {
                saveFolderEdits()
            }
            .disabled(trimmedEditedFolderName.isEmpty)
        } message: {
            Text("Update the folder name.")
        }
        .sheet(isPresented: $isShowingContactSheet) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Name", text: $contactName)
                        TextField("Phone Number", text: $contactPhoneNumber)
                            .keyboardType(.phonePad)
                    }
                }
                .navigationTitle(contactSheetTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            resetContactFields()
                            isShowingContactSheet = false
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button(contactSheetActionTitle) {
                            saveContact()
                        }
                        .disabled(trimmedContactName.isEmpty || trimmedPhoneNumber.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var trimmedSubfolderName: String {
        newSubfolderName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedEditedFolderName: String {
        editedFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedContactName: String {
        contactName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedPhoneNumber: String {
        contactPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var contactSheetTitle: String {
        contactBeingEdited == nil ? "New Contact" : "Edit Contact"
    }

    private var contactSheetActionTitle: String {
        contactBeingEdited == nil ? "Save" : "Update"
    }

    @ViewBuilder
    private func sectionPlaceholder(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
    }

    private func addSubfolder() {
        let subfolder = Folder(name: trimmedSubfolderName, parent: folder)
        modelContext.insert(subfolder)

        do {
            try modelContext.save()
            newSubfolderName = ""
        } catch {
            print("Failed to save subfolder: \(error)")
        }
    }

    private func startEditing(folder: Folder) {
        folderBeingEdited = folder
        editedFolderName = folder.name
        isShowingEditFolderAlert = true
    }

    private func saveFolderEdits() {
        guard let folderBeingEdited else { return }

        folderBeingEdited.name = trimmedEditedFolderName

        do {
            try modelContext.save()
            resetFolderEditing()
        } catch {
            print("Failed to update folder: \(error)")
        }
    }

    private func deleteFolder(_ folder: Folder) {
        modelContext.delete(folder)

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete folder: \(error)")
        }
    }

    private func startAddingContact() {
        contactBeingEdited = nil
        resetContactFields()
        isShowingContactSheet = true
    }

    private func startEditing(contact: FriendContact) {
        contactBeingEdited = contact
        contactName = contact.name
        contactPhoneNumber = contact.phoneNumber
        isShowingContactSheet = true
    }

    private func saveContact() {
        if let contactBeingEdited {
            contactBeingEdited.name = trimmedContactName
            contactBeingEdited.phoneNumber = trimmedPhoneNumber
        } else {
            let contact = FriendContact(
                name: trimmedContactName,
                phoneNumber: trimmedPhoneNumber,
                folder: folder
            )
            modelContext.insert(contact)
        }

        do {
            try modelContext.save()
            resetContactFields()
            contactBeingEdited = nil
            isShowingContactSheet = false
        } catch {
            print("Failed to save contact: \(error)")
        }
    }

    private func deleteContact(_ contact: FriendContact) {
        modelContext.delete(contact)

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete contact: \(error)")
        }
    }

    private func resetFolderEditing() {
        folderBeingEdited = nil
        editedFolderName = ""
    }

    private func resetContactFields() {
        contactName = ""
        contactPhoneNumber = ""
    }
}

#Preview {
    NavigationStack {
        FolderDetailView(folder: Folder(name: "Friends"))
    }
    .modelContainer(for: [Folder.self, FriendContact.self], inMemory: true)
}
