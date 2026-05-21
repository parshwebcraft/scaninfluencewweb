import SwiftUI

struct ContentView: View {
    @StateObject private var activityManager = LiveActivityManager()

    @State private var selectedTab: ShowcaseTab = .home
    @State private var didScan = false
    @State private var isScanning = false
    @State private var showSavedSheet = false

    private let contact = MockProfileStore.featuredContact

    var body: some View {
        GeometryReader { proxy in
            let compactHeight = proxy.size.height < 820
            let stageHeight = min(proxy.size.height * (compactHeight ? 0.37 : 0.42), compactHeight ? 310 : 380)
            let titleSize: CGFloat = compactHeight ? 28 : 34
            let subtitleSize: CGFloat = compactHeight ? 16 : 20
            let bodySize: CGFloat = compactHeight ? 12 : 15
            let verticalSpacing: CGFloat = compactHeight ? 10 : 16

            ZStack {
                PremiumBackgroundView()

                VStack(spacing: verticalSpacing) {
                    ShowcaseNavigation(selectedTab: $selectedTab, isCompact: compactHeight)
                        .padding(.top, compactHeight ? 2 : 8)

                    Group {
                        switch selectedTab {
                        case .home:
                            ShowcaseStage(contact: contact, isScanning: isScanning, didScan: didScan, height: stageHeight)
                        case .product:
                            ProductOverviewPanel(contact: contact, height: stageHeight)
                        case .vCardAPI:
                            VCardAPIPanel(contact: contact, height: stageHeight)
                        case .showcase:
                            AssessmentPanel(height: stageHeight)
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.985)))
                    .id(selectedTab)

                    VStack(spacing: compactHeight ? 5 : 8) {
                        Text(selectedTab.heroTitle)
                            .font(.system(size: titleSize, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Text(selectedTab.heroSubtitle)
                            .font(.system(size: subtitleSize, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)

                        Text(selectedTab.heroBody)
                            .font(.system(size: bodySize, weight: .regular))
                            .foregroundStyle(.white.opacity(0.55))
                            .multilineTextAlignment(.center)
                            .lineSpacing(1)
                            .lineLimit(compactHeight ? 2 : 3)
                            .minimumScaleFactor(0.78)
                            .padding(.horizontal, compactHeight ? 8 : 16)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))

                    ScanButton(isScanning: isScanning, didScan: didScan) {
                        startScan()
                    }
                    .opacity(selectedTab == .home ? 1 : 0.62)
                    .frame(maxWidth: compactHeight ? 330 : .infinity)
                }
                .padding(.horizontal, compactHeight ? 16 : 18)
                .padding(.bottom, compactHeight ? 10 : 18)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            }
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

private enum ShowcaseTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case product = "Product"
    case vCardAPI = "V-Card API"
    case showcase = "Showcase"

    var id: String { rawValue }

    var heroTitle: String {
        switch self {
        case .home:
            "SCANFLUENCE"
        case .product:
            "CONTACT INTELLIGENCE"
        case .vCardAPI:
            "LOCAL MOCK DATA"
        case .showcase:
            "DYNAMIC ISLAND MVP"
        }
    }

    var heroSubtitle: String {
        switch self {
        case .home:
            "The future of networking is dynamic."
        case .product:
            "A polished scanned-card profile surface."
        case .vCardAPI:
            "No backend. No network. Just clean state."
        case .showcase:
            "Built around the assessment requirements."
        }
    }

    var heroBody: String {
        switch self {
        case .home:
            "Tap Scan Card to trigger the Live Activity and watch the in-app Dynamic Island preview transition."
        case .product:
            "The saved contact state highlights profile, designation, score, actions, and mutual connections."
        case .vCardAPI:
            "ActivityAttributes and ContentState mirror a real QR/NFC business card handoff using static data."
        case .showcase:
            "Focus areas: SwiftUI structure, premium UI polish, smooth animation, and tap-to-open Live Activity behavior."
        }
    }
}

private struct ShowcaseNavigation: View {
    @Binding var selectedTab: ShowcaseTab
    let isCompact: Bool

    var body: some View {
        HStack(spacing: isCompact ? 2 : 4) {
            ForEach(ShowcaseTab.allCases) { tab in
                Button {
                    Haptics.softTap()
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: isCompact ? 11 : 13, weight: selectedTab == tab ? .semibold : .medium))
                        .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.58))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, isCompact ? (tab == .vCardAPI ? 8 : 9) : (tab == .vCardAPI ? 11 : 13))
                        .frame(height: isCompact ? 30 : 34)
                        .contentShape(Capsule())
                        .background {
                            if selectedTab == tab {
                                Capsule()
                                    .fill(.white.opacity(0.16))
                                    .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
                                    .shadow(color: .white.opacity(0.08), radius: 8)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open \(tab.rawValue)")
            }
        }
        .padding(isCompact ? 3 : 4)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.10), lineWidth: 1))
        .shadow(color: .black.opacity(0.28), radius: 18, y: 10)
    }
}

