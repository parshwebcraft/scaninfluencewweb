import SwiftUI

struct SuccessPulseView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(.teal.opacity(pulse ? 0.0 : 0.45), lineWidth: 2)
                .frame(width: pulse ? 112 : 72, height: pulse ? 112 : 72)

            Circle()
                .fill(.teal.opacity(0.18))
                .frame(width: 82, height: 82)

            Image(systemName: "checkmark")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(.teal, in: Circle())
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.35).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
    }
}
