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

extension TigerTileKind {
    var tint: Color {
        switch self {
        case .ember: return .tigerHex(0xFF4B22)
        case .lotus: return .tigerHex(0xFF77B8)
        case .shell: return .tigerHex(0xFFE18A)
        case .bamboo: return .tigerHex(0x39C96B)
        case .moon: return .tigerHex(0x6BD8FF)
        case .coin: return .tigerHex(0xFFD447)
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
                            .tigerHex(0xFF3A22),
                            .tigerHex(0xB61022),
                            .tigerHex(0x5B0733)
                        ]),
                        startPoint: .zero,
                        endPoint: CGPoint(x: size.width, y: size.height)
                    )
                )

                let sun = CGRect(x: size.width * 0.16, y: size.height * 0.08, width: size.width * 0.7, height: size.width * 0.7)
                context.fill(
                    Path(ellipseIn: sun),
                    with: .radialGradient(
                        Gradient(colors: [.tigerHex(0xFFE66D).opacity(0.78), .tigerHex(0xFF8E2B).opacity(0.18), .clear]),
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
                        context.fill(Path(ellipseIn: symbolRect), with: .color(.tigerHex(0xFFD447).opacity(0.84)))
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
                context.fill(roof, with: .linearGradient(Gradient(colors: [.tigerHex(0x16A05C), .tigerHex(0x04713C)]), startPoint: .zero, endPoint: CGPoint(x: size.width, y: 0)))
                context.stroke(roof, with: .color(.tigerHex(0xFFD447).opacity(0.8)), lineWidth: 3)
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
                LinearGradient(colors: [tint, tint.opacity(0.72)], startPoint: .top, endPoint: .bottom),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.white.opacity(0.28), lineWidth: 1))
            .shadow(color: tint.opacity(0.35), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct TigerTitle: View {
    var body: some View {
        Text("TIGER TIDE")
            .font(.system(size: 39, weight: .black, design: .rounded))
        .foregroundStyle(.white)
        .shadow(color: Color.tigerHex(0xFFD447), radius: 8)
        .shadow(color: Color.tigerHex(0xC21522), radius: 2)
    }
}

struct TigerAvatar: View {
    let focused: Bool

    var body: some View {
        Image("TigerLogo")
            .resizable()
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: focused ? 28 : 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: focused ? 28 : 22, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [.white.opacity(0.9), .tigerHex(0xFFD447).opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: focused ? 3 : 1.5
                    )
            )
            .shadow(color: Color.tigerHex(0xFFD447).opacity(focused ? 0.48 : 0.22), radius: focused ? 14 : 6, y: focused ? 5 : 2)
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
                    Capsule().fill(.black.opacity(0.28))
                    Capsule()
                        .fill(LinearGradient(colors: [tint, .tigerHex(0xFFD447)], startPoint: .leading, endPoint: .trailing))
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
                .fill(entry.tile.flooded ? Color.tigerHex(0x5E1021).opacity(0.86) : entry.tile.kind.tint.opacity(0.31))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(highlighted ? Color.tigerHex(0xFFD447) : .white.opacity(selected ? 0.55 : 0.14), lineWidth: highlighted ? 3 : 1)
                )
                .shadow(color: entry.tile.kind.tint.opacity(highlighted ? 0.7 : 0.14), radius: highlighted ? 8 : 2)

            if tiger {
                TigerAvatar(focused: selected)
                    .padding(6)
            } else {
                Image(systemName: entry.tile.kind.symbol)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(entry.tile.flooded ? .white.opacity(0.35) : entry.tile.kind.tint)

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
                    .foregroundStyle(Color.tigerHex(0xFFD447))
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
        .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(Color.tigerHex(0xFFD447).opacity(0.25), lineWidth: 1))
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
        .background(.black.opacity(0.25), in: Capsule())
        .overlay(Capsule().stroke(Color.tigerHex(0xFFD447).opacity(0.55), lineWidth: 1))
    }
}

struct StarRating: View {
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < count ? "star.fill" : "star")
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(index < count ? Color.tigerHex(0xFFD447) : .white.opacity(0.35))
            }
        }
    }
}

final class GameFeedback {
    static let shared = GameFeedback()
    private let soundKey = "tigerTideSoundEnabled"

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
