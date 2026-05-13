import SwiftUI

struct TigerTideGameView: View {
    let level: TigerLevel
    let bonusMoves: Int
    let bonusFocus: Int
    @Binding var roarInventory: Int
    @Binding var beaconInventory: Int
    var onExit: () -> Void = {}
    var onLevelComplete: (TigerLevelResult) -> Void = { _ in }
    var onNextLevel: () -> Void = {}

    @State private var game: TigerTideGame
    @State private var beaconMode = false
    @State private var message = "LEAP UP TO TWO TILES"
    @State private var selected: TidePoint?
    @State private var highlights: Set<TidePoint> = []
    @State private var victory: TigerLevelResult?
    @State private var defeat = false
    @State private var winPulse = false
    @State private var idleSeconds = 0

    init(
        level: TigerLevel,
        bonusMoves: Int,
        bonusFocus: Int,
        roarInventory: Binding<Int>,
        beaconInventory: Binding<Int>,
        onExit: @escaping () -> Void = {},
        onLevelComplete: @escaping (TigerLevelResult) -> Void = { _ in },
        onNextLevel: @escaping () -> Void = {}
    ) {
        self.level = level
        self.bonusMoves = bonusMoves
        self.bonusFocus = bonusFocus
        self._roarInventory = roarInventory
        self._beaconInventory = beaconInventory
        self.onExit = onExit
        self.onLevelComplete = onLevelComplete
        self.onNextLevel = onNextLevel
        self._game = State(initialValue: TigerTideGame(level: level, bonusMoves: bonusMoves, bonusFocus: bonusFocus))
    }

