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
        locationError = "Location unavailable. Enable Location Services in Settings."
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
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.colorScheme) var cs
    @State private var showCalibrationCheck = false
    @State private var alignmentPulse = false
    @State private var engine: CHHapticEngine?
    @Environment(\.dismiss) var dismiss

    private var deviation: Double {
        let d = (qibla.heading - qibla.qiblaDirection).truncatingRemainder(dividingBy: 360)
        let norm = d < -180 ? d + 360 : d > 180 ? d - 360 : d
        return abs(norm)
    }
    private var isPerfectlyAligned: Bool { deviation < 3 }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundLayer.ignoresSafeArea()
            VStack(spacing: 0) {
                locationBadge
                Spacer()
                compassDialView
                Spacer()
                bottomPill
                calibrationHint
                    .padding(.bottom, 12)
            }
        }
        .navigationTitle(localization.t(.qiblaTitle))
        .navigationBarTitleDisplayMode(.inline)
        .sheetDismissButton()
        .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear { qibla.start(); prepareHaptics() }
        .onDisappear { qibla.stop() }
        .onReceive(NotificationCenter.default.publisher(for: .qiblaCalibrated)) { _ in
            showCalibrationCheck = true
            triggerCalibrationHaptic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { showCalibrationCheck = false }
        }
        .onChange(of: isPerfectlyAligned) { oldValue, newValue in
            if newValue && !oldValue { triggerAlignmentHaptic() }
        }
    }

    // MARK: - Background
    private var backgroundLayer: some View {
        ZStack {
            Color("NoorSurface")
            if isPerfectlyAligned {
                RadialGradient(
                    colors: [Color.alehaGreen.opacity(0.15), Color.clear],
                    center: .center, startRadius: 60, endRadius: 320
                )
                .animation(.easeInOut(duration: 1.0), value: isPerfectlyAligned)
            }
        }
    }

    // MARK: - Location Badge
    private var locationBadge: some View {
        HStack(spacing: 16) {
            HStack(spacing: 5) {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundStyle(Color.alehaGreen)
                VStack(alignment: .leading, spacing: 1) {
                    Text(qibla.locationName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    if !qibla.distanceToMakkah.isEmpty {
                        Text(qibla.distanceToMakkah)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
            calibrationIndicator
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current location: \(qibla.locationName). \(qibla.distanceToMakkah)")
    }

    private var calibrationIndicator: some View {
        Group {
            if showCalibrationCheck {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(localization.t(.qiblaCalibrated))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                }
                .transition(.scale.combined(with: .opacity))
            } else if qibla.isCalibrated {
                HStack(spacing: 4) {
                    Image(systemName: "location.circle.fill")
                        .foregroundStyle(Color.alehaGreen)
                    Text(localization.t(.qiblaAccurate))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                calibratingBadge
            }
        }
        .animation(.spring(response: 0.4), value: showCalibrationCheck)
        .animation(.spring(response: 0.4), value: qibla.isCalibrated)
    }

    private var calibratingBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.orange)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(Color.orange.opacity(0.4), lineWidth: 3)
                        .scaleEffect(alignmentPulse ? 1.8 : 1.0)
                        .opacity(alignmentPulse ? 0 : 1)
                        .animation(.easeOut(duration: 1.2).repeatForever(autoreverses: false), value: alignmentPulse)
                )
                .onAppear { alignmentPulse = true }
            Text(localization.t(.qiblaCalibrating))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Compass Dial
    private var compassDialView: some View {
        ZStack {
            outerRing
            degreeTicks
            cardinalLabels
            qiblaNeedle
            centerKaaba
        }
        .frame(width: 300, height: 300)
        .rotationEffect(.degrees(-qibla.heading))
        .animation(.interpolatingSpring(stiffness: 80, damping: 12), value: qibla.heading)
        .padding(.vertical, 8)
        .accessibilityLabel("Qibla direction: \(Int(qibla.qiblaDirection)) degrees")
    }

    private var outerRing: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.alehaGreen.opacity(0.6), Color.alehaAmber.opacity(0.4), Color.alehaGreen.opacity(0.6)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ), lineWidth: 3
                )
                .frame(width: 296, height: 296)

            Circle()
                .stroke(Color.alehaGreen.opacity(0.2), lineWidth: 1)
                .frame(width: 280, height: 280)

            Circle()
                .stroke(Color.secondary.opacity(0.15), lineWidth: 12)
                .frame(width: 268, height: 268)
        }
    }

    private var degreeTicks: some View {
        ForEach(0..<72, id: \.self) { i in
            let isMajor = i % 18 == 0
            let isMid = i % 9 == 0
            Rectangle()
                .fill(isMajor ? Color.alehaGreen : (isMid ? Color.secondary.opacity(0.5) : Color.secondary.opacity(0.3)))
                .frame(width: isMajor ? 2.5 : 1, height: isMajor ? 16 : (isMid ? 10 : 6))
                .offset(y: -138)
                .rotationEffect(.degrees(Double(i) * 5))
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
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(color)
            .offset(x: 112 * sin(rad), y: -112 * cos(rad))
    }

    private var qiblaNeedle: some View {
        let needleAngle = qibla.qiblaDirection
        return ZStack(alignment: .bottom) {
            // Glow effect
            Rectangle()
                .fill(Color.alehaGreen.opacity(0.25))
                .frame(width: 8, height: 80)
                .blur(radius: 4)
                .offset(y: -14)

            // Main needle
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.alehaGreen.opacity(0.1), Color.alehaGreen],
                        startPoint: .bottom, endPoint: .top
                    )
                )
                .frame(width: 4, height: 72)
                .offset(y: -14)

            // Arrow head
            Image(systemName: "arrowtriangle.up.fill")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.alehaGreen)
                .offset(y: -84)

            // Qibla label
            Text(localization.t(.qiblaQiblaLabel))
                .font(.caption2)
                .fontWeight(.heavy)
                .foregroundStyle(Color.alehaGreen)
                .tracking(1.5)
                .offset(y: -108)
        }
        .rotationEffect(.degrees(needleAngle))
        .animation(.interpolatingSpring(stiffness: 70, damping: 11), value: needleAngle)
    }

    private var centerKaaba: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(Color.alehaGreen.opacity(0.1))
                .frame(width: 70, height: 70)

            // Gold ring
            Circle()
                .stroke(Color.alehaAmber.opacity(0.6), lineWidth: 2)
                .frame(width: 60, height: 60)

            // White center
            Circle()
                .fill(cs == .dark ? Color(.systemGray5) : .white)
                .frame(width: 54, height: 54)
                .shadow(color: .black.opacity(0.1), radius: 4)

            // Kaaba icon
            Image(systemName: "building.columns.fill")
                .font(.title2)
                .foregroundStyle(Color.alehaDarkGreen)
                .rotationEffect(.degrees(qibla.heading))
        }
    }

    // MARK: - Bottom Pill
    private var bottomPill: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(String(format: "%.0f", qibla.qiblaDirection))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.alehaGreen)
                        .contentTransition(.numericText())
                    Text("°")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.alehaGreen.opacity(0.7))
                        .baselineOffset(6)
                }
                HStack(spacing: 4) {
                    Image(systemName: isPerfectlyAligned ? "checkmark.circle.fill" : "location.north.fill")
                        .font(.caption)
                    Text(isPerfectlyAligned ? localization.t(.qiblaPerfectAlignment) : localization.t(.qiblaFaceDirection))
                        .font(.caption)
                }
                .foregroundStyle(isPerfectlyAligned ? Color.alehaGreen : .secondary)
                .animation(.spring(response: 0.3), value: isPerfectlyAligned)
            }
            Spacer()
            ShareLink(
                item: "My Qibla direction is \(String(format: "%.0f°", qibla.qiblaDirection)) from \(qibla.locationName). \(qibla.distanceToMakkah).",
                subject: Text(localization.t(.qiblaMyDirection)),
                message: Text(localization.t(.qiblaSharedVia))
            ) {
                Label(localization.t(.commonShare), systemImage: "square.and.arrow.up")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Color.alehaGreen)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 16, y: -4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .animation(.spring(response: 0.4), value: isPerfectlyAligned)
    }

    // MARK: - Calibration hint
    private var calibrationHint: some View {
        Group {
            if let err = qibla.locationError {
                Label(err, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            } else if !qibla.isCalibrated {
                Label(localization.t(.qiblaNeedsCalibration), systemImage: "iphone.gen3.radiowaves.left.and.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("\"Turn towards the Kaaba with sincerity.\"")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
        }
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
           let player = try? engine.makePlayer(with: pattern) { try? player.start(atTime: 0) }
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
           let player = try? engine.makePlayer(with: pattern) { try? player.start(atTime: 0) }
    }
}

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
