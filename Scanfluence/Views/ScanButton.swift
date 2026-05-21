import SwiftUI

struct ScanButton: View {
    let isScanning: Bool
    let didScan: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: didScan ? "checkmark.circle.fill" : "viewfinder.circle.fill")
                    .font(.title3.weight(.semibold))

                Text(isScanning ? "Scanning..." : didScan ? "Scan Again" : "Scan Card")
                    .font(.headline.weight(.semibold))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(.white, in: Capsule())
            .overlay(alignment: .trailing) {
                if isScanning {
                    ProgressView()
                        .tint(.black)
                        .padding(.trailing, 22)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isScanning)
        .scaleEffect(isScanning ? 0.985 : 1)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isScanning)
    }
}
