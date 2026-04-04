# MyFriends

## Project Overview

MyFriends is an iOS application for organizing personal contacts with custom folders and nested groups instead of a traditional alphabetical phonebook. The app is designed around a user-defined hierarchy, allowing contacts to be grouped by context such as family, work, school, projects, or communities.

The current implementation focuses on a clean SwiftUI interface, local-first persistence with SwiftData, and a modular structure that supports incremental feature growth.

## Features

- Create top-level folders to organize contacts by category
- Create nested subfolders inside any folder
- Add contacts to a specific folder
- View subfolders and contacts in a structured folder detail screen
- Navigate to dedicated detail screens for folders and contacts
- Persist folders, subfolders, and contacts locally using SwiftData
- Show clear empty states when a folder has no content

## Tech Stack

- Swift
- SwiftUI
- SwiftData
- Xcode
- VS Code + OpenAI Codex
- Git + GitHub

## Architecture

MyFriends uses a lightweight, model-driven architecture centered on two SwiftData models:

- `Folder`: Represents a container for organization. A folder can have a parent folder, child folders, and many contacts.
- `FriendContact`: Represents an individual contact stored inside a specific folder, including name, phone number, and creation timestamp.

At the UI layer, SwiftUI views map directly to the core navigation flow:

- `ContentView` displays root folders
- `FolderDetailView` displays nested subfolders and contacts for a selected folder
- `ContactDetailView` displays a single contact

This structure keeps the app simple while supporting hierarchical navigation and future expansion.

## Development Workflow

Development is performed through an AI-assisted workflow that combines local engineering tools with iterative implementation and review. Feature work is scoped into small, testable increments, implemented in VS Code with OpenAI Codex assistance, then validated in Xcode.

Typical workflow:

1. Define a focused feature or UI requirement
2. Implement the change with Codex-assisted development
3. Review generated code and integrate refinements
4. Build and verify the app with `xcodebuild` and Xcode
5. Track progress through Git and GitHub

This approach emphasizes speed, traceability, and disciplined iteration rather than ad hoc code generation.

## Project Structure

```text
MyFriends/
├── MyFriends/
│   ├── ContentView.swift
│   ├── FolderDetailView.swift
│   ├── ContactDetailView.swift
│   ├── Item.swift
│   └── MyFriendsApp.swift
├── PROJECT_LOG.md
└── README.md
```

Key files:

- `ContentView.swift`: Root folder list and folder creation flow
- `FolderDetailView.swift`: Subfolder and contact listing, plus add actions
- `ContactDetailView.swift`: Read-only contact detail screen
- `Item.swift`: SwiftData models including `Folder` and `FriendContact`
- `MyFriendsApp.swift`: App entry point and SwiftData model container setup

## Current Status

The project currently supports the core navigation and data model required for hierarchical contact organization:

- Root folder creation
- Nested subfolder creation
- Contact creation within folders
- Folder and contact detail navigation
- Local persistence with SwiftData

The application is functional as an early-stage product foundation and is being developed incrementally with compile-verified changes.

## Future Improvements

- Edit and delete support for folders and contacts
- Search across folders and contacts
- Input validation and phone number formatting
- Improved visual polish and list interactions
- Additional contact metadata such as notes, tags, or profile details
- Broader test coverage and stronger model-level validation

## Purpose

This project is being built as a serious portfolio-grade iOS application that demonstrates:

- SwiftUI interface design
- SwiftData modeling and persistence
- Hierarchical navigation patterns
- iterative product development with clear architectural boundaries
- professional use of AI-assisted software development workflows

## Author

Built by Harry So Cool with Swift, SwiftUI, and OpenAI Codex-assisted development.
