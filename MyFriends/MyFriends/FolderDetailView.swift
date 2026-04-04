import SwiftUI
import SwiftData

struct FolderDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.createdAt) private var allFolders: [Folder]
    @Query(sort: \FriendContact.createdAt) private var allContacts: [FriendContact]

    let folder: Folder

    @State private var isShowingAddSubfolderAlert = false
    @State private var isShowingEditFolderAlert = false
    @State private var isShowingContactSheet = false
    @State private var newSubfolderName = ""
    @State private var editedFolderName = ""
    @State private var searchText = ""
    @State private var contactName = ""
    @State private var contactRegionCode = PhoneCountry.defaultCountry.regionCode
    @State private var contactPhoneNumber = ""
    @State private var contactEmail = ""
    @State private var contactInstagram = ""
    @State private var contactNotes = ""
    @State private var contactBeingEdited: FriendContact?
    @State private var folderBeingEdited: Folder?

    private var subfolders: [Folder] {
        folder.childFolders.sorted { $0.createdAt < $1.createdAt }
    }

    private var contacts: [FriendContact] {
        folder.contacts.sorted { $0.createdAt < $1.createdAt }
    }

    private var filteredSubfolders: [Folder] {
        guard !normalizedSearchText.isEmpty else { return subfolders }

        return subfolders.filter {
            $0.name.localizedCaseInsensitiveContains(normalizedSearchText)
        }
    }

    private var filteredContacts: [FriendContact] {
        guard !normalizedSearchText.isEmpty else { return contacts }

        return contacts.filter {
            $0.name.localizedCaseInsensitiveContains(normalizedSearchText)
        }
    }

    private var normalizedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool {
        !normalizedSearchText.isEmpty
    }

    private var matchingFolders: [Folder] {
        guard isSearching else { return [] }

        return allFolders
            .filter { $0.name.localizedCaseInsensitiveContains(normalizedSearchText) }
            .sorted { $0.fullPath.localizedCaseInsensitiveCompare($1.fullPath) == .orderedAscending }
    }

    private var matchingContacts: [FriendContact] {
        guard isSearching else { return [] }

        return allContacts
            .filter { $0.name.localizedCaseInsensitiveContains(normalizedSearchText) }
            .sorted { lhs, rhs in
                let leftPath = lhs.folderPath ?? ""
                let rightPath = rhs.folderPath ?? ""

                if leftPath.caseInsensitiveCompare(rightPath) == .orderedSame {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }

                return leftPath.localizedCaseInsensitiveCompare(rightPath) == .orderedAscending
            }
    }

    var body: some View {
        Group {
            if isSearching {
                globalSearchResultsList
            } else {
                localContentList
            }
        }
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: "Search folders and contacts"
        )
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

                            TextField("Phone Number", text: $contactPhoneNumber)
                                .keyboardType(.phonePad)
                        }

                        if let phoneValidationMessage {
                            Text(phoneValidationMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }

                        TextField("Email", text: $contactEmail)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        TextField("Instagram", text: $contactInstagram)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    Section("Notes") {
                        TextField("Notes", text: $contactNotes, axis: .vertical)
                            .lineLimit(3...6)
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
                        .disabled(!canSaveContact)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var localContentList: some View {
        List {
            Section("Subfolders") {
                if filteredSubfolders.isEmpty {
                    sectionPlaceholder(subfolderPlaceholderText)
                } else {
                    ForEach(filteredSubfolders) { subfolder in
                        NavigationLink {
                            FolderDetailView(folder: subfolder)
                        } label: {
                            FolderRowView(name: subfolder.name, subtitle: "Subfolder")
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
                if filteredContacts.isEmpty {
                    sectionPlaceholder(contactPlaceholderText)
                } else {
                    ForEach(filteredContacts) { contact in
                        NavigationLink {
                            ContactDetailView(contact: contact)
                        } label: {
                            ContactRowView(name: contact.name, subtitle: contact.formattedPhoneNumber)
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
    }

    private var globalSearchResultsList: some View {
        List {
            Section("Folders") {
                if matchingFolders.isEmpty {
                    sectionPlaceholder("No matching folders")
                } else {
                    ForEach(matchingFolders) { folder in
                        NavigationLink {
                            FolderDetailView(folder: folder)
                        } label: {
                            FolderRowView(
                                name: folder.name,
                                subtitle: folder.parentPath ?? "Root folder"
                            )
                        }
                    }
                }
            }

            Section("Contacts") {
                if matchingContacts.isEmpty {
                    sectionPlaceholder("No matching contacts")
                } else {
                    ForEach(matchingContacts) { contact in
                        NavigationLink {
                            ContactDetailView(contact: contact)
                        } label: {
                            ContactRowView(
                                name: contact.name,
                                subtitle: contact.folderPath ?? "Unassigned"
                            )
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
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

    private var selectedCountry: PhoneCountry {
        PhoneCountry.country(for: contactRegionCode)
    }

    private var trimmedPhoneNumber: String {
        PhoneNumberValidator.normalizedInput(contactPhoneNumber)
    }

    private var trimmedEmail: String {
        contactEmail.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedInstagram: String {
        contactInstagram.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedNotes: String {
        contactNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var contactSheetTitle: String {
        contactBeingEdited == nil ? "New Contact" : "Edit Contact"
    }

    private var contactSheetActionTitle: String {
        contactBeingEdited == nil ? "Save" : "Update"
    }

    private var phoneValidationMessage: String? {
        PhoneNumberValidator.validationMessage(for: contactPhoneNumber)
    }

    private var canSaveContact: Bool {
        !trimmedContactName.isEmpty && phoneValidationMessage == nil
    }

    private var subfolderPlaceholderText: String {
        if subfolders.isEmpty {
            return "No subfolders yet"
        }

        return "No matching subfolders"
    }

    private var contactPlaceholderText: String {
        if contacts.isEmpty {
            return "No contacts yet"
        }

        return "No matching contacts"
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
        contactRegionCode = contact.resolvedPhoneRegionCode
        contactPhoneNumber = contact.phoneNumber
        contactEmail = contact.email ?? ""
        contactInstagram = contact.instagram ?? ""
        contactNotes = contact.notes ?? ""
        isShowingContactSheet = true
    }

    private func saveContact() {
        if let contactBeingEdited {
            contactBeingEdited.name = trimmedContactName
            contactBeingEdited.phoneNumber = PhoneNumberValidator.storageValue(
                from: trimmedPhoneNumber,
                dialingCode: selectedCountry.dialingCode
            )
            contactBeingEdited.phoneRegionCode = selectedCountry.regionCode
            contactBeingEdited.phoneDialingCode = selectedCountry.dialingCode
            contactBeingEdited.email = optionalValue(from: trimmedEmail)
            contactBeingEdited.instagram = optionalValue(from: trimmedInstagram)
            contactBeingEdited.notes = optionalValue(from: trimmedNotes)
        } else {
            let contact = FriendContact(
                name: trimmedContactName,
                phoneNumber: PhoneNumberValidator.storageValue(
                    from: trimmedPhoneNumber,
                    dialingCode: selectedCountry.dialingCode
                ),
                phoneRegionCode: selectedCountry.regionCode,
                phoneDialingCode: selectedCountry.dialingCode,
                email: optionalValue(from: trimmedEmail),
                instagram: optionalValue(from: trimmedInstagram),
                notes: optionalValue(from: trimmedNotes),
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
        contactRegionCode = PhoneCountry.defaultCountry.regionCode
        contactPhoneNumber = ""
        contactEmail = ""
        contactInstagram = ""
        contactNotes = ""
    }

    private func optionalValue(from value: String) -> String? {
        value.isEmpty ? nil : value
    }
}

#Preview {
    NavigationStack {
        FolderDetailView(folder: Folder(name: "Friends"))
    }
    .modelContainer(for: [Folder.self, FriendContact.self], inMemory: true)
}
