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
- Added folder creation via alert with text field
- Saved folders with SwiftData
- Displayed root folders in a clean list

---

### 4.3 Folder Detail Navigation
Prompt:
> Add navigation from the folder list to a folder detail screen.

Result:
- Created FolderDetailView
- Navigation from folder list to detail screen
- Folder name shown as navigation title
- Placeholder UI for folder content

---

### 4.4 Nested Subfolders
Prompt:
> Add support for subfolders inside FolderDetailView.

Result:
- Folder model supports parent/child relationship
- Can create subfolders inside folders
- Subfolders are saved with SwiftData
- Recursive navigation works
- Root folder list excludes nested subfolders

---

### 4.5 Contacts Inside Folders
Prompt:
> Add support for contacts inside a folder.

Result:
- Created FriendContact model
- Contacts linked to folders
- Contacts store name, phone number, and createdAt
- Can create contacts inside folders using a sheet
- Folder detail screen shows subfolders and contacts in separate sections

---

### 4.6 Contact Detail Screen
Prompt:
> Add navigation from contacts to a contact detail screen.

Result:
- Created ContactDetailView
- Navigation from contact list
- Displays contact name and phone number
- Uses contact name as the navigation title

---

### 4.7 Editing and Deletion
Prompt:
> Add support for deleting and editing folders and contacts.

Result:
- Added swipe-to-delete for root folders
- Added swipe-to-delete for subfolders
- Added swipe-to-delete for contacts
- Added simple folder renaming via alert
- Added simple contact editing via sheet
- Folder deletion cascades through nested contents using SwiftData relationships

---

### 4.8 Search
Prompt:
> Add search functionality to the MyFriends app.

Result:
- Added live folder search on the main screen
- Added live subfolder and contact search in FolderDetailView
- Search updates as the user types
- Empty search shows the normal full list

---

### 4.9 Native Search Bar Placement
Prompt:
> Fix the search bar placement to match native iOS behavior.

Result:
- Updated both screens to use SwiftUI `searchable` with `navigationBarDrawer`
- Search bars are hidden initially
- Search bars appear when the user pulls down, matching native iOS behavior

---

### 4.10 List UI Polish
Prompt:
> Improve the UI of folder and contact lists to make the app feel more polished.

Result:
- Added clearer folder and contact icons
- Improved spacing and alignment in list rows
- Made folder rows and contact rows visually distinct
- Kept styling subtle and consistent with iOS conventions

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
- Editing folders
- Editing contacts
- Deleting folders, subfolders, and contacts
- Search on root folders
- Search inside folders for subfolders and contacts
- Native pull-down search bar placement
- SwiftData persistence for folders, subfolders, and contacts
- Empty states when a folder has no subfolders or contacts
- Sectioned folder detail UI with add actions for subfolders and contacts
- More polished folder and contact list rows with clearer visual distinction

---

## 8. Next Steps

Planned features:
- Possibly notes or tags for contacts
- Validation and formatting for phone numbers
- Move `Item` starter model cleanup if no longer needed
- Confirmation dialogs for destructive folder deletion
- Additional detail fields for contacts
- Broader testing coverage

---

## 9. Implementation Notes

- `Folder` uses a self-referential SwiftData relationship for nested subfolders
- `FriendContact` belongs to a single folder through SwiftData relationships
- `ContentView` shows only root folders
- `ContentView` supports folder search and swipe edit/delete
- `FolderDetailView` supports:
  - Viewing subfolders
  - Viewing contacts
  - Creating subfolders via alert
  - Creating contacts via sheet
  - Searching subfolders and contacts
  - Editing and deleting subfolders
  - Editing and deleting contacts
- `ContactDetailView` supports viewing and editing a contact
- Search uses in-memory filtering with SwiftUI `searchable`
- Folder and contact deletion is persisted through SwiftData and reflected immediately in the UI

---

## 10. Verification

- Repeatedly verified changes using `xcodebuild`
- Current implemented features compile successfully in the iOS simulator build target
- Latest verified areas include editing, deletion, search, native search placement, and row UI polish

---
