import Foundation

struct SearchResults {
    let folders: [Folder]
    let contacts: [FriendContact]

    var isEmpty: Bool {
        folders.isEmpty && contacts.isEmpty
    }
}

enum SearchService {
    // Trimming once keeps matching rules consistent across screens.
    static func normalizedQuery(_ query: String) -> String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func search(
        query: String,
        folders: [Folder],
        contacts: [FriendContact]
    ) -> SearchResults {
        let trimmedQuery = normalizedQuery(query)

        guard !trimmedQuery.isEmpty else {
            return SearchResults(folders: [], contacts: [])
        }

        return SearchResults(
            folders: foldersMatching(trimmedQuery, in: folders),
            contacts: contactsMatching(trimmedQuery, in: contacts)
        )
    }

    static func foldersMatching(_ query: String, in folders: [Folder]) -> [Folder] {
        folders
            .filter { $0.name.localizedCaseInsensitiveContains(query) }
            .sorted(by: areFoldersInAscendingPathOrder)
    }

    static func contactsMatching(_ query: String, in contacts: [FriendContact]) -> [FriendContact] {
        contactsSortedByPath(
            contacts.filter { $0.name.localizedCaseInsensitiveContains(query) }
        )
    }

    static func contactsSortedByPath(_ contacts: [FriendContact]) -> [FriendContact] {
        contacts.sorted(by: areContactsInAscendingFolderOrder)
    }

    nonisolated private static func areFoldersInAscendingPathOrder(_ lhs: Folder, _ rhs: Folder) -> Bool {
        lhs.fullPath.localizedCaseInsensitiveCompare(rhs.fullPath) == .orderedAscending
    }

    nonisolated private static func areContactsInAscendingFolderOrder(_ lhs: FriendContact, _ rhs: FriendContact) -> Bool {
        let leftFolderPath = lhs.folderPath ?? ""
        let rightFolderPath = rhs.folderPath ?? ""

        if leftFolderPath.caseInsensitiveCompare(rightFolderPath) == .orderedSame {
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }

        return leftFolderPath.localizedCaseInsensitiveCompare(rightFolderPath) == .orderedAscending
    }
}
