import SwiftUI
import CoreLocation
import CoreHaptics

// MARK: - Qibla Manager
class QiblaManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var qiblaDirection: Double = 0
    @Published var heading: Double = 0
    @Published var hasLocation = false
    @Published var hasHeading = false
    @Published var isCalibrated = false
    @Published var locationError: String?
    @Published var locationName: String = "Detecting..."
    @Published var distanceToMakkah: String = ""
    @Published var distanceRaw: Double = 0

    private let locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    private let kaabaLat = 21.4225
    private let kaabaLon = 39.8262

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 0.5
    }

    func start() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func stop() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        userLocation = loc
        hasLocation = true
        calculateQibla(from: loc)
        calculateDistance(from: loc)
        reverseGeocode(loc)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else { return }
        let wasCalibrated = isCalibrated
        hasHeading = true
        isCalibrated = newHeading.headingAccuracy < 15
        heading = newHeading.magneticHeading
        if !wasCalibrated && isCalibrated {
            NotificationCenter.default.post(name: .qiblaCalibrated, object: nil)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = "Location unavailable. Enable Location Services."
    }

    private func calculateQibla(from location: CLLocation) {
        let userLat = location.coordinate.latitude.degreesToRadians
        let userLon = location.coordinate.longitude.degreesToRadians
        let kaabaLatRad = kaabaLat.degreesToRadians
        let kaabaLonRad = kaabaLon.degreesToRadians
        let dLon = kaabaLonRad - userLon
        let y = sin(dLon) * cos(kaabaLatRad)
        let x = cos(userLat) * sin(kaabaLatRad) - sin(userLat) * cos(kaabaLatRad) * cos(dLon)
        var bearing = atan2(y, x).radiansToDegrees
        if bearing < 0 { bearing += 360 }
        qiblaDirection = bearing
    }

    private func calculateDistance(from location: CLLocation) {
        let kaaba = CLLocation(latitude: kaabaLat, longitude: kaabaLon)
        let dist = location.distance(from: kaaba) / 1000
        distanceRaw = dist
        distanceToMakkah = dist > 1000
            ? String(format: "%.0f km from Makkah", dist)
            : String(format: "%.1f km from Makkah", dist)
    }

    private func reverseGeocode(_ location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            DispatchQueue.main.async {
                if let city = placemarks?.first?.locality, let country = placemarks?.first?.country {
                    self?.locationName = "\(city), \(country)"
                }
            }
        }
    }
}

extension Notification.Name {
    static let qiblaCalibrated = Notification.Name("qiblaCalibrated")
}

private extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }
}

// MARK: - Main View
struct QiblaCompassView: View {
    @StateObject private var qibla = QiblaManager()
    @Environment(\.colorScheme) var cs
    @State private var showCalibrationCheck = false
    @State private var alignmentPulse = false
    @State private var engine: CHHapticEngine?

    private var deviation: Double {
        let d = (qibla.heading - qibla.qiblaDirection).truncatingRemainder(dividingBy: 360)
        let norm = d < -180 ? d + 360 : d > 180 ? d - 360 : d
        return abs(norm)
    }
    private var isPerfectlyAligned: Bool { deviation < 3 }
    private var borderColor: Color { isPerfectlyAligned ? Color(hex: "#2E8B42") : Color(.systemGray3) }

    var body: some View {
        ZStack {
            Color("NoorSurface").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    locationCard
                    compassSection
                    degreeCard
                    spiritualQuote
                    shareButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Qibla Compass")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            qibla.start()
            prepareHaptics()
        }
        .onDisappear { qibla.stop() }
        .onReceive(NotificationCenter.default.publisher(for: .qiblaCalibrated)) { _ in
            showCalibrationCheck = true
            triggerCalibrationHaptic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { showCalibrationCheck = false }
        }
        .onChange(of: isPerfectlyAligned) { aligned in
            if aligned { triggerAlignmentHaptic() }
        }
    }

