# MyFriends – Project Log

## 1. Project Overview

MyFriends is an iOS app that allows users to organize contacts using custom folders and nested groups instead of traditional alphabetical phonebooks.

### Core Idea
Users can:
- Create folders (e.g. School, Work, Gym)
- Nest folders inside folders
- Add contacts inside folders

---

## 2. Setup Process

### Tools Used
- Xcode (iOS development)
- Swift + SwiftUI
- SwiftData (local database)
- VS Code (AI coding environment)
- OpenAI Codex (code generation)
- Git + GitHub (version control)

### Setup Steps

1. Created local project folder
2. Initialized Git repository
3. Created GitHub repository and pushed initial commit
4. Installed Xcode
5. Installed iOS simulator components
6. Installed VS Code
7. Installed Codex extension
8. Created iOS app using:
   - SwiftUI
   - Swift
   - SwiftData
9. Ran first app successfully in simulator

---

## 3. Development Workflow

Workflow used for building the app:

1. Write feature prompt
2. Send to Codex
3. Review and apply changes
4. Run app in Xcode
5. Test feature
6. Commit only if working

---

## 4. Features Implemented

### 4.1 Initial UI Setup
- Clean empty state screen
- Navigation title: MyFriends
- "+" button added

---

### 4.2 Folder Creation
Prompt:
> Add folder creation using SwiftData with a plus button, alert input, and display folders in a list.

Result:
- Created Folder model
- Added folder creation via alert
- Displayed folders in list

---

### 4.3 Folder Detail Navigation
Prompt:
> Add navigation from the folder list to a folder detail screen.

Result:
- Created FolderDetailView
- Navigation from folder list to detail screen
- Placeholder UI for folder content

---

### 4.4 Nested Subfolders
Prompt:
> Add support for subfolders inside FolderDetailView.

Result:
- Folder model supports parent/child relationship
- Can create subfolders inside folders
- Recursive navigation works

---

### 4.5 Contacts Inside Folders
Prompt:
> Add support for contacts inside a folder.

Result:
- Created FriendContact model
- Contacts linked to folders
- Can create contacts inside folders
- Contacts display correctly

---

### 4.6 Contact Detail Screen
Prompt:
> Add navigation from contacts to a contact detail screen.

Result:
- Created ContactDetailView
- Navigation from contact list
- Displays contact name and phone number

---

## 5. Git Strategy

- Commit only after working features
- Avoid committing broken code
- Use clear commit messages:
  - "Add folder creation with SwiftData"
  - "Add nested subfolders"
  - "Add contacts inside folders"

---

## 6. Key Learnings

- AI is powerful but requires clear prompts
- Small incremental features work best
- Always test after each change
- Git is essential for safe iteration
- Xcode is used for running, not writing code
- VS Code + Codex is used for development

---

## 7. Current App State

The app currently supports:
- Folder creation
- Nested folders
- Adding contacts to folders
- Viewing contact details

---

## 8. Next Steps

Planned features:
- Edit and delete folders
- Edit and delete contacts
- Better UI (sections, icons, spacing)
- Search functionality
- Possibly notes or tags for contacts

---