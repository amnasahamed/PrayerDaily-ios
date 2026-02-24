import SwiftUI
import CoreLocation
import Combine

// MARK: - Qibla Manager
class QiblaManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var qiblaDirection: Double = 0
    @Published var heading: Double = 0
    @Published var hasLocation = false
    @Published var hasHeading = false
    @Published var locationError: String?
    @Published var locationName: String = "Detecting..."
    @Published var distanceToMakkah: String = ""

    private let locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    private let kaabaLat = 21.4225
    private let kaabaLon = 39.8262

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 1
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
        hasHeading = true
        heading = newHeading.magneticHeading
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = "Location unavailable. Please enable Location Services."
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
        if dist > 1000 {
            distanceToMakkah = String(format: "%.0f km to Makkah", dist)
        } else {
            distanceToMakkah = String(format: "%.1f km to Makkah", dist)
        }
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

private extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }
}

// MARK: - Qibla Compass View
struct QiblaCompassView: View {
    @StateObject private var qibla = QiblaManager()
    @Environment(\.colorScheme) var cs

    private var rotationAngle: Double { -(qibla.heading - qibla.qiblaDirection) }

    var body: some View {
        ZStack {
            backgroundGradient
            VStack(spacing: 24) {
                locationInfoCard
                compassBody
                directionInfoCard
            }
            .padding(.horizontal, AppTheme.screenPadding)
        }
        .navigationTitle("Qibla Compass")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { qibla.start() }
        .onDisappear { qibla.stop() }
    }

    // MARK: - Background
    private var backgroundGradient: some View {
        Color("NoorSurface").ignoresSafeArea()
    }

    // MARK: - Location Info
    private var locationInfoCard: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundStyle(Color("NoorPrimary"))
                Text(qibla.locationName)
                    .font(.subheadline.weight(.medium))
            }
            if !qibla.distanceToMakkah.isEmpty {
                Text(qibla.distanceToMakkah)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .noorCard()
    }

    // MARK: - Compass
    private var compassBody: some View {
        ZStack {
            outerRing
            cardinalDirections
            compassNeedle
            centerKaaba
        }
        .frame(width: 280, height: 280)
        .rotationEffect(.degrees(-qibla.heading))
        .animation(.easeInOut(duration: 0.3), value: qibla.heading)
    }

    private var outerRing: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 2)
                .frame(width: 270, height: 270)
            ForEach(0..<72, id: \.self) { i in
                let isMajor = i % 18 == 0
                Rectangle()
                    .fill(isMajor ? Color.primary : Color(.systemGray4))
                    .frame(width: isMajor ? 2 : 1, height: isMajor ? 14 : 8)
                    .offset(y: -127)
                    .rotationEffect(.degrees(Double(i) * 5))
            }
        }
    }

    private var cardinalDirections: some View {
        ZStack {
            compassLabel("N", angle: 0, color: .red)
            compassLabel("E", angle: 90, color: .primary)
            compassLabel("S", angle: 180, color: .primary)
            compassLabel("W", angle: 270, color: .primary)
        }
    }

    private func compassLabel(_ text: String, angle: Double, color: Color) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .offset(y: -105)
            .rotationEffect(.degrees(angle))
            .rotationEffect(.degrees(-angle))
            .offset(
                x: 105 * sin(angle * .pi / 180),
                y: -105 * cos(angle * .pi / 180)
            )
            .offset(y: 105)
    }

    private var compassNeedle: some View {
        VStack(spacing: 0) {
            Image(systemName: "arrowtriangle.up.fill")
                .font(.title2)
                .foregroundStyle(Color("NoorPrimary"))
            Rectangle()
                .fill(Color("NoorPrimary"))
                .frame(width: 3, height: 60)
        }
        .offset(y: -40)
        .rotationEffect(.degrees(qibla.qiblaDirection))
        .animation(.easeInOut(duration: 0.3), value: qibla.qiblaDirection)
    }

    private var centerKaaba: some View {
        ZStack {
            Circle()
                .fill(Color("NoorPrimary").opacity(0.15))
                .frame(width: 56, height: 56)
            Circle()
                .fill(cs == .dark ? Color(.systemGray6) : .white)
                .frame(width: 48, height: 48)
            Text("🕋")
                .font(.title2)
                .rotationEffect(.degrees(qibla.heading))
        }
    }

    // MARK: - Direction Info
    private var directionInfoCard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundStyle(Color("NoorPrimary"))
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(.easeInOut(duration: 0.3), value: rotationAngle)
                Text("Qibla Direction")
                    .font(.subheadline.weight(.semibold))
            }
            Text(String(format: "%.1f°", qibla.qiblaDirection))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Color("NoorPrimary"))
            accuracyIndicator
            if let error = qibla.locationError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .noorCard()
    }

    private var accuracyIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(qibla.hasHeading ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            Text(qibla.hasHeading ? "Compass calibrated" : "Calibrating compass...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
