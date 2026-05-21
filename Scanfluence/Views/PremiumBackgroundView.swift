import SwiftUI

struct PremiumBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.15, green: 0.16, blue: 0.18),
                Color(red: 0.045, green: 0.047, blue: 0.055),
                Color(red: 0.005, green: 0.006, blue: 0.008)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            RadialGradient(
                colors: [.cyan.opacity(0.18), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 380
            )
        }
        .overlay {
            RadialGradient(
                colors: [.white.opacity(0.14), .clear],
                center: .top,
                startRadius: 10,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }
}
