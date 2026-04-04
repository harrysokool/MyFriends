import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.createdAt) private var folders: [Folder]

    @State private var isShowingAddFolderAlert = false
    @State private var isShowingEditFolderAlert = false
    @State private var newFolderName = ""
    @State private var editedFolderName = ""
    @State private var folderBeingEdited: Folder?

    private var rootFolders: [Folder] {
        folders
            .filter { $0.parent == nil }
            .sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            Group {
                if rootFolders.isEmpty {
                    ContentUnavailableView(
                        "No Folders Yet",
                        systemImage: "folder",
                        description: Text("Tap the + button to create your first folder.")
                    )
                } else {
                    List {
                        ForEach(rootFolders) { folder in
                            NavigationLink {
                                FolderDetailView(folder: folder)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "folder.fill")
                                        .foregroundStyle(.blue)

                                    Text(folder.name)
                                        .font(.body)
                                }
                                .padding(.vertical, 4)
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
        }
    }

    private var trimmedFolderName: String {
        newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
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
