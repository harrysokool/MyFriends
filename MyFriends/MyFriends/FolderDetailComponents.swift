import SwiftUI

struct FolderDetailEmptyStateView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
    }
}

struct SubfolderListSectionView: View {
    let subfolders: [Folder]
    let placeholderText: String
    let onEdit: (Folder) -> Void
    let onDelete: (Folder) -> Void

    var body: some View {
        Section("Subfolders") {
            if subfolders.isEmpty {
                FolderDetailEmptyStateView(text: placeholderText)
            } else {
                ForEach(subfolders) { subfolder in
                    NavigationLink {
                        FolderDetailView(folder: subfolder)
                    } label: {
                        FolderRowView(name: subfolder.name, subtitle: "Subfolder")
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            onDelete(subfolder)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            onEdit(subfolder)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
    }
}

struct ContactListSectionView: View {
    let title: String
    let contacts: [FriendContact]
    let placeholderText: String
    let subtitle: (FriendContact) -> String
    let onEdit: (FriendContact) -> Void
    let onDelete: (FriendContact) -> Void

    var body: some View {
        Section(title) {
            if contacts.isEmpty {
                FolderDetailEmptyStateView(text: placeholderText)
            } else {
                ForEach(contacts) { contact in
                    NavigationLink {
                        ContactDetailView(contact: contact)
                    } label: {
                        ContactRowView(name: contact.name, subtitle: subtitle(contact))
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            onDelete(contact)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            onEdit(contact)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
    }
}
