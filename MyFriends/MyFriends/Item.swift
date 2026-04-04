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

    init(name: String, createdAt: Date = .now) {
        self.name = name
        self.createdAt = createdAt
    }
}

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
