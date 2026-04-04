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

    init(name: String, createdAt: Date = .now, parent: Folder? = nil) {
        self.name = name
        self.createdAt = createdAt
        self.parent = parent
    }
}

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
