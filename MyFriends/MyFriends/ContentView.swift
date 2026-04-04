import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.createdAt) private var folders: [Folder]
    @Query(sort: \FriendContact.createdAt) private var contacts: [FriendContact]

    @State private var isShowingAddFolderAlert = false
    @State private var isShowingEditFolderAlert = false
    @State private var newFolderName = ""
    @State private var editedFolderName = ""
    @State private var searchText = ""
    @State private var folderBeingEdited: Folder?

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
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool {
        !normalizedSearchText.isEmpty
    }

    private var matchingFolders: [Folder] {
        guard isSearching else { return [] }

        return folders
            .filter { $0.name.localizedCaseInsensitiveContains(normalizedSearchText) }
            .sorted { $0.fullPath.localizedCaseInsensitiveCompare($1.fullPath) == .orderedAscending }
    }

    private var matchingContacts: [FriendContact] {
        guard isSearching else { return [] }

        return contacts
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

    private var favoriteContacts: [FriendContact] {
        contacts
            .filter { $0.resolvedIsFavorite }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isSearching {
                    searchResultsList
                } else if rootFolders.isEmpty {
                    ContentUnavailableView(
                        "No Folders Yet",
                        systemImage: "folder",
                        description: Text("Tap the + button to create your first folder.")
                    )
                } else {
                    List {
                        if !favoriteContacts.isEmpty {
                            NavigationLink {
                                FavoritesView()
                            } label: {
                                FavoritesRowView(count: favoriteContacts.count)
                            }
                        }

                        ForEach(filteredFolders) { folder in
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
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("MyFriends")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        newFolderName = ""
                        isShowingAddFolderAlert = true
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
                .disabled(trimmedFolderName.isEmpty)
            } message: {
                Text("Enter a name for the folder.")
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
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search folders and contacts"
            )
        }
    }

    @ViewBuilder
    private var searchResultsList: some View {
        if matchingFolders.isEmpty && matchingContacts.isEmpty {
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

    private var trimmedFolderName: String {
        newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
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

    private func addFolder() {
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
