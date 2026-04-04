# MyFriends

## Project Overview

MyFriends is an iOS application for organizing personal relationships through custom folders and nested groups rather than a traditional alphabetical contact list. Instead of forcing every person into a flat phonebook, the app lets users structure contacts around real-life context such as family, school, work, projects, communities, and social circles.

The project is designed as a local-first SwiftUI application with SwiftData-backed persistence, a simple native interface, and an architecture that supports iterative feature growth without losing clarity.

## Features

- Create and rename top-level folders
- Create nested subfolders inside any folder
- Add, edit, and delete contacts inside folders
- Navigate through a hierarchical folder structure
- View detailed contact profiles
- Mark contacts as favorites with a smart-folder style Favorites view
- Search globally across all folders and contacts in the hierarchy
- Show full hierarchy paths for global search results
- Store richer contact information including phone number, email, Instagram, notes, and interaction history
- Log the last interaction date and an interaction note for a contact
- Open phone numbers in the Phone app with confirmation
- Open Instagram profiles in the Instagram app with Safari fallback
- Validate phone number input with country and dialing code support
- Persist all data locally using SwiftData

## Tech Stack

- Swift
- SwiftUI
- SwiftData
- Xcode
- VS Code + OpenAI Codex
- Git + GitHub

## Architecture

MyFriends is built around two primary SwiftData models:

- `Folder`: Represents a node in the hierarchy. A folder can have a parent folder, child folders, and many contacts.
- `FriendContact`: Represents an individual relationship profile stored in a folder, including core contact info, optional metadata, favorite state, and interaction tracking.

At a high level, the app is organized into:

- Model layer: SwiftData models and derived helpers for hierarchy and display-friendly values
- View layer: SwiftUI screens for home, folder detail, contact detail, and favorites
- Shared helpers: Search, contact form state, and contact persistence mapping extracted to reduce duplication

This keeps the app lightweight while still supporting nested navigation, smart-folder behavior, and progressive refactoring toward better maintainability.

## Development Workflow

Development uses a structured AI-assisted workflow combining VS Code, OpenAI Codex, Xcode, and Git-based iteration.

Typical workflow:

1. Define a focused product or refactor task
2. Implement the change through Codex-assisted development in the local codebase
3. Review the result and tighten structure or behavior where needed
4. Validate with `xcodebuild` and Xcode
5. Record progress and continue in small, compile-verified increments

The AI workflow is used as an engineering accelerator, not a replacement for review or technical judgment. Changes are scoped deliberately and validated locally before being treated as complete.

## Project Structure

```text
MyFriends/
├── MyFriends/
│   ├── ContentView.swift
│   ├── FolderDetailView.swift
│   ├── FolderDetailComponents.swift
│   ├── FavoritesView.swift
│   ├── ContactDetailView.swift
│   ├── ContactFormView.swift
│   ├── ContactPersistenceService.swift
│   ├── SearchService.swift
│   ├── SearchResultRowViews.swift
│   ├── PhoneCountry.swift
│   ├── Item.swift
│   └── MyFriendsApp.swift
├── PROJECT_LOG.md
└── README.md
```

Key files:

- `ContentView.swift`: Home screen, root folders, favorites entry point, and global search
- `FolderDetailView.swift`: Folder-level coordination for subfolders, contacts, search, and editing flows
- `FolderDetailComponents.swift`: Extracted folder detail list sections and empty state UI
- `FavoritesView.swift`: Smart folder view for favorited contacts
- `ContactDetailView.swift`: Contact profile, favorite toggle, actions, and interaction logging
- `ContactFormView.swift`: Reusable create/edit contact form and form state
- `ContactPersistenceService.swift`: Shared mapping from form state into `FriendContact`
- `SearchService.swift`: Centralized global search and path-based sorting
- `Item.swift`: SwiftData models including `Folder` and `FriendContact`
- `PhoneCountry.swift`: Country/dialing code data and phone number validation helpers

## Current Status

The app is functional as a local-first relationship organizer with:

- Hierarchical folders and subfolders
- Contact creation, editing, and deletion
- Global search across the full folder tree
- Favorites as a smart folder
- Richer contact profiles with notes, Instagram, and interaction tracking
- Native-style contact actions for phone and Instagram
- Ongoing maintainability improvements through targeted refactors

The project has moved beyond a basic prototype and now demonstrates both product functionality and incremental architectural cleanup.

## Future Improvements

- Extract more business logic out of large view coordinators
- Add stronger user-facing error handling for persistence failures
- Add tests for search, contact mapping, and interaction behavior
- Remove or replace the leftover starter `Item` model if no longer needed
- Add confirmation flows for destructive actions where appropriate
- Explore tags, reminders, or lightweight relationship insights

## Purpose

MyFriends is being built as a portfolio-grade iOS project that demonstrates:

- SwiftUI interface design with native interaction patterns
- SwiftData modeling for hierarchical local data
- Relationship-focused product thinking beyond a standard CRUD contacts app
- Incremental refactoring to improve maintainability as scope grows
- Professional use of AI-assisted software development in a real project workflow

## Author

Built by Harry So Cool with Swift, SwiftUI, SwiftData, and OpenAI Codex-assisted development.
