import SwiftUI
import Combine

// MARK: - Compact Prayer-Time Header (~90px)
struct SmartHeaderView: View {
    @ObservedObject var service: PrayerTimesService
    @Environment(\.colorScheme) var cs
    @Environment(\.localization) var l10n
    @State private var countdown = ""
    @State private var pulseOpacity: Double = 1.0
    @State private var timerCancellable: AnyCancellable?

    var body: some View {
        HStack(spacing: 14) {
            leftGreeting
            Spacer()
            if let next = service.nextPrayer {
                nextPrayerPill(next)
            }
            crescentBadge
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(headerBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.alehaGreen.opacity(cs == .dark ? 0.22 : 0.14), radius: 14, y: 6)
        .onAppear {
            updateCountdown()
            timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in updateCountdown() }
        }
        .onDisappear {
            timerCancellable?.cancel()
            timerCancellable = nil
        }
    }

    // MARK: - Left: greeting + arabic
    private var leftGreeting: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(greetingText)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.65))
            Text("السلام عليكم")
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Next prayer pill
    private func nextPrayerPill(_ next: PrayerTime) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.alehaGreen)
                .frame(width: 7, height: 7)
                .opacity(pulseOpacity)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulseOpacity)
                .onAppear { pulseOpacity = 0.25 }
            VStack(alignment: .leading, spacing: 1) {
                Text(next.prayer.rawValue)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Text(countdown)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.alehaGreen)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.alehaGreen.opacity(0.30), lineWidth: 1)
        )
    }

    // MARK: - Crescent moon badge
    private var crescentBadge: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.09))
                .frame(width: 38, height: 38)
            CrescentShape()
                .fill(Color.alehaAmber.opacity(0.90))
                .frame(width: 18, height: 18)
        }
    }

    // MARK: - Background (dark green + stars canvas)
    private var headerBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.13, blue: 0.09),
                    Color(red: 0.07, green: 0.22, blue: 0.14)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            Canvas { context, size in
                let stars: [(CGFloat, CGFloat, CGFloat)] = [
                    (0.08, 0.22, 1.2), (0.22, 0.60, 0.9), (0.40, 0.18, 1.4),
                    (0.60, 0.70, 1.0), (0.78, 0.28, 1.3), (0.92, 0.62, 1.1)
                ]
                for (x, y, r) in stars {
                    let pt = CGPoint(x: size.width * x, y: size.height * y)
                    let rect = CGRect(x: pt.x - r, y: pt.y - r, width: r * 2, height: r * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.45)))
                }
            }
            .allowsHitTesting(false)
            Circle()
                .fill(Color.alehaGreen.opacity(0.12))
                .frame(width: 120, height: 120)
                .blur(radius: 45)
                .offset(x: 60, y: -20)
        }
    }

    private var greetingText: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return l10n.t(.homeGreetingMorning) }
        if h < 17 { return l10n.t(.homeGreetingAfternoon) }
        return l10n.t(.homeGreetingEvening)
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
