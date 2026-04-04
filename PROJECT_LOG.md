# MyFriends – Project Log

## 1. Project Overview

MyFriends is an iOS app for organizing people through custom folders and nested groups instead of a flat alphabetical phonebook.

### Core Product Direction

Users can:

- Create folders such as `School`, `Work`, `Family`, or `Projects`
- Nest folders inside other folders
- Store contacts inside specific folders
- Treat contacts more like relationship profiles than basic address book entries

---

## 2. Setup Process

### Tools Used

- Xcode
- Swift + SwiftUI
- SwiftData
- VS Code
- OpenAI Codex
- Git + GitHub

### Setup Steps

1. Created the local project and repository
2. Initialized Git and connected GitHub
3. Created the iOS app using SwiftUI + SwiftData
4. Configured Xcode and simulator support
5. Established a Codex-assisted workflow in VS Code
6. Began iterative feature delivery with compile verification

---

## 3. Development Workflow

Current workflow:

1. Define a focused feature or cleanup goal
2. Implement through Codex-assisted local development
3. Review the result and refine structure where needed
4. Verify with `xcodebuild` and Xcode
5. Update documentation and continue incrementally

This workflow has been used for both feature delivery and maintainability-oriented refactors.

---

## 4. Major Features Implemented

### 4.1 Folder Hierarchy

- Root folder creation with SwiftData persistence
- Folder rename support
- Nested subfolders through a self-referential `Folder` relationship
- Recursive folder navigation
- Root list excludes nested folders

### 4.2 Contacts

- Contacts belong to a specific folder
- Contact create, edit, and delete flows are implemented
- Contact detail screen shows a richer profile layout
- Contact model supports:
  - name
  - phone number
  - email
  - Instagram
  - notes
  - created date

### 4.3 Favorites

- Added `isFavorite` support to `FriendContact`
- Contacts can be starred or unstarred from the contact detail screen
- Home screen shows a `Favorites` smart-folder row only when favorites exist
- Favorites are not stored as real folders
- Added a dedicated `FavoritesView`

### 4.4 Search

- Global hierarchical search across all folders and contacts
- Search results include deeply nested items
- Results are grouped into:
  - Folders
  - Contacts
- Results display full hierarchy paths where appropriate
- Search uses native SwiftUI searchable drawer placement

### 4.5 Contact Actions

- Phone numbers are tappable with call confirmation
- Instagram usernames are tappable
- Instagram opens in the app when available, then falls back to Safari

### 4.6 Phone Number Improvements

- Added country picker and dialing code handling
- Added practical phone number validation
- Supports common formatting characters
- Rejects invalid input before save
- Stores phone numbers in a normalized form
- Migration issue from required phone metadata fields was fixed by making added fields migration-safe

### 4.7 Interaction Tracking

- Added `lastInteractedAt`
- Added `interactionNote`
- Contact detail screen displays interaction history when present
- Added a simple sheet to log or update an interaction date and note

---

## 5. Maintainability Refactors Completed

Recent cleanup work has focused on reducing duplication and improving structure without changing product behavior.

### 5.1 Shared Search Logic

- Extracted global search and path-based sorting into `SearchService`
- Removed duplicated search logic from:
  - `ContentView`
  - `FolderDetailView`
  - `FavoritesView`

### 5.2 Reusable Contact Form

- Extracted shared contact create/edit fields into `ContactFormView`
- Added `ContactFormState` to centralize input state and validation
- Reused the same form in both create and edit flows

### 5.3 Folder Detail Component Split

- Extracted:
  - subfolder section view
  - contact section view
  - empty state row view
- `FolderDetailView` now acts more clearly as a coordinator

### 5.4 Shared Contact Persistence Mapping

- Extracted form-to-model mapping into `ContactPersistenceService`
- Removed duplicated contact mapping logic from:
  - `FolderDetailView`
  - `ContactDetailView`

---

## 6. Current App State

The app currently supports:

- Root folders
- Nested subfolders
- Contacts within folders
- Folder rename and delete
- Contact edit and delete
- Favorites smart folder
- Global search across the full hierarchy
- Contact detail navigation
- Phone and Instagram actions
- Interaction tracking
- SwiftData-backed persistence for all implemented data
- Native empty states and sectioned list presentation

The app is now both more feature-complete and more maintainable than the initial implementation.

---

## 7. Remaining High-Value Cleanup Areas

Based on the latest maintainability review, the next important cleanup opportunities are:

1. Reduce the remaining coordinator weight inside `FolderDetailView`
2. Improve model and file organization, especially around `Item.swift`
3. Add stronger user-facing error handling instead of `print(...)`-only failures

These are important because they will affect future feature work more than UI polish tasks.

---

## 8. Implementation Notes

- `Folder` uses a self-referential SwiftData relationship for nested hierarchy
- `FriendContact` belongs to a single folder
- Favorites are implemented as a smart-folder pattern, not a stored folder record
- Search is centralized through `SearchService`
- Contact form state and validation are centralized through `ContactFormView` and `ContactFormState`
- Contact save/update mapping is centralized through `ContactPersistenceService`
- `ContactDetailView` now handles:
  - favorite toggling
  - contact editing
  - phone action
  - Instagram action
  - interaction logging

---

## 9. Verification

- Changes have been repeatedly verified with `xcodebuild`
- The current project compiles successfully for the iOS simulator build target
- Recent verified areas include:
  - search refactor
  - reusable contact form refactor
  - folder detail view component split
  - shared contact persistence logic
  - interaction tracking

---
