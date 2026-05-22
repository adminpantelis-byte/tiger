import AudioToolbox
import SwiftUI
import UIKit

extension Color {
    static func tigerHex(_ value: Int) -> Color {
        Color(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

enum TidePalette {
    static let ink = Color.tigerHex(0x150A2E)
    static let night = Color.tigerHex(0x27205D)
    static let lagoon = Color.tigerHex(0x00A5A8)
    static let mint = Color.tigerHex(0x4EE0A1)
    static let coral = Color.tigerHex(0xFF5B6E)
    static let mango = Color.tigerHex(0xFFC247)
    static let orchid = Color.tigerHex(0xB45CFF)
    static let sky = Color.tigerHex(0x55D6FF)
    static let glass = Color.white.opacity(0.16)
}

extension TigerTileKind {
    var tint: Color {
        switch self {
        case .ember: return TidePalette.coral
        case .lotus: return Color.tigerHex(0xFF8AC8)
        case .shell: return Color.tigerHex(0xFFE7A6)
        case .bamboo: return TidePalette.mint
        case .moon: return TidePalette.sky
        case .coin: return TidePalette.mango
        }
    }
}

struct FestivalBackground: View {
    var level: Int

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let rect = CGRect(origin: .zero, size: size)
                context.fill(
                    Path(rect),
                    with: .linearGradient(
                        Gradient(colors: [
                            .tigerHex(0x30206F),
                            .tigerHex(0x008A94),
                            .tigerHex(0x5F174D)
                        ]),
                        startPoint: .zero,
                        endPoint: CGPoint(x: size.width, y: size.height)
                    )
                )

                let sun = CGRect(x: size.width * 0.16, y: size.height * 0.08, width: size.width * 0.7, height: size.width * 0.7)
                context.fill(
                    Path(ellipseIn: sun),
                    with: .radialGradient(
                        Gradient(colors: [TidePalette.mango.opacity(0.72), TidePalette.coral.opacity(0.2), .clear]),
                        center: CGPoint(x: sun.midX, y: sun.midY),
                        startRadius: 8,
                        endRadius: sun.width / 2
                    )
                )

                let time = timeline.date.timeIntervalSinceReferenceDate
                for index in 0..<36 {
                    let baseX = CGFloat((index * 61 + level * 17) % max(1, Int(size.width)))
                    let drift = CGFloat((time * Double(20 + index % 9)).truncatingRemainder(dividingBy: Double(size.height + 120)))
                    let y = (CGFloat(index * 83) + drift).truncatingRemainder(dividingBy: size.height + 120) - 60
                    let isCoin = index.isMultiple(of: 4)
                    let symbolRect = CGRect(x: baseX, y: y, width: isCoin ? 11 : 8, height: isCoin ? 11 : 8)
                    if isCoin {
                        context.fill(Path(ellipseIn: symbolRect), with: .color(.tigerHex(0xFFE15A).opacity(0.84)))
                        context.stroke(Path(ellipseIn: symbolRect), with: .color(.white.opacity(0.32)), lineWidth: 1)
                    } else {
                        context.fill(Path(ellipseIn: symbolRect), with: .color(.tigerHex(0xFFB2C9).opacity(0.74)))
                    }
                }

                var roof = Path()
                roof.move(to: CGPoint(x: -20, y: size.height * 0.25))
                roof.addQuadCurve(to: CGPoint(x: size.width + 20, y: size.height * 0.25), control: CGPoint(x: size.width / 2, y: size.height * 0.13))
                roof.addLine(to: CGPoint(x: size.width + 20, y: size.height * 0.34))
                roof.addQuadCurve(to: CGPoint(x: -20, y: size.height * 0.34), control: CGPoint(x: size.width / 2, y: size.height * 0.25))
                roof.closeSubpath()
                context.fill(roof, with: .linearGradient(Gradient(colors: [TidePalette.lagoon, TidePalette.ink]), startPoint: .zero, endPoint: CGPoint(x: size.width, y: 0)))
                context.stroke(roof, with: .color(TidePalette.mango.opacity(0.8)), lineWidth: 3)
            }
            .ignoresSafeArea()
        }
    }
}

