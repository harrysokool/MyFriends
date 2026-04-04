import SwiftUI

struct FolderDetailView: View {
    let folder: Folder

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text(folder.name)
                .font(.title2)
                .fontWeight(.semibold)

            Text("No contacts or subfolders yet")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FolderDetailView(folder: Folder(name: "Friends"))
    }
}
