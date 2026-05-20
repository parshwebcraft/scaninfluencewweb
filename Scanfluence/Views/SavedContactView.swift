import SwiftUI

struct SavedContactView: View {
    let contact: ContactProfile

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(.white.opacity(0.22))
                .frame(width: 38, height: 5)
                .padding(.top, 10)

            ProfileAvatarView(initials: contact.initials, size: 86)

            VStack(spacing: 7) {
                Text(contact.name)
                    .font(.title2.weight(.semibold))
                Text("\(contact.designation) at \(contact.company)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Label(contact.status, systemImage: "checkmark.seal.fill")
                .font(.headline)
                .foregroundStyle(.teal)
                .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
}
