import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FriendContact.createdAt) private var contacts: [FriendContact]

    private var favoriteContacts: [FriendContact] {
        SearchService.contactsSortedByPath(
            contacts.filter { $0.resolvedIsFavorite }
        )
    }

    var body: some View {
        Group {
            if favoriteContacts.isEmpty {
                ContentUnavailableView(
                    "No Favorites Yet",
                    systemImage: "star",
                    description: Text("Star a contact to see it here.")
                )
            } else {
                List {
                    ForEach(favoriteContacts) { contact in
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
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
            .modelContainer(for: [Folder.self, FriendContact.self], inMemory: true)
    }
}
