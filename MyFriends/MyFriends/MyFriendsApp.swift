//
//  MyFriendsApp.swift
//  MyFriends
//
//  Created by harrysocool on 2026-04-04.
//

import SwiftUI
import SwiftData

// This is the starting point of the app
@main
struct MyFriendsApp: App {
    // creating a database for this app
    var sharedModelContainer: ModelContainer = {
        // database schema
        let schema = Schema([
            Folder.self,
            FriendContact.self,
        ])

        // database config
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // render the home page and attatching the database to the app
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
