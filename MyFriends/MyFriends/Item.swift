//
//  Item.swift
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
}

@Model
final class FriendContact {
    var name: String
    var phoneNumber: String
    var createdAt: Date
    var folder: Folder?

    init(
        name: String,
        phoneNumber: String,
        createdAt: Date = .now,
        folder: Folder? = nil
    ) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
        self.folder = folder
    }
}

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
