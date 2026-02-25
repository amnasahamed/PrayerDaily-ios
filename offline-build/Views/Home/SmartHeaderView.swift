import SwiftUI

// MARK: - Smart Compact Header
struct SmartHeaderView: View {
    @ObservedObject var service: PrayerTimesService
    @Environment(\.colorScheme) var cs
    @State private var countdown = ""
    @State private var pulseOpacity: Double = 1.0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            heroBackground
            VStack(spacing: 0) {
                mosqueImageLayer
                contentOverlay
            }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.alehaGreen.opacity(0.22), radius: 18, y: 8)
        .onAppear { updateCountdown() }
        .onReceive(timer) { _ in updateCountdown() }
    }

    // MARK: - Hero Background
    private var heroBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.10, blue: 0.08),
                    Color(red: 0.06, green: 0.20, blue: 0.13),
                    Color(red: 0.10, green: 0.30, blue: 0.18)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            // Subtle star canvas
            Canvas { context, size in
                let stars: [(CGFloat, CGFloat, CGFloat)] = [
                    (0.12, 0.18, 1.3), (0.30, 0.10, 1.8), (0.55, 0.20, 1.1),
                    (0.72, 0.08, 1.6), (0.88, 0.22, 1.2), (0.45, 0.06, 1.4),
                    (0.65, 0.14, 0.9), (0.20, 0.30, 1.0), (0.82, 0.28, 1.5)
                ]
                for (x, y, r) in stars {
                    let pt = CGPoint(x: size.width * x, y: size.height * y * 0.55)
                    let rect = CGRect(x: pt.x - r, y: pt.y - r, width: r * 2, height: r * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.55)))
                }
            }
            .allowsHitTesting(false)
            // Green glow orb
            Circle()
                .fill(Color.alehaGreen.opacity(0.14))
                .frame(width: 180, height: 180)
                .blur(radius: 60)
                .offset(x: 80, y: -60)
            // Amber glow
            Circle()
                .fill(Color.alehaAmber.opacity(0.08))
                .frame(width: 100, height: 100)
                .blur(radius: 40)
                .offset(x: -80, y: -50)
        }
    }

    // MARK: - Mosque Silhouette Image Layer
    private var mosqueImageLayer: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Try to load a bundled image; fall back to drawn silhouette
                MosqueSilhouette()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.03, green: 0.12, blue: 0.07).opacity(0.95),
                                Color(red: 0.02, green: 0.08, blue: 0.05)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: geo.size.width, height: geo.size.height * 0.52)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
    }

    // MARK: - Content Overlay
    private var contentOverlay: some View {
        HStack(alignment: .top) {
            leftContent
            Spacer()
            rightContent
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var leftContent: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(greetingText)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.60))
            Text("السلام عليكم")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(.white)
            if let next = service.nextPrayer {
                nextPrayerBadge(next)
            } else {
                Text(service.hijriDate.isEmpty ? "Loading…" : service.hijriDate)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.40))
                    .lineLimit(1)
            }
        }
        .offset(y: 0)
    }

    private func nextPrayerBadge(_ next: PrayerTime) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color.alehaGreen)
                .frame(width: 6, height: 6)
                .opacity(pulseOpacity)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulseOpacity)
                .onAppear { pulseOpacity = 0.25 }
            Text("Next: \(next.prayer.rawValue) · \(countdown)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.alehaGreen)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.alehaGreen.opacity(0.15))
        .clipShape(Capsule())
    }

    private var rightContent: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 44, height: 44)
            CrescentShape()
                .fill(Color.alehaAmber.opacity(0.88))
                .frame(width: 20, height: 20)
        }
    }

    private var greetingText: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good Morning ☀️" }
        if h < 17 { return "Good Afternoon 🌤" }
        return "Good Evening 🌙"
    }

    private func updateCountdown() {
        guard let next = service.nextPrayer else { countdown = ""; return }
        let diff = next.time.timeIntervalSinceNow
        if diff <= 0 { countdown = "Now"; return }
        let h = Int(diff) / 3600
        let m = (Int(diff) % 3600) / 60
        let s = Int(diff) % 60
        if h > 0 { countdown = "\(h)h \(m)m" }
        else if m > 0 { countdown = "\(m)m \(s)s" }
        else { countdown = "\(s)s" }
    }
}
