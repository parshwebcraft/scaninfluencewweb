import SwiftUI

struct ContentView: View {
    @Namespace private var scanNamespace
    @StateObject private var activityManager = LiveActivityManager()

    @State private var didScan = false
    @State private var isScanning = false
    @State private var showSavedSheet = false

    private let contact = MockProfileStore.featuredContact

    var body: some View {
        ZStack {
            PremiumBackgroundView()

            VStack(spacing: 28) {
                header

                Spacer(minLength: 6)

                BusinessCardPreview(contact: contact, namespace: scanNamespace)
                    .scaleEffect(isScanning ? 0.96 : 1)
                    .opacity(isScanning ? 0.72 : 1)

                scanStatus

                Spacer(minLength: 8)

                ScanButton(isScanning: isScanning, didScan: didScan) {
                    startScan()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 26)
        }
        .sheet(isPresented: $showSavedSheet) {
            SavedContactView(contact: contact)
                .presentationDetents([.height(360)])
                .presentationCornerRadius(32)
                .presentationBackground(.ultraThinMaterial)
        }
        .onOpenURL { _ in
            showSavedSheet = true
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Scanfluence")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                Text("Instant contact exchange")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.10), in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.12), lineWidth: 1))
        }
    }

    private var scanStatus: some View {
        VStack(spacing: 12) {
            ZStack {
                if didScan {
                    SuccessPulseView()
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 42, weight: .light))
                        .foregroundStyle(.white.opacity(0.82))
                        .frame(width: 82, height: 82)
                        .background(.white.opacity(0.08), in: Circle())
                        .overlay(Circle().stroke(.white.opacity(0.10), lineWidth: 1))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: 92)

            Text(didScan ? "Connection added" : "Ready for QR or NFC")
                .font(.headline)
                .contentTransition(.numericText())

            Text(didScan ? "Live Activity is active. Tap the Dynamic Island to return here." : "A mock scan starts a Live Activity with Dynamic Island states.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 290)
                .animation(.easeInOut(duration: 0.25), value: didScan)
        }
    }

    private func startScan() {
        guard !isScanning else { return }

        Haptics.softTap()
        isScanning = true

        Task {
            withAnimation(.spring(response: 0.46, dampingFraction: 0.78)) {
                didScan = false
            }

            try? await Task.sleep(for: .milliseconds(450))
            await activityManager.startScanActivity(for: contact)

            await MainActor.run {
                Haptics.success()
                withAnimation(.spring(response: 0.58, dampingFraction: 0.72)) {
                    didScan = true
                    isScanning = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
