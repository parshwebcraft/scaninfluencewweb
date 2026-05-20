import SwiftUI

struct ProfileAvatarView: View {
    let initials: String
    let size: CGFloat

    var body: some View {
        ZStack {
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

            Text(initials)
                .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .overlay(Circle().stroke(.white.opacity(0.28), lineWidth: 1))
        .shadow(color: .teal.opacity(0.26), radius: 18, y: 8)
    }
}
