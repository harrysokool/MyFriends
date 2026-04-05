//
//  MyFriendsApp.swift
//  MyFriends
//
//  Created by harrysocool on 2026-04-04.
//

import SwiftUI
import SwiftData

@main
struct MyFriendsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Folder.self,
            FriendContact.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
