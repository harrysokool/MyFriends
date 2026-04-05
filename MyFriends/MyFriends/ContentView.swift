import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - Data

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.createdAt) private var folders: [Folder]
    @Query(sort: \FriendContact.createdAt) private var contacts: [FriendContact]

    // MARK: - View State

    @State private var isShowingAddFolderAlert = false
    @State private var isShowingEditFolderAlert = false
    @State private var newFolderName = ""
    @State private var editedFolderName = ""
    @State private var searchText = ""
    @State private var folderBeingEdited: Folder?

    // Root folders drive the top-level navigation list.
    private var rootFolders: [Folder] {
        folders
            .filter { $0.parent == nil }
            .sorted { $0.createdAt < $1.createdAt }
    }

    private var filteredFolders: [Folder] {
        guard !normalizedSearchText.isEmpty else { return rootFolders }

        return rootFolders.filter {
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
            folders: folders,
            contacts: contacts
        )
    }

    private var favoriteContacts: [FriendContact] {
        SearchService.contactsSortedByPath(
            contacts.filter { $0.resolvedIsFavorite }
        )
    }

    private var isShowingFavoritesRow: Bool {
        !favoriteContacts.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if isSearching {
                    searchResultsList
                } else if rootFolders.isEmpty {
                    emptyStateView
                } else {
                    folderList
                }
            }
            .navigationTitle("MyFriends")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        startAddingFolder()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("New Folder", isPresented: $isShowingAddFolderAlert) {
                TextField("Folder name", text: $newFolderName)

                Button("Cancel", role: .cancel) {
                    newFolderName = ""
                }

                Button("Save") {
                    addFolder()
                }
                .disabled(trimmedFolderName.isEmpty || hasDuplicateRootFolderName)
            } message: {
                Text(newFolderValidationMessage)
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
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search folders and contacts"
            )
        }
    }

    // MARK: - Content

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Folders Yet",
            systemImage: "folder",
            description: Text("Tap the + button to create your first folder.")
        )
    }

    private var folderList: some View {
        List {
            if isShowingFavoritesRow {
                NavigationLink {
                    FavoritesView()
                } label: {
                    FavoritesRowView(count: favoriteContacts.count)
                }
            }

            ForEach(filteredFolders) { folder in
                folderRow(for: folder)
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private var searchResultsList: some View {
        if searchResults.isEmpty {
            ContentUnavailableView.search(text: normalizedSearchText)
        } else {
            List {
                Section("Folders") {
                    if matchingFolders.isEmpty {
                        searchPlaceholder("No matching folders")
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
                        searchPlaceholder("No matching contacts")
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
    }

    private func folderRow(for folder: Folder) -> some View {
        NavigationLink {
            FolderDetailView(folder: folder)
        } label: {
            FolderRowView(name: folder.name, subtitle: "Folder")
        }
        .swipeActions {
            Button(role: .destructive) {
                deleteFolder(folder)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                startEditing(folder)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }

    private var trimmedFolderName: String {
        newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var newFolderValidationMessage: String {
        duplicateFolderNameMessage(
            for: trimmedFolderName,
            in: nil
        ) ?? "Enter a name for the folder."
    }

    @ViewBuilder
    private func searchPlaceholder(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
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

    // MARK: - Actions

    private func startAddingFolder() {
        newFolderName = ""
        isShowingAddFolderAlert = true
    }

    private var hasDuplicateRootFolderName: Bool {
        hasDuplicateFolderName(trimmedFolderName, in: nil)
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

    private func hasDuplicateFolderName(
        _ name: String,
        in parent: Folder?,
        excluding folder: Folder? = nil
    ) -> Bool {
        guard !name.isEmpty else { return false }

        return folders.contains { candidate in
            candidate.parent === parent
                && candidate !== folder
                && candidate.name.localizedCaseInsensitiveCompare(name) == .orderedSame
        }
    }

    private func addFolder() {
        guard !hasDuplicateRootFolderName else { return }

        let folder = Folder(name: trimmedFolderName)
        modelContext.insert(folder)

        do {
            try modelContext.save()
            newFolderName = ""
        } catch {
            print("Failed to save folder: \(error)")
        }
    }

    private func startEditing(_ folder: Folder) {
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

    private func resetFolderEditing() {
        folderBeingEdited = nil
        editedFolderName = ""
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Folder.self, FriendContact.self], inMemory: true)
}
