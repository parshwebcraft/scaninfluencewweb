import SwiftUI

struct PremiumBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.02, green: 0.02, blue: 0.025),
                Color(red: 0.055, green: 0.06, blue: 0.075),
                Color(red: 0.01, green: 0.015, blue: 0.018)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            RadialGradient(
                colors: [.teal.opacity(0.18), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 380
            )
        }
        .ignoresSafeArea()
    }
}