private struct ProductOverviewPanel: View {
    let contact: ContactProfile
    let height: CGFloat

    var body: some View {
        ZStack {
            PanelBackground()

            VStack(spacing: 18) {
                ProfileAvatarView(initials: contact.initials, size: 82)

                VStack(spacing: 6) {
                    Text(contact.name)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("\(contact.designation) at \(contact.company)")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.68))
                }

                MetricRow()
                    .frame(maxWidth: 280)

                HStack(spacing: 10) {
                    MiniActionButton(title: "Call", systemImage: "phone.fill")
                    MiniActionButton(title: "LinkedIn", systemImage: "person.crop.square.fill")
                }

                Label(contact.status, systemImage: "checkmark.seal.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.teal)
                    .padding(.horizontal, 18)
                    .frame(height: 44)
                    .background(.teal.opacity(0.14), in: Capsule())
            }
            .padding(28)
        }
        .frame(height: height)
    }
}

private struct VCardAPIPanel: View {
    let contact: ContactProfile
    let height: CGFloat

    var body: some View {
        ZStack {
            PanelBackground()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Mock vCard Payload", systemImage: "curlybraces")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    Text("Local")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 10)
                        .frame(height: 24)
                        .background(.teal, in: Capsule())
                }

                VStack(alignment: .leading, spacing: 9) {
                    CodeLine(key: "name", value: contact.name)
                    CodeLine(key: "designation", value: contact.designation)
                    CodeLine(key: "company", value: contact.company)
                    CodeLine(key: "status", value: contact.status)
                    CodeLine(key: "activityPhase", value: "saving -> saved")
                    CodeLine(key: "deeplink", value: "scanfluence://contact/sarah-chen")
                }
                .padding(18)
                .background(.black.opacity(0.52), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(0.09), lineWidth: 1)
                }

                Spacer()

                Text("The app sends compact ActivityKit state updates. WidgetKit renders compact, expanded, minimal, and lock screen Live Activity layouts.")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.62))
                    .lineSpacing(3)
            }
            .padding(24)
        }
        .frame(height: height)
    }
}

private struct AssessmentPanel: View {
    let height: CGFloat

    private let items = [
        ("SwiftUI only", "Native views, materials, symbols, and springs"),
        ("Mock data", "Sarah Chen profile, no backend or networking"),
        ("Dynamic Island", "Compact, expanded, minimal, and lock screen states"),
        ("Tap interaction", "Widget URL opens scanfluence://contact/sarah-chen")
    ]

    var body: some View {
        ZStack {
            PanelBackground()

            VStack(alignment: .leading, spacing: 16) {
                Text("Assessment Coverage")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                ForEach(items, id: \.0) { item in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.teal)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.0)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white)

                            Text(item.1)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.58))
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                Spacer()
            }
            .padding(24)
        }
        .frame(height: height)
    }
}

private struct PanelBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [.white.opacity(0.16), .white.opacity(0.06), .black.opacity(0.78)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.13), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.48), radius: 30, y: 18)
    }
}

private struct CodeLine: View {
    let key: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\"\(key)\"")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(.cyan)
            Text(":")
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundStyle(.white.opacity(0.38))
            Text("\"\(value)\"")
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            Spacer(minLength: 0)
        }
    }
}

private struct ShowcaseStage: View {
    let contact: ContactProfile
    let isScanning: Bool
    let didScan: Bool
    let height: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let phoneWidth = min(width * 0.34, height * 0.42, 132)
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
        .frame(height: height)
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
