import SwiftUI
import SwiftData

struct FolderDetailView: View {
    // MARK: - Data

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.createdAt) private var allFolders: [Folder]
    @Query(sort: \FriendContact.createdAt) private var allContacts: [FriendContact]

    let folder: Folder

    // MARK: - View State

    @State private var isShowingAddSubfolderAlert = false
    @State private var isShowingEditFolderAlert = false
    @State private var isShowingContactSheet = false
    @State private var newSubfolderName = ""
    @State private var editedFolderName = ""
    @State private var searchText = ""
    @State private var contactForm = ContactFormState()
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
        SearchService.normalizedQuery(searchText)
    }

    private var isSearching: Bool {
        !normalizedSearchText.isEmpty
    }

    private var matchingFolders: [Folder] {
        searchResults.folders
    }

    private var matchingContacts: [FriendContact] {
        searchResults.contacts
    }

    private var searchResults: SearchResults {
        SearchService.search(
            query: searchText,
            folders: allFolders,
            contacts: allContacts
        )
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
        .toolbar { toolbarContent }
        .alert("New Subfolder", isPresented: $isShowingAddSubfolderAlert) {
            TextField("Subfolder name", text: $newSubfolderName)

            Button("Cancel", role: .cancel) {
                newSubfolderName = ""
            }

            Button("Save") {
                addSubfolder()
            }
            .disabled(trimmedSubfolderName.isEmpty || hasDuplicateSubfolderName)
        } message: {
            Text(newSubfolderValidationMessage)
        }
        .alert("Edit Folder", isPresented: $isShowingEditFolderAlert) {
            TextField("Folder name", text: $editedFolderName)

            Button("Cancel", role: .cancel) {
                resetFolderEditing()
            }

            Button("Save") {
                saveFolderEdits()
            }
            .disabled(trimmedEditedFolderName.isEmpty || hasDuplicateEditedFolderName)
        } message: {
            Text(editedFolderValidationMessage)
        }
        .sheet(isPresented: $isShowingContactSheet) { contactSheet }
    }

    // MARK: - Content

    private var localContentList: some View {
        List {
            SubfolderListSectionView(
                subfolders: filteredSubfolders,
                placeholderText: subfolderPlaceholderText,
                onEdit: startEditing(folder:),
                onDelete: deleteFolder(_:)
            )

            ContactListSectionView(
                title: "Contacts",
                contacts: filteredContacts,
                placeholderText: contactPlaceholderText,
                subtitle: { $0.formattedPhoneNumber },
                onEdit: startEditing(contact:),
                onDelete: deleteContact(_:)
            )
        }
        .listStyle(.insetGrouped)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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
                    startAddingSubfolder()
                }

                Button("New Contact", systemImage: "person.badge.plus") {
                    startAddingContact()
                }
            } label: {
                Image(systemName: "plus")
            }
        }
    }

    private var contactSheet: some View {
        NavigationStack {
            ContactFormView(formState: $contactForm)
                .navigationTitle(contactSheetTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismissContactSheet()
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button(contactSheetActionTitle) {
                            saveContact()
                        }
                        .disabled(!contactForm.canSave)
                    }
                }
        }
        .presentationDetents([.medium])
    }

    private var globalSearchResultsList: some View {
        List {
            folderSearchResultsSection

            ContactListSectionView(
                title: "Contacts",
                contacts: matchingContacts,
                placeholderText: "No matching contacts",
                subtitle: { $0.folderPath ?? "Unassigned" },
                onEdit: startEditing(contact:),
                onDelete: deleteContact(_:)
            )
        }
        .listStyle(.insetGrouped)
    }

    private var folderSearchResultsSection: some View {
        Section("Folders") {
            if matchingFolders.isEmpty {
                FolderDetailEmptyStateView(text: "No matching folders")
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
    }

    private var trimmedSubfolderName: String {
        newSubfolderName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var newSubfolderValidationMessage: String {
        duplicateFolderNameMessage(
            for: trimmedSubfolderName,
            in: folder
        ) ?? "Enter a name for the subfolder."
    }

    private var trimmedEditedFolderName: String {
        editedFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var editedFolderValidationMessage: String {
        duplicateFolderNameMessage(
            for: trimmedEditedFolderName,
            in: folderBeingEdited?.parent,
            excluding: folderBeingEdited
        ) ?? "Update the folder name."
    }

    private var contactSheetTitle: String {
        contactBeingEdited == nil ? "New Contact" : "Edit Contact"
    }

    private var contactSheetActionTitle: String {
        contactBeingEdited == nil ? "Save" : "Update"
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

    // MARK: - Actions

    private func startAddingSubfolder() {
        newSubfolderName = ""
        isShowingAddSubfolderAlert = true
    }

    private var hasDuplicateSubfolderName: Bool {
        hasDuplicateFolderName(trimmedSubfolderName, in: folder)
    }

    private var hasDuplicateEditedFolderName: Bool {
        hasDuplicateFolderName(
            trimmedEditedFolderName,
            in: folderBeingEdited?.parent,
            excluding: folderBeingEdited
        )
    }

    private func duplicateFolderNameMessage(
        for name: String,
        in parent: Folder?,
        excluding folder: Folder? = nil
    ) -> String? {
        guard hasDuplicateFolderName(name, in: parent, excluding: folder) else {
            return nil
        }

        return "A folder with this name already exists here."
    }

    // Folder names only need to be unique among siblings that share the same parent.
    private func hasDuplicateFolderName(
        _ name: String,
        in parent: Folder?,
        excluding folder: Folder? = nil
    ) -> Bool {
        guard !name.isEmpty else { return false }

        return allFolders.contains { candidate in
            candidate.parent === parent
                && candidate !== folder
                && candidate.name.localizedCaseInsensitiveCompare(name) == .orderedSame
        }
    }

    private func addSubfolder() {
        guard !hasDuplicateSubfolderName else { return }

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
        guard !hasDuplicateEditedFolderName else { return }

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
        contactForm = ContactFormState(contact: contact)
        isShowingContactSheet = true
    }

    private func saveContact() {
        if let contactBeingEdited {
            ContactPersistenceService.apply(contactForm, to: contactBeingEdited)
        } else {
            let contact = ContactPersistenceService.makeContact(from: contactForm, in: folder)
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

    private func dismissContactSheet() {
        resetContactFields()
        isShowingContactSheet = false
    }

    private func resetContactFields() {
        contactForm.reset()
    }
}

#Preview {
    NavigationStack {
        FolderDetailView(folder: Folder(name: "Friends"))
    }
    .modelContainer(for: [Folder.self, FriendContact.self], inMemory: true)
}
