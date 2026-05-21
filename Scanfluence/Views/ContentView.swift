import SwiftUI

struct ContentView: View {
    @StateObject private var activityManager = LiveActivityManager()

    @State private var didScan = false
    @State private var isScanning = false
    @State private var showSavedSheet = false

    private let contact = MockProfileStore.featuredContact

    var body: some View {
        ZStack {
            PremiumBackgroundView()

            VStack(spacing: 18) {
                ShowcaseNavigation()
                    .padding(.top, 10)

                ShowcaseStage(contact: contact, isScanning: isScanning, didScan: didScan)
                    .padding(.top, 8)

                VStack(spacing: 8) {
                    Text("SCANFLUENCE")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .multilineTextAlignment(.center)

                    Text("The future of networking is dynamic.")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
                        .multilineTextAlignment(.center)

                    Text("Leveraging Apple's Dynamic Island API for seamless V-Card discovery.")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 16)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))

                ScanButton(isScanning: isScanning, didScan: didScan) {
                    startScan()
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 22)
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

    private func startScan() {
        guard !isScanning else { return }

        Haptics.softTap()

        withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
            isScanning = true
            didScan = false
        }

        Task {
            try? await Task.sleep(for: .milliseconds(420))
            await activityManager.startScanActivity(for: contact)

            await MainActor.run {
                Haptics.success()
                withAnimation(.spring(response: 0.62, dampingFraction: 0.74)) {
                    didScan = true
                    isScanning = false
                }
            }
        }
    }
}

private struct ShowcaseNavigation: View {
    private let items = ["Home", "Product", "V-Card API", "Showcase"]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.system(size: 13, weight: item == "Home" ? .semibold : .medium))
                    .foregroundStyle(item == "Home" ? .white : .white.opacity(0.58))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .padding(.horizontal, item == "V-Card API" ? 12 : 14)
                    .frame(height: 34)
                    .background {
                        if item == "Home" {
                            Capsule()
                                .fill(.white.opacity(0.16))
                                .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
                        }
                    }
            }
        }
        .padding(4)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.10), lineWidth: 1))
        .shadow(color: .black.opacity(0.28), radius: 18, y: 10)
    }
}

private struct ShowcaseStage: View {
    let contact: ContactProfile
    let isScanning: Bool
    let didScan: Bool

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let phoneWidth = min(width * 0.34, 132)
            let stageHeight = proxy.size.height

            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.18),
                                .white.opacity(0.06),
                                .black.opacity(0.72)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(.white.opacity(0.14), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.55), radius: 34, y: 20)

                PhoneMockup(width: phoneWidth, dimmed: !isScanning && !didScan) {
                    EmptyPhoneContent()
                }
                .offset(x: -phoneWidth * 0.92, y: 22)
                .rotation3DEffect(.degrees(0), axis: (x: 0, y: 1, z: 0))

                PhoneMockup(width: phoneWidth, dimmed: false) {
                    ScannerPhoneContent(isScanning: isScanning, didScan: didScan)
                }
                .scaleEffect(isScanning ? 1.04 : 1)
                .offset(y: isScanning ? -10 : 4)
                .zIndex(2)

                PhoneMockup(width: phoneWidth, dimmed: !didScan) {
                    ContactPhoneContent(contact: contact, isVisible: didScan)
                }
                .offset(x: phoneWidth * 0.92, y: didScan ? -2 : 22)
                .scaleEffect(didScan ? 1.03 : 0.98)
                .zIndex(didScan ? 3 : 1)

                VStack {
                    Spacer()
                    LinearGradient(colors: [.clear, .black.opacity(0.88)], startPoint: .top, endPoint: .bottom)
                        .frame(height: stageHeight * 0.28)
                }
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .allowsHitTesting(false)
            }
            .animation(.spring(response: 0.62, dampingFraction: 0.74), value: isScanning)
            .animation(.spring(response: 0.72, dampingFraction: 0.78), value: didScan)
        }
        .frame(height: 420)
    }
}

private struct PhoneMockup<Content: View>: View {
    let width: CGFloat
    let dimmed: Bool
    let content: Content

    private var height: CGFloat { width * 2.08 }

    init(width: CGFloat, dimmed: Bool, @ViewBuilder content: () -> Content) {
        self.width = width
        self.dimmed = dimmed
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: width * 0.18, style: .continuous)
                .fill(.black)
                .overlay {
                    RoundedRectangle(cornerRadius: width * 0.18, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.48), .white.opacity(0.08), .white.opacity(0.28)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }

            VStack(spacing: 0) {
                PhoneStatusBar(width: width)
                content
            }
            .padding(width * 0.07)
        }
        .frame(width: width, height: height)
        .opacity(dimmed ? 0.48 : 1)
        .blur(radius: dimmed ? 0.4 : 0)
        .shadow(color: .black.opacity(0.52), radius: 18, y: 12)
    }
}

