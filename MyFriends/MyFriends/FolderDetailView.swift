import SwiftUI
import SwiftData

struct FolderDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let folder: Folder

    @State private var isShowingAddSubfolderAlert = false
    @State private var newSubfolderName = ""

    private var subfolders: [Folder] {
        folder.childFolders.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        Group {
            if subfolders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)

                    Text(folder.name)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("No contacts or subfolders yet")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List(subfolders) { subfolder in
                    NavigationLink {
                        FolderDetailView(folder: subfolder)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "folder.fill")
                                .foregroundStyle(.blue)

                            Text(subfolder.name)
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    newSubfolderName = ""
                    isShowingAddSubfolderAlert = true
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
    }

    private var trimmedSubfolderName: String {
        newSubfolderName.trimmingCharacters(in: .whitespacesAndNewlines)
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
}

#Preview {
    NavigationStack {
        FolderDetailView(folder: Folder(name: "Friends"))
    }
}
