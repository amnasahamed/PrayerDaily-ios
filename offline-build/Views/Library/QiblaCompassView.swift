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
            // Full-bleed background
            backgroundLayer.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                Spacer()
                compassDialView
                Spacer()
                bottomPill
                calibrationHint
                    .padding(.bottom, 12)
            }
        }
        .onAppear { qibla.start(); prepareHaptics() }
        .onDisappear { qibla.stop() }
        .onReceive(NotificationCenter.default.publisher(for: .qiblaCalibrated)) { _ in
            showCalibrationCheck = true
            triggerCalibrationHaptic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { showCalibrationCheck = false }
        }
        .onChange(of: isPerfectlyAligned) { aligned in if aligned { triggerAlignmentHaptic() } }
    }

    // MARK: - Background
    private var backgroundLayer: some View {
        ZStack {
            Color("NoorSurface")
            if isPerfectlyAligned {
                RadialGradient(
                    colors: [Color(hex: "#2E8B42").opacity(0.18), Color.clear],
                    center: .center, startRadius: 60, endRadius: 320
                )
                .animation(.easeInOut(duration: 1.0), value: isPerfectlyAligned)
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(spacing: 2) {
                HStack(spacing: 5) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundStyle(Color(hex: "#2E8B42"))
                    Text(qibla.locationName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                if !qibla.distanceToMakkah.isEmpty {
                    Text(qibla.distanceToMakkah)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            calibrationIndicator
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var calibrationIndicator: some View {
        Group {
            if showCalibrationCheck {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    Text("Calibrated").font(.caption.weight(.medium)).foregroundStyle(.green)
                }
                .transition(.scale.combined(with: .opacity))
            } else if qibla.isCalibrated {
                HStack(spacing: 4) {
                    Circle().fill(Color.green).frame(width: 7, height: 7)
                    Text("Accurate").font(.caption2).foregroundStyle(.secondary)
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
                .frame(width: 7, height: 7)
                .overlay(
                    Circle()
                        .stroke(Color.orange.opacity(0.4), lineWidth: 3)
                        .scaleEffect(alignmentPulse ? 1.8 : 1.0)
                        .opacity(alignmentPulse ? 0 : 1)
                        .animation(.easeOut(duration: 1.2).repeatForever(autoreverses: false), value: alignmentPulse)
                )
                .onAppear { alignmentPulse = true }
            Text("Calibrating").font(.caption2).foregroundStyle(.secondary)
        }
    }

    // MARK: - Compass Dial (full-bleed, no card box)
    private var compassDialView: some View {
        ZStack {
            outerRing
            cardinalLabels
            qiblaNeedle
            centerKaaba
        }
        .frame(width: 290, height: 290)
        .rotationEffect(.degrees(-qibla.heading))
        .animation(.interpolatingSpring(stiffness: 80, damping: 12), value: qibla.heading)
        .padding(.vertical, 8)
    }

    private var outerRing: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "#2E8B42").opacity(0.5), Color(hex: "#C8A951").opacity(0.3), Color(hex: "#2E8B42").opacity(0.5)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ), lineWidth: 2
                )
                .frame(width: 284, height: 284)
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 1)
                .frame(width: 262, height: 262)
                .opacity(0.6)
            ForEach(0..<72, id: \.self) { i in
                let isMajor = i % 18 == 0
                let isMid = i % 9 == 0
                Rectangle()
                    .fill(isMajor ? Color(hex: "#2E8B42") : (isMid ? Color(.systemGray3) : Color(.systemGray5)))
                    .frame(width: isMajor ? 2 : 1, height: isMajor ? 14 : (isMid ? 9 : 6))
                    .offset(y: -133)
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
            .offset(x: 108 * sin(rad), y: -108 * cos(rad))
    }

    private var qiblaNeedle: some View {
        let needleAngle = qibla.qiblaDirection
        return ZStack(alignment: .bottom) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#2E8B42").opacity(0.0), Color(hex: "#2E8B42").opacity(0.35)],
                        startPoint: .bottom, endPoint: .top
                    )
                )
                .frame(width: 6, height: 72)
                .blur(radius: 3)
                .offset(y: -16)
            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: "#2E8B42"), Color(hex: "#2E8B42").opacity(0.75)], startPoint: .top, endPoint: .bottom))
                .frame(width: 3.5, height: 68)
                .offset(y: -16)
            Image(systemName: "arrowtriangle.up.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(hex: "#2E8B42"))
                .offset(y: -82)
            Text("Qibla")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color(hex: "#2E8B42"))
                .offset(y: -102)
        }
        .rotationEffect(.degrees(needleAngle))
        .animation(.interpolatingSpring(stiffness: 70, damping: 11), value: needleAngle)
    }

    private var centerKaaba: some View {
        ZStack {
            Circle().fill(Color(hex: "#2E8B42").opacity(0.12)).frame(width: 60, height: 60)
            Circle().stroke(Color(hex: "#C8A951").opacity(0.5), lineWidth: 1.5).frame(width: 54, height: 54)
            Circle()
                .fill(cs == .dark ? Color(.systemGray6) : .white)
                .frame(width: 50, height: 50)
                .shadow(color: .black.opacity(0.08), radius: 4)
            Text("🕋").font(.system(size: 22))
                .rotationEffect(.degrees(qibla.heading))
        }
    }

    // MARK: - Bottom Pill (unified degree + instruction)
    private var bottomPill: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(String(format: "%.1f", qibla.qiblaDirection))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#2E8B42"))
                        .contentTransition(.numericText())
                    Text("°")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color(hex: "#2E8B42").opacity(0.7))
                        .baselineOffset(6)
                }
                Text(isPerfectlyAligned ? "✅ Perfect alignment" : "Face this direction to pray")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isPerfectlyAligned ? Color(hex: "#2E8B42") : .secondary)
                    .animation(.spring(response: 0.3), value: isPerfectlyAligned)
            }
            Spacer()
            ShareLink(
                item: "My Qibla direction is \(String(format: "%.1f°", qibla.qiblaDirection)) from \(qibla.locationName). \(qibla.distanceToMakkah). 🕋",
                subject: Text("My Qibla Direction"),
                message: Text("Shared via Noor")
            ) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                    Text("Share")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Color(hex: "#2E8B42"))
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
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            } else if !qibla.isCalibrated {
                Text("Move your phone in a figure-8 to calibrate")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                Text("\"Align your heart before your direction.\"")
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
