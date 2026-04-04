import Foundation

struct SearchResults {
    let folders: [Folder]
    let contacts: [FriendContact]

    var isEmpty: Bool {
        folders.isEmpty && contacts.isEmpty
    }
}

enum SearchService {
    static func normalizedQuery(_ query: String) -> String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func search(
        query: String,
        folders: [Folder],
        contacts: [FriendContact]
    ) -> SearchResults {
        let normalizedQuery = normalizedQuery(query)

        guard !normalizedQuery.isEmpty else {
            return SearchResults(folders: [], contacts: [])
        }

        return SearchResults(
            folders: foldersMatching(normalizedQuery, in: folders),
            contacts: contactsMatching(normalizedQuery, in: contacts)
        )
    }

    static func foldersMatching(_ query: String, in folders: [Folder]) -> [Folder] {
        folders
            .filter { $0.name.localizedCaseInsensitiveContains(query) }
            .sorted { $0.fullPath.localizedCaseInsensitiveCompare($1.fullPath) == .orderedAscending }
    }

    static func contactsMatching(_ query: String, in contacts: [FriendContact]) -> [FriendContact] {
        contactsSortedByPath(
            contacts.filter { $0.name.localizedCaseInsensitiveContains(query) }
        )
    }

    static func contactsSortedByPath(_ contacts: [FriendContact]) -> [FriendContact] {
        contacts.sorted { lhs, rhs in
            let leftPath = lhs.folderPath ?? ""
            let rightPath = rhs.folderPath ?? ""

            if leftPath.caseInsensitiveCompare(rightPath) == .orderedSame {
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }

            return leftPath.localizedCaseInsensitiveCompare(rightPath) == .orderedAscending
        }
    }
}