    // MARK: - Location Card
    private var locationCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#2E8B42"))
                    Text(qibla.locationName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                if !qibla.distanceToMakkah.isEmpty {
                    HStack(spacing: 5) {
                        Text("🕋")
                            .font(.caption)
                        Text(qibla.distanceToMakkah)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
            calibrationBadge
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var calibrationBadge: some View {
        Group {
            if showCalibrationCheck {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Calibrated")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.green)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                HStack(spacing: 5) {
                    Circle()
                        .fill(qibla.isCalibrated ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(qibla.isCalibrated ? Color.green.opacity(0.4) : Color.orange.opacity(0.4), lineWidth: 3)
                                .scaleEffect(alignmentPulse ? 1.6 : 1.0)
                                .opacity(alignmentPulse ? 0 : 1)
                                .animation(.easeOut(duration: 1.2).repeatForever(autoreverses: false), value: alignmentPulse)
                        )
                    Text(qibla.isCalibrated ? "Accurate" : "Calibrating...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .onAppear { alignmentPulse = true }
            }
        }
        .animation(.spring(response: 0.4), value: showCalibrationCheck)
    }

    // MARK: - Compass Section
    private var compassSection: some View {
        ZStack {
            // Glass background
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [borderColor.opacity(0.8), borderColor.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isPerfectlyAligned ? 2.5 : 1
                        )
                )
                .shadow(color: isPerfectlyAligned ? Color(hex: "#2E8B42").opacity(0.3) : Color.black.opacity(0.06), radius: isPerfectlyAligned ? 14 : 8)
            
            compassDial
                .padding(28)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isPerfectlyAligned)
    }

    private var compassDial: some View {
        ZStack {
            // Outer tick ring
            outerRing
            // Cardinal labels
            cardinalLabels
            // Qibla needle (rotates with qibla direction relative to heading)
            qiblaNeedle
            // Center Kaaba
            centerKaaba
        }
        .frame(width: 272, height: 272)
        .rotationEffect(.degrees(-qibla.heading))
        .animation(.interpolatingSpring(stiffness: 80, damping: 12), value: qibla.heading)
    }

    private var outerRing: some View {
        ZStack {
            // Outer gradient stroke
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "#2E8B42").opacity(0.6), Color(hex: "#C8A951").opacity(0.3), Color(hex: "#2E8B42").opacity(0.6)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 268, height: 268)
            // Inner soft shadow ring
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 1)
                .frame(width: 248, height: 248)
                .opacity(0.6)
            // Tick marks
            ForEach(0..<72, id: \.self) { i in
                let isMajor = i % 18 == 0
                let isMid = i % 9 == 0
                Rectangle()
                    .fill(isMajor ? Color(hex: "#2E8B42") : (isMid ? Color(.systemGray3) : Color(.systemGray5)))
                    .frame(width: isMajor ? 2 : 1, height: isMajor ? 14 : (isMid ? 9 : 6))
                    .offset(y: -126)
                    .rotationEffect(.degrees(Double(i) * 5))
            }
        }
    }

    private var cardinalLabels: some View {
        ZStack {
            compassLabel("N", angle: 0, color: .red)
            compassLabel("E", angle: 90)
            compassLabel("S", angle: 180)
            compassLabel("W", angle: 270)
        }
    }

    private func compassLabel(_ text: String, angle: Double, color: Color = .primary) -> some View {
        let rad = angle * .pi / 180
        return Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .offset(x: 100 * sin(rad), y: -100 * cos(rad))
    }