private struct PhoneStatusBar: View {
    let width: CGFloat

    var body: some View {
        HStack {
            Text("9:41")
                .font(.system(size: width * 0.095, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Capsule()
                .fill(.black)
                .frame(width: width * 0.36, height: width * 0.13)
                .overlay(Capsule().stroke(.white.opacity(0.06), lineWidth: 1))

            Spacer()

            HStack(spacing: 3) {
                Image(systemName: "cellularbars")
                Image(systemName: "wifi")
                Image(systemName: "battery.100")
            }
            .font(.system(size: width * 0.062, weight: .bold))
            .foregroundStyle(.white)
        }
        .frame(height: width * 0.22)
    }
}

private struct EmptyPhoneContent: View {
    var body: some View {
        LinearGradient(
            colors: [.white.opacity(0.12), .black, .black],
            startPoint: .top,
            endPoint: .bottom
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(alignment: .top) {
            DynamicIslandPill(title: "", icon: "sparkle", accent: .white.opacity(0.28), progress: nil)
                .opacity(0.45)
                .padding(.top, 10)
                .padding(.horizontal, 8)
        }
    }
}

private struct ScannerPhoneContent: View {
    let isScanning: Bool
    let didScan: Bool

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [.cyan.opacity(isScanning ? 0.22 : 0.08), .black, .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(spacing: 18) {
                DynamicIslandPill(
                    title: didScan ? "Connection Added" : isScanning ? "Scan Detected..." : "Ready to Scan",
                    icon: didScan ? "checkmark" : "viewfinder",
                    accent: didScan ? .teal : .cyan,
                    progress: didScan ? 1 : isScanning ? 0.62 : nil
                )
                .padding(.top, 10)
                .padding(.horizontal, 8)
                .shadow(color: (isScanning || didScan ? Color.cyan : .clear).opacity(0.9), radius: 18)

                Spacer()

                Image(systemName: didScan ? "checkmark.seal.fill" : "qrcode.viewfinder")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(didScan ? .teal : .white.opacity(0.72))
                    .scaleEffect(isScanning ? 1.12 : 1)

                Text(didScan ? "Saved to Contacts" : "NFC + QR Discovery")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.76))

                Spacer()
            }
        }
    }
}

private struct ContactPhoneContent: View {
    let contact: ContactProfile
    let isVisible: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.white.opacity(0.24), .gray.opacity(0.22), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .blur(radius: isVisible ? 0 : 1.5)

            VStack(spacing: 10) {
                Spacer(minLength: 22)

                ProfileAvatarView(initials: contact.initials, size: 54)

                VStack(spacing: 3) {
                    HStack(spacing: 4) {
                        Text(contact.name)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.blue)
                    }

                    Text("\(contact.designation), \(contact.company)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                        .lineLimit(1)
                }

                VStack(spacing: 7) {
                    MetricRow()

                    HStack(spacing: 7) {
                        MiniActionButton(title: "Call", systemImage: "phone.fill")
                        MiniActionButton(title: "LinkedIn", systemImage: "inset.filled.rectangle.and.person.filled")
                    }

                    MiniActionButton(title: "Save to Contacts", systemImage: "person.crop.circle.badge.checkmark", isWide: true)
                }
                .padding(.horizontal, 9)

                HStack {
                    Text("Mutual Connections")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.75))

                    Spacer()

                    HStack(spacing: -6) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill([Color.orange, Color.blue, Color.teal][index])
                                .frame(width: 21, height: 21)
                                .overlay(Circle().stroke(.black, lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 12)

                Spacer(minLength: 12)
            }
            .opacity(isVisible ? 1 : 0.36)
            .scaleEffect(isVisible ? 1 : 0.94)
        }
        .animation(.spring(response: 0.58, dampingFraction: 0.76), value: isVisible)
    }
}

private struct DynamicIslandPill: View {
    let title: String
    let icon: String
    let accent: Color
    let progress: Double?

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 24, height: 24)
                .background(accent.opacity(0.15), in: Circle())

            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: 0)

            if let progress {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.18), lineWidth: 3)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 42)
        .background(.black, in: Capsule())
        .overlay(Capsule().stroke(accent.opacity(0.42), lineWidth: 1))
    }
}

private struct MetricRow: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.blue.opacity(0.34), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 1) {
                Text("AI Networking Score")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.72))
                Text("98/100 - Premium")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(8)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct MiniActionButton: View {
    let title: String
    let systemImage: String
    var isWide = false

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.system(size: 10, weight: .bold))
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: isWide ? .infinity : nil)
        .frame(height: 29)
        .padding(.horizontal, isWide ? 0 : 12)
        .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
    }
}

#Preview {
    ContentView()
}