    var body: some View {
        ZStack {
            FestivalBackground(level: level.id)

            VStack(spacing: 8) {
                topBar
                compactStatus
                board
                controls
                messageBar
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .blur(radius: victory == nil && defeat == false ? 0 : 1.5)

            if let victory {
                VictoryOverlay(result: victory, pulse: winPulse, onHome: onExit, onNext: onNextLevel)
                    .transition(.scale.combined(with: .opacity))
            }

            if defeat {
                DefeatOverlay(level: level, score: game.score, trails: game.trailsOpened, targetTrails: level.targetTrails, onRetry: restartLevel, onHome: onExit)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: level.id) { _ in
            restartLevel()
        }
        .task(id: level.id) {
            await runIdleHintLoop()
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            Button("HOME") { onExit() }
                .buttonStyle(TigerButtonStyle(tint: .tigerHex(0xC7193B)))
                .frame(width: 92)

            Spacer()
            Text("TIGERS TIDE")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: Color.tigerHex(0xFFE15A), radius: 8)
            Spacer()

            Button {
                restartLevel()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(TigerButtonStyle(tint: .tigerHex(0x12A86B)))
            .frame(width: 56)
        }
    }

    private var compactStatus: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                TigerAvatar(focused: game.focus >= 6)
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text("LEVEL \(level.id)")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(Color.tigerHex(0xFFE15A))
                    Text(level.title.uppercased())
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                Spacer()

                TideChip(title: "Moves", value: "\(game.moves)", tint: .tigerHex(0x12A86B))
                    .frame(width: 76)
                TideChip(title: "Trails", value: "\(game.trailsOpened)/\(level.targetTrails)", tint: .tigerHex(0xFF6FB1))
                    .frame(width: 76)
            }

            HStack(spacing: 10) {
                ProgressStrip(title: "Score", value: "\(game.score)/\(level.targetScore)", progress: game.scoreProgress, tint: .tigerHex(0xFF5A36))
                ProgressStrip(title: "Trail", value: "\(game.trailsOpened)/\(level.targetTrails)", progress: game.trailProgress, tint: .tigerHex(0x12A86B))
            }

            HStack(spacing: 6) {
                ForEach(game.trails) { trail in
                    Button {
                        showTrailHint(trail)
                    } label: {
                        TrailCard(trail: trail)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(10)
        .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.tigerHex(0xFFE15A).opacity(0.32), lineWidth: 1))
    }

    private var board: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 6
            let side = min(proxy.size.width, proxy.size.height)
            let cell = (side - spacing * CGFloat(game.width - 1) - 12) / CGFloat(game.width)
            let origin = CGPoint(x: (proxy.size.width - side) / 2 + 6 + cell / 2, y: (proxy.size.height - side) / 2 + 6 + cell / 2)

            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.black.opacity(0.2))
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.tigerHex(0xFFE15A).opacity(0.45), lineWidth: 2))
                    .frame(width: side, height: side)

                ForEach(game.positionedTiles) { entry in
                    Button {
                        tap(entry.point)
                    } label: {
                        TideTileView(
                            entry: entry,
                            tiger: entry.point == game.tiger,
                            selected: selected == entry.point,
                            highlighted: highlights.contains(entry.point)
                        )
                        .frame(width: cell, height: cell)
                    }
                    .buttonStyle(.plain)
                    .disabled(victory != nil || defeat)
                    .position(
                        x: origin.x + CGFloat(entry.point.x) * (cell + spacing),
                        y: origin.y + CGFloat(entry.point.y) * (cell + spacing)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .layoutPriority(2)
    }

    private var controls: some View {
        HStack(spacing: 8) {
            Button("ROAR \(game.roarCharges + roarInventory)") {
                useRoar()
            }
            .buttonStyle(TigerButtonStyle(tint: .tigerHex(0xFF5A36)))

            Button(beaconMode ? "PLACE" : "BEACON \(game.beaconCharges + beaconInventory)") {
                beaconMode.toggle()
                message = beaconMode ? "TAP A TILE TO ANCHOR IT" : "LEAP UP TO TWO TILES"
            }
            .buttonStyle(TigerButtonStyle(tint: .tigerHex(0x60D6F5)))
        }
        .disabled(victory != nil || defeat)
    }

    private var messageBar: some View {
        Text(message)
            .font(.system(size: 14, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(.black.opacity(0.26), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func tap(_ point: TidePoint) {
        selected = point
        idleSeconds = 0

        if beaconMode {
            placeBeacon(at: point)
            return
        }

        do {
            apply(try game.leap(to: point))
        } catch TigerMoveError.flooded {
            message = "THAT TILE IS UNDERWATER"
            GameFeedback.shared.error()
        } catch TigerMoveError.tooFar {
            message = "LEAP ONE OR TWO TILES"
            GameFeedback.shared.error()
        } catch TigerMoveError.levelOver {
            showDefeat()
            GameFeedback.shared.error()
        } catch {
            message = "THE TIDE BLOCKS THAT MOVE"
            GameFeedback.shared.error()
        }
    }

    private func useRoar() {
        guard victory == nil, defeat == false, game.moves > 0 else { return }

        if game.roarCharges == 0, roarInventory > 0 {
            roarInventory -= 1
            game.addRoarCharge()
        }

        do {
            idleSeconds = 0
            apply(try game.roar())
        } catch {
            message = "NO ROAR CHARGES"
            GameFeedback.shared.error()
        }
    }

    private func placeBeacon(at point: TidePoint) {
        guard victory == nil, defeat == false else { return }

        if game.beaconCharges == 0, beaconInventory > 0 {
            beaconInventory -= 1
            game.addBeaconCharge()
        }

        do {
            idleSeconds = 0
            apply(try game.placeBeacon(at: point))
        } catch {
            message = "NO BEACONS READY"
            GameFeedback.shared.error()
        }
        beaconMode = false
    }

    private func apply(_ outcome: TigerOutcome) {
        message = outcome.message
        highlights = outcome.highlights

        if let completed = outcome.completedLevel {
            complete(completed)
            return
        }

        if game.moves == 0, (game.trailsOpened < level.targetTrails || game.score < level.targetScore) {
            showDefeat()
            return
        }

        if outcome.scoreDelta > 0 || outcome.coinDelta > 0 {
            GameFeedback.shared.success()
        } else {
            GameFeedback.shared.light()
        }
    }

    private func complete(_ result: TigerLevelResult) {
        guard victory == nil else { return }
        onLevelComplete(result)
        GameFeedback.shared.success()
        withAnimation(.spring(response: 0.6, dampingFraction: 0.72)) {
            victory = result
            winPulse = true
        }
    }

    private func showDefeat() {
        guard defeat == false, victory == nil else { return }
        GameFeedback.shared.error()
        withAnimation(.spring(response: 0.52, dampingFraction: 0.78)) {
            defeat = true
            message = "OUT OF MOVES"
        }
    }

    private func showTrailHint(_ trail: TideTrail) {
        idleSeconds = 0
        guard let need = trail.currentNeed else {
            message = "\(trail.name.uppercased()) IS READY"
            highlights = []
            return
        }

        let targets = game.positionedTiles
            .filter { $0.tile.kind == need && $0.tile.flooded == false }
            .map(\.point)
        highlights = Set(targets)
        message = "\(trail.name.uppercased()): NEXT \(need.rawValue.uppercased())"
        GameFeedback.shared.light()
    }

    private func showSmartHint() {
        if let trail = game.trails.first(where: { $0.currentNeed != nil }) {
            showTrailHint(trail)
        } else {
            message = "TAP A TRAIL CARD FOR THE NEXT RUNE"
        }
    }

    private func restartLevel() {
        game.start(level: level, bonusMoves: bonusMoves, bonusFocus: bonusFocus)
        message = "LEAP UP TO TWO TILES"
        highlights = []
        selected = nil
        beaconMode = false
        victory = nil
        defeat = false
        winPulse = false
        idleSeconds = 0
    }

    @MainActor
    private func runIdleHintLoop() async {
        while Task.isCancelled == false {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            guard Task.isCancelled == false else { return }
            guard victory == nil, defeat == false else { continue }
            idleSeconds += 1
            if idleSeconds == 8 {
                showSmartHint()
            }
        }
    }
}

struct DefeatOverlay: View {
    let level: TigerLevel
    let score: Int
    let trails: Int
    let targetTrails: Int
    let onRetry: () -> Void
    let onHome: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.48).ignoresSafeArea()

            VStack(spacing: 16) {
                TigerAvatar(focused: false)
                    .frame(width: 112, height: 112)

                VStack(spacing: 5) {
                    Text("TRY AGAIN")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.45), radius: 6)
                    Text("Level \(level.id) needs more trail work")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(Color.tigerHex(0xFFE15A))
                }

                VStack(spacing: 8) {
                    Text("Moves are over. Collect trail runes in order, then finish the score goal.")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.86))
                        .multilineTextAlignment(.center)
                    Text("Score \(score)/\(level.targetScore) • Trails \(trails)/\(targetTrails)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                }

                Button("RETRY LEVEL") { onRetry() }
                    .buttonStyle(TigerButtonStyle(tint: .tigerHex(0xFF5A36)))

                Button("HOME") { onHome() }
                    .buttonStyle(TigerButtonStyle(tint: .tigerHex(0xC7193B)))
            }
            .padding(22)
            .background(
                LinearGradient(colors: [.tigerHex(0x7A1234), .tigerHex(0x1F0920)], startPoint: .top, endPoint: .bottom),
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.tigerHex(0xFFE15A).opacity(0.7), lineWidth: 2))
            .padding(24)
        }
    }
}

