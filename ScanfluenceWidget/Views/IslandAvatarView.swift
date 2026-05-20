import SwiftUI

struct IslandAvatarView: View {
    let contact: ContactProfile
    let size: CGFloat

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.38, green: 0.94, blue: 0.82),
                            Color(red: 0.17, green: 0.42, blue: 0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Text(contact.initials)
                        .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

            Circle()
                .fill(.teal)
                .frame(width: size * 0.28, height: size * 0.28)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.13, weight: .bold))
                        .foregroundStyle(.black)
                }
                .offset(x: size * 0.02, y: size * 0.02)
        }
        .frame(width: size, height: size)
        .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1))
    }
}
