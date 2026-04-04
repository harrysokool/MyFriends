import SwiftUI

struct ContactDetailView: View {
    let contact: FriendContact

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text(contact.name)
                .font(.title2)
                .fontWeight(.semibold)

            Text(contact.phoneNumber)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ContactDetailView(contact: FriendContact(name: "Alex", phoneNumber: "555-123-4567"))
    }
}
