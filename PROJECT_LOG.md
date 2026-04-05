# MyFriends – Project Log

## 1. Project Overview

MyFriends is an iOS app for organizing people through nested folders instead of a flat alphabetical phonebook.

The product direction is to treat contacts as relationship profiles grouped by real-life context such as family, work, school, projects, and communities.

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

1. Created the local iOS project and repository
2. Initialized Git and connected GitHub
3. Started from a SwiftUI + SwiftData app template
4. Configured simulator and local build workflow
5. Established a Codex-assisted development workflow in VS Code
6. Began shipping features in compile-verified increments

---

## 3. Development Workflow

Current workflow:

1. Define a focused feature or maintainability task
2. Implement locally through Codex-assisted development
3. Review the change and keep the solution simple
4. Verify using `xcodebuild` and Xcode
5. Record progress in project documentation

This workflow has been used for both feature delivery and targeted refactoring.

---

## 4. Major Features Implemented

### 4.1 Folder Hierarchy

- Root folder creation with SwiftData persistence
- Nested subfolders through a self-referential `Folder` relationship
- Folder rename support
- Folder delete support
- Recursive folder navigation
- Root list excludes nested folders

### 4.2 Rich Contact Profiles

- Contacts belong to a specific folder
- Contact create, edit, and delete flows are implemented
- Contact detail screen shows a richer profile layout
- Contact model supports:
  - name
  - phone number
  - email
  - Instagram
  - notes
  - favorite status
  - last interaction date
  - interaction note
  - created date

### 4.3 Favorites

- Added `isFavorite` support to `FriendContact`
- Contacts can be starred or unstarred from the contact detail screen
- Home screen shows a `Favorites` smart-folder row only when favorites exist
- Favorites are implemented as a smart folder, not a stored folder
- Added a dedicated `FavoritesView`

### 4.4 Search

- Global hierarchical search across all folders and contacts
- Search results include deeply nested items
- Results are grouped into:
  - Folders
  - Contacts
- Results show parent or full-path context where appropriate
- Search uses native SwiftUI searchable drawer placement

### 4.5 Contact Actions

- Phone numbers are tappable with call confirmation
- Instagram usernames are tappable
- Instagram opens in the app when available and falls back to the web
- Contacts can be moved between folders from the detail screen

### 4.6 Interaction Tracking

- Added `lastInteractedAt`
- Added `interactionNote`
- Contact detail screen displays interaction history when present
- Added a simple sheet to log or update an interaction date and note

### 4.7 Validation and UX Refinement

- Added country picker and dialing code handling for phone input
- Added practical phone number validation
- Added duplicate folder-name prevention within the same parent folder
- Duplicate validation applies to:
  - root folders
  - nested subfolders
  - folder renaming flows
- Kept duplicate-name feedback native through the existing alert UI

### 4.8 Product Polish

- Added an app icon
- Completed real-device testing
- Confirmed the app works as a functional MVP on hardware

---

## 5. Maintainability Refactors Completed

Recent cleanup work has focused on improving clarity without changing behavior.

### 5.1 Model and File Refactor

- Split SwiftData models into dedicated files:
  - `Folder.swift`
  - `FriendContact.swift`
- Removed the unused starter `Item` model
- Updated the schema to reflect the real app models

### 5.2 Shared Search Logic

- Extracted global search and path-based sorting into `SearchService`
- Removed duplicated search logic from major views

### 5.3 Reusable Contact Form

- Extracted shared contact create/edit fields into `ContactFormView`
- Added `ContactFormState` to centralize input state and validation
- Reused the same form in both create and edit flows

### 5.4 Shared Contact Persistence Mapping

- Extracted form-to-model mapping into `ContactPersistenceService`
- Removed duplicated contact mapping logic from multiple views

### 5.5 Folder Detail Modularization

- Extracted reusable folder-detail list sections and empty-state helpers
- `FolderDetailView` now acts more clearly as a coordinator
- Additional readability refactors reduced dense view code and improved helper naming

### 5.6 General Readability Improvements

- Added `MARK` organization in major views
- Extracted smaller sheet and section builders in large SwiftUI screens
- Improved naming clarity for local helpers and temporary values
- Preserved beginner-readable structure without introducing heavy patterns

---

## 6. Current App State

The app currently supports:

- Root folders
- Nested subfolders
- Folder rename and delete
- Duplicate folder-name prevention within the same parent folder
- Contacts within folders
- Contact create, edit, move, and delete
- Favorites smart folder
- Global search across the full hierarchy
- Rich contact detail screens
- Phone and Instagram actions
- Interaction tracking
- SwiftData-backed local persistence
- App icon and real-device validation

The project has moved beyond an early prototype and now functions as a portfolio-quality MVP.

---

## 7. Current Architecture Notes

- `Folder` uses a self-referential SwiftData relationship for nested hierarchy
- `FriendContact` belongs to a single folder
- Favorites are implemented as a smart-folder pattern, not a stored folder record
- Search is centralized through `SearchService`
- Contact form state and validation are handled through `ContactFormView` and `ContactFormState`
- Contact save/update mapping is centralized through `ContactPersistenceService`
- `FolderDetailView` has been partially modularized into smaller reusable components

---

## 8. Remaining High-Value Next Steps

The next meaningful improvements are:

1. Add stronger user-facing error handling instead of `print(...)`-only failures
2. Add tests for search, folder validation, and contact persistence logic
3. Continue reducing coordinator weight in the largest SwiftUI views
4. Add confirmation flows for destructive actions where helpful

These are higher-value next steps than large architecture changes at the current project size.

---

## 9. Verification

- Changes have been repeatedly verified with `xcodebuild`
- The app currently compiles successfully for the iOS simulator target
- Real-device testing has also been completed
- Recently verified areas include:
  - favorites
  - interaction tracking
  - contact move flow
  - model/file refactor
  - maintainability cleanup
  - duplicate folder validation
  - app icon integration

---