struct VictoryOverlay: View {
    let result: TigerLevelResult
    let pulse: Bool
    let onHome: () -> Void
    let onNext: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.44).ignoresSafeArea()

            VStack(spacing: 16) {
                TigerAvatar(focused: true)
                    .frame(width: 118, height: 118)
                    .scaleEffect(pulse ? 1.04 : 0.96)

                VStack(spacing: 4) {
                    Text(starStatus)
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(Color.tigerHex(0xFFE15A))
                        .shadow(color: Color.tigerHex(0xFF5A36), radius: 8)
                    Text("Level \(result.level.id) Complete")
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }

                StarRating(count: result.stars)

                VStack(spacing: 8) {
                    Text("Congratulations! The tide path is open.")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.86))
                        .multilineTextAlignment(.center)
                    Text("+\(result.coins) COINS")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.tigerHex(0xFFE15A))
                    Text("Score \(result.score) • Trails \(result.trailsOpened)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                }

                Button("NEXT LEVEL") { onNext() }
                    .buttonStyle(TigerButtonStyle(tint: .tigerHex(0x12A86B)))

                Button("HOME") { onHome() }
                    .buttonStyle(TigerButtonStyle(tint: .tigerHex(0xC7193B)))
            }
            .padding(22)
            .background(
                LinearGradient(colors: [.tigerHex(0xF33248), .tigerHex(0x64124A)], startPoint: .top, endPoint: .bottom),
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.tigerHex(0xFFE15A), lineWidth: 2))
            .padding(24)
        }
    }

    private var starStatus: String {
        switch result.stars {
        case 3: return "3 STARS"
        case 2: return "2 STARS"
        default: return "1 STAR"
        }
    }
}
