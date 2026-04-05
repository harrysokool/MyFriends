# MyFriends

## Project Overview

MyFriends is a SwiftUI + SwiftData iOS app for organizing personal relationships through nested folders instead of a traditional flat contacts list. Rather than treating every person as an entry in a single phonebook, the app lets users structure contacts around real-life context such as family, work, school, projects, and communities.

The project is built as a local-first iOS app with a simple native interface, pragmatic architecture, and enough polish to function as both a usable MVP and a portfolio-quality SwiftUI project.

## Features

- Nested folder hierarchy with root folders and subfolders
- Folder rename and delete support
- Duplicate folder-name prevention within the same parent folder
- Rich contact profiles with:
  - name
  - phone number
  - email
  - Instagram
  - notes
- Favorites smart folder
- Global search across folders and contacts
- Full-path search result context for nested items
- Move contact to another folder
- Interaction tracking with last interaction date and interaction note
- Tap-to-call action from contact detail
- Instagram profile open action with app-first behavior and web fallback
- Clean sectioned folder, detail, and search UI
- Local persistence with SwiftData
- App icon added and tested on a real device

## Tech Stack

- Swift
- SwiftUI
- SwiftData
- Xcode
- Git + GitHub
- VS Code + OpenAI Codex

## Architecture

The app is intentionally lightweight and avoids unnecessary patterns for an MVP of this size.

- `Folder`: SwiftData model for the hierarchy. A folder can have a parent folder, child folders, and many contacts.
- `FriendContact`: SwiftData model for a contact profile stored inside a folder.
- `ContentView`: Root screen for top-level folders, favorites entry point, and global search.
- `FolderDetailView`: Coordinator for subfolders, contacts, local list presentation, and folder-level actions.
- `FolderDetailComponents`: Extracted reusable list sections and empty-state helpers for folder detail UI.
- `ContactDetailView`: Contact profile, favorite toggle, interaction logging, move flow, and external actions.
- `ContactFormView`: Shared create/edit contact form and input state handling.
- `SearchService`: Centralized global search and path-based sorting logic.
- `ContactPersistenceService`: Shared mapping between form state and `FriendContact`.

Current model files are split cleanly into:

- `Folder.swift`
- `FriendContact.swift`

This structure keeps the codebase beginner-readable while still separating the core model, view, and helper responsibilities.

## Development Workflow

Development follows a small-batch, compile-verified workflow:

1. Define a focused feature or refactor task.
2. Implement locally through Codex-assisted development.
3. Keep changes small and behavior-preserving where possible.
4. Verify with `xcodebuild` and Xcode.
5. Update project documentation as milestones are completed.

This workflow is used to ship features and improve maintainability without losing momentum or introducing unnecessary architectural complexity.

## Current Status

MyFriends is currently a functional MVP with a polished core experience:

- Nested folder-based contact organization
- Rich contact detail screens and actions
- Favorites smart folder
- Global search across the full hierarchy
- Contact move flow between folders
- Interaction tracking
- Duplicate folder validation within sibling folders
- Real-device testing completed
- App icon in place

The codebase has also gone through meaningful cleanup work, including model/file separation, shared search logic, extracted reusable contact form handling, and centralized contact persistence mapping.

## Future Improvements

- Add stronger user-facing persistence error handling
- Add unit tests for search, folder validation, and contact mapping
- Continue reducing coordinator weight in large SwiftUI views
- Add confirmation flows for destructive actions where helpful
- Explore lightweight reminders, tags, or relationship insights

## Purpose

MyFriends is being developed as a serious portfolio project that demonstrates:

- SwiftUI interface design with native iOS patterns
- SwiftData modeling for hierarchical local data
- Product thinking beyond a standard CRUD phonebook
- Incremental refactoring for clarity and maintainability
- Practical AI-assisted development with local verification

## Author

Built by Harry So Cool with Swift, SwiftUI, SwiftData, and OpenAI Codex-assisted development.