struct TigerButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [tint.opacity(0.95), tint.opacity(0.66)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.white.opacity(0.28), lineWidth: 1))
            .shadow(color: tint.opacity(0.35), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct TigerTitle: View {
    var body: some View {
        Text("TIGER LAGOON")
            .font(.system(size: 39, weight: .black, design: .rounded))
        .foregroundStyle(.white)
        .shadow(color: TidePalette.mango, radius: 8)
        .shadow(color: TidePalette.orchid, radius: 2)
    }
}

struct TigerAvatar: View {
    let focused: Bool

    var body: some View {
        Image("LagoonLogo")
            .resizable()
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: focused ? 28 : 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: focused ? 28 : 22, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [.white.opacity(0.9), .tigerHex(0xFFE15A).opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: focused ? 3 : 1.5
                    )
            )
            .shadow(color: TidePalette.mango.opacity(focused ? 0.48 : 0.22), radius: focused ? 14 : 6, y: focused ? 5 : 2)
    }
}

struct TideChip: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
            Text(title.uppercased())
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.76))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(tint.opacity(0.7), lineWidth: 1))
    }
}

struct ProgressStrip: View {
    let title: String
    let value: String
    let progress: Double
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title.uppercased())
                Spacer()
                Text(value)
            }
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(.white.opacity(0.9))

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(TidePalette.ink.opacity(0.34))
                    Capsule()
                        .fill(LinearGradient(colors: [tint, TidePalette.mango], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(8, proxy.size.width * min(1, max(0, progress))))
                }
            }
            .frame(height: 9)
        }
    }
}

struct TideTileView: View {
    let entry: PositionedTigerTile
    let tiger: Bool
    let selected: Bool
    let highlighted: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(entry.tile.flooded ? TidePalette.ink.opacity(0.86) : entry.tile.kind.tint.opacity(0.32))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(highlighted ? TidePalette.mango : .white.opacity(selected ? 0.55 : 0.14), lineWidth: highlighted ? 3 : 1)
                )
                .shadow(color: entry.tile.kind.tint.opacity(highlighted ? 0.7 : 0.14), radius: highlighted ? 8 : 2)

            if tiger {
                TigerAvatar(focused: selected)
                    .padding(6)
            } else {
                Image(systemName: entry.tile.kind.symbol)
                    .font(.system(size: 23, weight: .black))
                    .foregroundStyle(entry.tile.flooded ? .white.opacity(0.35) : entry.tile.kind.tint)
                    .scaleEffect(highlighted ? 1.14 : 1)

                if entry.tile.marked {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.85))
                        .offset(x: 15, y: 15)
                }
            }
        }
    }
}

struct TrailCard: View {
    let trail: TideTrail

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(trail.name.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                Spacer()
                Text("+\(trail.reward)")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(TidePalette.mango)
            }

            HStack(spacing: 5) {
                ForEach(Array(trail.needs.enumerated()), id: \.offset) { index, kind in
                    Image(systemName: kind.symbol)
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(kind.tint)
                        .frame(width: 21, height: 21)
                        .background(.white.opacity(index < trail.progress ? 0.08 : 0.17), in: RoundedRectangle(cornerRadius: 7))
                        .opacity(index < trail.progress ? 0.35 : 1)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TidePalette.ink.opacity(0.36), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(TidePalette.mango.opacity(0.28), lineWidth: 1))
    }
}

struct CoinPill: View {
    let value: Int

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "circle.hexagongrid.fill")
            Text("\(value)")
                .font(.system(size: 16, weight: .black, design: .rounded))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(TidePalette.ink.opacity(0.38), in: Capsule())
        .overlay(Capsule().stroke(TidePalette.mango.opacity(0.55), lineWidth: 1))
    }
}

struct StarRating: View {
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < count ? "star.fill" : "star")
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(index < count ? TidePalette.mango : .white.opacity(0.35))
                    .scaleEffect(index < count ? 1.05 : 1)
            }
        }
    }
}

final class GameFeedback {
    static let shared = GameFeedback()
    private let soundKey = "tigerLagoonSoundEnabled"

    var soundEnabled: Bool {
        if UserDefaults.standard.object(forKey: soundKey) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: soundKey)
    }

    func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        playSound(1104)
    }

    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        playSound(1053)
    }

    func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func playSound(_ id: SystemSoundID) {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(id)
    }
}
