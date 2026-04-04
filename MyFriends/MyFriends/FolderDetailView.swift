import SwiftUI
import SwiftData

struct FolderDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let folder: Folder

    @State private var isShowingAddSubfolderAlert = false
    @State private var isShowingAddContactSheet = false
    @State private var newSubfolderName = ""
    @State private var newContactName = ""
    @State private var newContactPhoneNumber = ""

    private var subfolders: [Folder] {
        folder.childFolders.sorted { $0.createdAt < $1.createdAt }
    }

    private var contacts: [FriendContact] {
        folder.contacts.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        Group {
            if subfolders.isEmpty && contacts.isEmpty {
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
                List {
                    if !subfolders.isEmpty {
                        Section("Subfolders") {
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
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }

                    if !contacts.isEmpty {
                        Section("Contacts") {
                            ForEach(contacts) { contact in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(contact.name)
                                        .font(.body)
                                        .fontWeight(.medium)

                                    Text(contact.phoneNumber)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("New Subfolder", systemImage: "folder.badge.plus") {
                        newSubfolderName = ""
                        isShowingAddSubfolderAlert = true
                    }

                    Button("New Contact", systemImage: "person.badge.plus") {
                        newContactName = ""
                        newContactPhoneNumber = ""
                        isShowingAddContactSheet = true
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
        .sheet(isPresented: $isShowingAddContactSheet) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Name", text: $newContactName)
                        TextField("Phone Number", text: $newContactPhoneNumber)
                            .keyboardType(.phonePad)
                    }
                }
                .navigationTitle("New Contact")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            resetContactFields()
                            isShowingAddContactSheet = false
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            addContact()
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

    private var trimmedContactName: String {
        newContactName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedPhoneNumber: String {
        newContactPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
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

    private func addContact() {
        let contact = FriendContact(
            name: trimmedContactName,
            phoneNumber: trimmedPhoneNumber,
            folder: folder
        )
        modelContext.insert(contact)

        do {
            try modelContext.save()
            resetContactFields()
            isShowingAddContactSheet = false
        } catch {
            print("Failed to save contact: \(error)")
        }
    }

    private func resetContactFields() {
        newContactName = ""
        newContactPhoneNumber = ""
    }
}

#Preview {
    NavigationStack {
        FolderDetailView(folder: Folder(name: "Friends"))
    }
    .modelContainer(for: [Folder.self, FriendContact.self], inMemory: true)
}