    private var qiblaNeedle: some View {
        let needleAngle = qibla.qiblaDirection
        return ZStack(alignment: .bottom) {
            // Glow trail
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#2E8B42").opacity(0.0), Color(hex: "#2E8B42").opacity(0.35)],
                        startPoint: .bottom, endPoint: .top
                    )
                )
                .frame(width: 6, height: 68)
                .blur(radius: 3)
                .offset(y: -14)
            // Arrow shaft
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#2E8B42"), Color(hex: "#2E8B42").opacity(0.75)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 3.5, height: 64)
                .offset(y: -14)
            // Arrowhead
            Image(systemName: "arrowtriangle.up.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(hex: "#2E8B42"))
                .offset(y: -76)
            // "Qibla" label near tip
            Text("Qibla")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color(hex: "#2E8B42"))
                .offset(y: -96)
        }
        .rotationEffect(.degrees(needleAngle))
        .animation(.interpolatingSpring(stiffness: 70, damping: 11), value: needleAngle)
    }

    private var centerKaaba: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#2E8B42").opacity(0.12))
                .frame(width: 58, height: 58)
            Circle()
                .stroke(Color(hex: "#C8A951").opacity(0.5), lineWidth: 1.5)
                .frame(width: 52, height: 52)
            Circle()
                .fill(cs == .dark ? Color(.systemGray6) : .white)
                .frame(width: 48, height: 48)
                .shadow(color: .black.opacity(0.08), radius: 4)
            Text("🕋")
                .font(.system(size: 20))
                .rotationEffect(.degrees(qibla.heading))
        }
    }

    // MARK: - Degree Card
    private var degreeCard: some View {
        VStack(spacing: 10) {
            if isPerfectlyAligned {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color(hex: "#2E8B42"))
                    Text("Perfect Alignment")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "#2E8B42"))
                }
                .transition(.scale.combined(with: .opacity))
            }

            // Large degree display
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(String(format: "%.0f", qibla.qiblaDirection))
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#2E8B42"))
                    .tracking(-1)
                Text(String(format: ".%01d°", Int(qibla.qiblaDirection * 10) % 10))
                    .font(.system(size: 28, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(hex: "#2E8B42").opacity(0.7))
                    .baselineOffset(4)
            }

            Text("Face this direction to pray")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let error = qibla.locationError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .animation(.spring(response: 0.4), value: isPerfectlyAligned)
    }

    // MARK: - Spiritual Quote
    private var spiritualQuote: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#2E8B42"), Color(hex: "#C8A951")],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 3)
                .clipShape(Capsule())
            Text("Align your heart before your direction.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .italic()
            Spacer()
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Share Button
    private var shareButton: some View {
        ShareLink(
            item: "My Qibla direction is \(String(format: "%.1f°", qibla.qiblaDirection)) from \(qibla.locationName). \(qibla.distanceToMakkah). 🕋",
            subject: Text("My Qibla Direction"),
            message: Text("Shared via Noor Al-Muslim")
        ) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.subheadline.weight(.semibold))
                Text("Share Qibla Direction")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(Color(hex: "#2E8B42"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(hex: "#2E8B42").opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#2E8B42").opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Helpers
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(cs == .dark ? Color(.systemGray6) : .white)
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    // MARK: - Haptics
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        engine = try? CHHapticEngine()
        try? engine?.start()
    }

    private func triggerCalibrationHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics, let engine else { return }
        let events: [CHHapticEvent] = [
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
            ], relativeTime: 0),
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
            ], relativeTime: 0.15)
        ]
        if let pattern = try? CHHapticPattern(events: events, parameters: []),
           let player = try? engine.makePlayer(with: pattern) {
            try? player.start(atTime: 0)
        }
    }

    private func triggerAlignmentHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics, let engine else { return }
        let events: [CHHapticEvent] = [
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ], relativeTime: 0),
            CHHapticEvent(eventType: .hapticContinuous, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            ], relativeTime: 0.1, duration: 0.3),
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            ], relativeTime: 0.45)
        ]
        if let pattern = try? CHHapticPattern(events: events, parameters: []),
           let player = try? engine.makePlayer(with: pattern) {
            try? player.start(atTime: 0)
        }
    }
}

// MARK: - Color Hex Extension
private extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
