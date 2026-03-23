import SwiftUI
import CoreLocation

struct CompactQiblaCard: View {
    @StateObject private var qibla = QiblaManager()
    @Environment(\.colorScheme) var cs
    @EnvironmentObject var localization: LocalizationManager
    @State private var needleRotation: Double = 0

    var body: some View {
        VStack(spacing: 10) {
            cardHeader
            compassVisual
            directionLabel
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(cardBorder)
        .shadow(color: .black.opacity(0.05), radius: 14, y: 5)
        .onAppear { qibla.start() }
        .onDisappear { qibla.stop() }
        .onChange(of: qibla.heading) { _, _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                needleRotation = -(qibla.heading - qibla.qiblaDirection)
            }
        }
    }

    private var cardHeader: some View {
        HStack(spacing: 5) {
            Image(systemName: "location.north.fill")
                .foregroundStyle(Color.alehaGreen)
                .font(.system(size: 12))
            Text(localization.t(.qiblaTitle))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var compassVisual: some View {
        ZStack {
            // outer ring
            Circle()
                .stroke(Color.alehaGreen.opacity(0.15), lineWidth: 3)
                .frame(width: 76, height: 76)
            // tick marks
            ForEach(0..<12, id: \.self) { i in
                let isMajor = i % 3 == 0
                Rectangle()
                    .fill(isMajor ? Color.alehaGreen.opacity(0.5) : Color(.systemGray4))
                    .frame(width: isMajor ? 1.5 : 1, height: isMajor ? 6 : 4)
                    .offset(y: -34)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
            // needle
            needleView
            // center kaaba
            ZStack {
                Circle()
                    .fill(Color.alehaGreen.opacity(0.12))
                    .frame(width: 24, height: 24)
                Image(systemName: "building.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.alehaGreen)
            }
        }
        .frame(width: 80, height: 80)
    }

    private var needleView: some View {
        VStack(spacing: 0) {
            Triangle()
                .fill(Color.alehaGreen)
                .frame(width: 8, height: 10)
            Rectangle()
                .fill(Color.alehaGreen)
                .frame(width: 2, height: 16)
        }
        .offset(y: -16)
        .rotationEffect(.degrees(needleRotation))
    }

    private var directionLabel: some View {
        Group {
            if qibla.hasLocation {
                Text(String(format: "%.0f°", qibla.qiblaDirection))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.alehaGreen)
            } else {
                Text(localization.t(.homeLocating))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var cardBg: some ShapeStyle {
        cs == .dark
            ? AnyShapeStyle(Color.white.opacity(0.07))
            : AnyShapeStyle(Color.white.opacity(0.88))
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
            .stroke(cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6), lineWidth: 0.5)
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

