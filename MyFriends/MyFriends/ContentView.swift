import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.createdAt) private var folders: [Folder]

    @State private var isShowingAddFolderAlert = false
    @State private var newFolderName = ""

    var body: some View {
        NavigationStack {
            Group {
                if folders.isEmpty {
                    ContentUnavailableView(
                        "No Folders Yet",
                        systemImage: "folder",
                        description: Text("Tap the + button to create your first folder.")
                    )
                } else {
                    List(folders) { folder in
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
        }
    }

    private var trimmedFolderName: String {
        newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
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
}

#Preview {
    ContentView()
        .modelContainer(for: Folder.self, inMemory: true)
}
