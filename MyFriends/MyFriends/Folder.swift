//
//  Folder.swift
//  MyFriends
//
//  Created by harrysocool on 2026-04-04.
//

import Foundation
import SwiftData

@Model
final class Folder {
    var name: String
    var createdAt: Date
    var parent: Folder?

    @Relationship(deleteRule: .cascade, inverse: \Folder.parent)
    var childFolders: [Folder] = []

    @Relationship(deleteRule: .cascade, inverse: \FriendContact.folder)
    var contacts: [FriendContact] = []

    init(name: String, createdAt: Date = .now, parent: Folder? = nil) {
        self.name = name
        self.createdAt = createdAt
        self.parent = parent
    }

    var pathComponents: [String] {
        var components: [String] = [name]
        var currentParent = parent

        while let folder = currentParent {
            components.insert(folder.name, at: 0)
            currentParent = folder.parent
        }

        return components
    }

    var fullPath: String {
        pathComponents.joined(separator: " / ")
    }

    var parentPath: String? {
        let components = pathComponents.dropLast()
        return components.isEmpty ? nil : components.joined(separator: " / ")
    }
}
