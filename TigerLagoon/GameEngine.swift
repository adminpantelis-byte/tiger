import Foundation

enum TigerTileKind: String, CaseIterable, Identifiable {
    case ember
    case lotus
    case shell
    case bamboo
    case moon
    case coin

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .ember: return "sparkles"
        case .lotus: return "camera.macro"
        case .shell: return "seal.fill"
        case .bamboo: return "leaf.fill"
        case .moon: return "moon.stars.fill"
        case .coin: return "circle.hexagongrid.fill"
        }
    }
}

struct TidePoint: Hashable {
    let x: Int
    let y: Int

    func distance(to other: TidePoint) -> Int {
        abs(x - other.x) + abs(y - other.y)
    }
}

struct TigerTile: Identifiable, Equatable {
    let id = UUID()
    var kind: TigerTileKind
    var flooded: Bool = false
    var marked: Bool = false
}

struct PositionedTigerTile: Identifiable {
    let point: TidePoint
    let tile: TigerTile

    var id: UUID { tile.id }
}

struct TideTrail: Identifiable {
    let id = UUID()
    let name: String
    let needs: [TigerTileKind]
    var progress: Int
    let reward: Int

    var currentNeed: TigerTileKind? {
        guard progress < needs.count else { return nil }
        return needs[progress]
    }
}

struct TigerLevel: Identifiable, Equatable {
    let id: Int
    let title: String
    let subtitle: String
    let targetScore: Int
    let targetTrails: Int
    let moves: Int
    let reward: Int
    let startingRoars: Int
    let startingBeacons: Int
    let floodModulo: Int

    static let campaign: [TigerLevel] = [
        TigerLevel(id: 1, title: "Lantern Gate", subtitle: "Open the first tide path.", targetScore: 220, targetTrails: 1, moves: 24, reward: 32, startingRoars: 1, startingBeacons: 2, floodModulo: 6),
        TigerLevel(id: 2, title: "Cherry Bridge", subtitle: "Follow the petals over the tide.", targetScore: 340, targetTrails: 2, moves: 25, reward: 42, startingRoars: 1, startingBeacons: 2, floodModulo: 6),
        TigerLevel(id: 3, title: "Golden Drum", subtitle: "Keep focus while the water turns.", targetScore: 470, targetTrails: 2, moves: 24, reward: 54, startingRoars: 1, startingBeacons: 1, floodModulo: 5),
        TigerLevel(id: 4, title: "Firework Pier", subtitle: "Score quickly before the pier floods.", targetScore: 620, targetTrails: 3, moves: 26, reward: 68, startingRoars: 2, startingBeacons: 1, floodModulo: 5),
        TigerLevel(id: 5, title: "Jade Roof", subtitle: "Use beacons to build a safe route.", targetScore: 760, targetTrails: 3, moves: 25, reward: 84, startingRoars: 1, startingBeacons: 3, floodModulo: 5),
        TigerLevel(id: 6, title: "Red Envelope Run", subtitle: "Collect coin runes for the festival.", targetScore: 930, targetTrails: 4, moves: 27, reward: 100, startingRoars: 2, startingBeacons: 2, floodModulo: 4),
        TigerLevel(id: 7, title: "Temple Steps", subtitle: "The tide is sharper near the temple.", targetScore: 1120, targetTrails: 4, moves: 27, reward: 118, startingRoars: 2, startingBeacons: 2, floodModulo: 4),
        TigerLevel(id: 8, title: "Tiger Sky", subtitle: "A bright climb through coins.", targetScore: 1360, targetTrails: 5, moves: 28, reward: 140, startingRoars: 2, startingBeacons: 3, floodModulo: 4),
        TigerLevel(id: 9, title: "Lotus Market", subtitle: "Chain trails between crowded stalls.", targetScore: 1540, targetTrails: 5, moves: 28, reward: 154, startingRoars: 2, startingBeacons: 2, floodModulo: 4),
        TigerLevel(id: 10, title: "Crimson Canal", subtitle: "Floods arrive faster near the canal.", targetScore: 1740, targetTrails: 5, moves: 27, reward: 168, startingRoars: 2, startingBeacons: 2, floodModulo: 4),
        TigerLevel(id: 11, title: "Moon Gate", subtitle: "Moon runes lead the route forward.", targetScore: 1960, targetTrails: 6, moves: 29, reward: 184, startingRoars: 2, startingBeacons: 3, floodModulo: 4),
        TigerLevel(id: 12, title: "Lantern Rapids", subtitle: "Plan around quick water turns.", targetScore: 2200, targetTrails: 6, moves: 29, reward: 200, startingRoars: 2, startingBeacons: 2, floodModulo: 4),
        TigerLevel(id: 13, title: "Goldfish Court", subtitle: "Big scores need focused leaps.", targetScore: 2460, targetTrails: 6, moves: 30, reward: 218, startingRoars: 3, startingBeacons: 2, floodModulo: 4),
        TigerLevel(id: 14, title: "Bamboo Harbor", subtitle: "Anchor paths before the harbor floods.", targetScore: 2740, targetTrails: 7, moves: 30, reward: 236, startingRoars: 2, startingBeacons: 3, floodModulo: 3),
        TigerLevel(id: 15, title: "Pearl Stair", subtitle: "Every move needs a clean target.", targetScore: 3040, targetTrails: 7, moves: 31, reward: 256, startingRoars: 3, startingBeacons: 2, floodModulo: 3),
        TigerLevel(id: 16, title: "Dragon Boat", subtitle: "Ride the tide with longer plans.", targetScore: 3360, targetTrails: 7, moves: 31, reward: 276, startingRoars: 3, startingBeacons: 3, floodModulo: 3),
        TigerLevel(id: 17, title: "Ruby Shrine", subtitle: "Score and trails must rise together.", targetScore: 3700, targetTrails: 8, moves: 32, reward: 298, startingRoars: 3, startingBeacons: 3, floodModulo: 3),
        TigerLevel(id: 18, title: "Cloud Terrace", subtitle: "Use charms to protect extra moves.", targetScore: 4060, targetTrails: 8, moves: 32, reward: 320, startingRoars: 3, startingBeacons: 3, floodModulo: 3),
        TigerLevel(id: 19, title: "Fire Lily Bend", subtitle: "Fast water punishes loose jumps.", targetScore: 4440, targetTrails: 8, moves: 33, reward: 344, startingRoars: 3, startingBeacons: 4, floodModulo: 3),
        TigerLevel(id: 20, title: "Emerald Palace", subtitle: "Open many trails before the bell.", targetScore: 4840, targetTrails: 9, moves: 33, reward: 368, startingRoars: 3, startingBeacons: 3, floodModulo: 3),
        TigerLevel(id: 21, title: "Sunset Causeway", subtitle: "Late campaign goals are demanding.", targetScore: 5260, targetTrails: 9, moves: 34, reward: 394, startingRoars: 4, startingBeacons: 3, floodModulo: 3),
        TigerLevel(id: 22, title: "Crown Bridge", subtitle: "Clear hazards only when it matters.", targetScore: 5700, targetTrails: 9, moves: 34, reward: 420, startingRoars: 3, startingBeacons: 4, floodModulo: 3),
        TigerLevel(id: 23, title: "Star Drum Hall", subtitle: "Three-star play needs spare moves.", targetScore: 6160, targetTrails: 10, moves: 35, reward: 448, startingRoars: 4, startingBeacons: 4, floodModulo: 3),
        TigerLevel(id: 24, title: "Tiger Summit", subtitle: "Master every rune path.", targetScore: 6660, targetTrails: 10, moves: 36, reward: 500, startingRoars: 4, startingBeacons: 4, floodModulo: 3)
    ]
}

struct TigerLevelResult {
    let level: TigerLevel
    let score: Int
    let trailsOpened: Int
    let coins: Int
    let stars: Int
    let movesLeft: Int
    let maxCombo: Int
}

struct TigerOutcome {
    var scoreDelta: Int
    var coinDelta: Int
    var message: String
    var highlights: Set<TidePoint>
    var completedLevel: TigerLevelResult?
}

enum TigerMoveError: Error {
    case outsideBoard
    case tooFar
    case flooded
    case noCharge
    case levelOver
}

struct TigerLagoonGame {
    let width = 6
    let height = 6

    private(set) var level = TigerLevel.campaign[0]
    private(set) var score = 0
    private(set) var moves = 24
    private(set) var tide = 0
    private(set) var focus = 0
    private(set) var roarCharges = 1
    private(set) var beaconCharges = 2
    private(set) var trailsOpened = 0
    private(set) var coinsEarned = 0
    private(set) var combo = 0
    private(set) var maxCombo = 0
    private(set) var tiger = TidePoint(x: 2, y: 3)
    private(set) var trails: [TideTrail] = []
    private(set) var isComplete = false
    private var cells: [TigerTile] = []

    init(level: TigerLevel = TigerLevel.campaign[0], bonusMoves: Int = 0, bonusFocus: Int = 0) {
        start(level: level, bonusMoves: bonusMoves, bonusFocus: bonusFocus)
    }

    mutating func start(level: TigerLevel, bonusMoves: Int = 0, bonusFocus: Int = 0) {
        self.level = level
        score = 0
        moves = level.moves + bonusMoves
        tide = level.id % 4
        focus = bonusFocus
        roarCharges = level.startingRoars
        beaconCharges = level.startingBeacons
        trailsOpened = 0
        coinsEarned = 0
        combo = 0
        maxCombo = 0
        isComplete = false
        tiger = TidePoint(x: 2, y: 3)
        cells = []

        for y in 0..<height {
            for x in 0..<width {
                cells.append(TigerTile(kind: randomKind(avoiding: TidePoint(x: x, y: y), seed: level.id)))
            }
        }

        trails = initialTrails(for: level)
        redrawTide()
    }

    func tile(at point: TidePoint) -> TigerTile? {
        guard contains(point) else { return nil }
        return cells[index(point)]
    }

    var positionedTiles: [PositionedTigerTile] {
        var result: [PositionedTigerTile] = []
        for y in 0..<height {
            for x in 0..<width {
                let point = TidePoint(x: x, y: y)
                result.append(PositionedTigerTile(point: point, tile: cells[index(point)]))
            }
        }
        return result
    }

    var scoreProgress: Double {
        min(1, Double(score) / Double(level.targetScore))
    }

    var trailProgress: Double {
        min(1, Double(trailsOpened) / Double(level.targetTrails))
    }

    mutating func leap(to point: TidePoint) throws -> TigerOutcome {
        guard isComplete == false, moves > 0 else { throw TigerMoveError.levelOver }
        guard contains(point) else { throw TigerMoveError.outsideBoard }
        guard tiger.distance(to: point) <= 2, tiger.distance(to: point) > 0 else { throw TigerMoveError.tooFar }
        guard cells[index(point)].flooded == false else { throw TigerMoveError.flooded }

        tiger = point
        moves = max(0, moves - 1)

        let kind = cells[index(point)].kind
        cells[index(point)].marked = true

        let base = 14 + focus * 2 + (kind == .coin ? 5 : 0)
        score += base
        focus = min(12, focus + 1)
        tide = (tide + 1) % 4

        let trailReward = feedTrails(with: kind)
        if trailReward.progressed {
            combo = min(9, combo + 1)
            maxCombo = max(maxCombo, combo)
        } else {
            combo = 0
        }

        let comboBonus = trailReward.progressed ? combo * 6 : 0
        let coinBonus = kind == .coin && combo >= 2 ? 1 : 0
        score += trailReward.score + comboBonus
        coinsEarned += trailReward.coins + coinBonus

        redrawTide()
        let completed = completionIfReady()

        return TigerOutcome(
            scoreDelta: base + trailReward.score + comboBonus,
            coinDelta: trailReward.coins + coinBonus,
            message: completed == nil ? (trailReward.message ?? "\(kind.rawValue.uppercased()) TIDE MARK") : "LEVEL COMPLETE",
            highlights: [point],
            completedLevel: completed
        )
    }

    mutating func roar() throws -> TigerOutcome {
        guard isComplete == false, moves > 0 else { throw TigerMoveError.levelOver }
        guard roarCharges > 0 else { throw TigerMoveError.noCharge }
        roarCharges -= 1
        moves = max(0, moves - 1)

        var cleared: Set<TidePoint> = []
        for x in 0..<width {
            cleared.insert(TidePoint(x: x, y: tiger.y))
        }
        for y in 0..<height {
            cleared.insert(TidePoint(x: tiger.x, y: y))
        }

        for point in cleared {
            cells[index(point)] = TigerTile(kind: TigerTileKind.allCases.randomElement() ?? .moon)
        }

        let delta = cleared.count * 12
        score += delta
        focus = min(12, focus + 2)
        combo = 0
        tide = (tide + 2) % 4
        redrawTide()

        let completed = completionIfReady()
        return TigerOutcome(scoreDelta: delta, coinDelta: 0, message: completed == nil ? "TIGER ROAR CLEARED THE REEDS" : "LEVEL COMPLETE", highlights: cleared, completedLevel: completed)
    }

    mutating func placeBeacon(at point: TidePoint) throws -> TigerOutcome {
        guard isComplete == false else { throw TigerMoveError.levelOver }
        guard beaconCharges > 0 else { throw TigerMoveError.noCharge }
        guard contains(point) else { throw TigerMoveError.outsideBoard }

        beaconCharges -= 1
        cells[index(point)].flooded = false
        cells[index(point)].marked = true
        focus = min(12, focus + 1)

        return TigerOutcome(scoreDelta: 0, coinDelta: 0, message: "BEACON HOLDS BACK THE TIDE", highlights: [point], completedLevel: nil)
    }

    mutating func addRoarCharge() {
        roarCharges = min(6, roarCharges + 1)
    }

    mutating func addBeaconCharge() {
        beaconCharges = min(9, beaconCharges + 1)
    }

    mutating func addMoves(_ amount: Int) {
        moves += max(0, amount)
    }

    private mutating func feedTrails(with kind: TigerTileKind) -> (score: Int, coins: Int, progressed: Bool, message: String?) {
        for index in trails.indices {
            guard trails[index].currentNeed == kind else { continue }
            trails[index].progress += 1
            guard trails[index].progress == trails[index].needs.count else {
                return (0, 0, true, "\(trails[index].name.uppercased()) ADVANCES")
            }

            let reward = trails[index].reward
            let name = trails[index].name.uppercased()
            trailsOpened += 1
            trails[index] = makeTrail()
            return (reward, max(1, reward / 58), true, "\(name) OPENED")
        }
        return (0, 0, false, nil)
    }

    private mutating func completionIfReady() -> TigerLevelResult? {
        guard isComplete == false else { return nil }
        guard score >= level.targetScore, trailsOpened >= level.targetTrails else { return nil }

        isComplete = true
        let efficiencyBonus = max(0, moves / 7)
        let completionReward = max(6, level.reward / 7)
        let totalCoins = completionReward + coinsEarned + efficiencyBonus
        coinsEarned += completionReward + efficiencyBonus

        let stars: Int
        if score >= Int(Double(level.targetScore) * 1.35) && moves >= max(2, level.moves / 5) {
            stars = 3
        } else if score >= Int(Double(level.targetScore) * 1.12) || moves >= max(1, level.moves / 8) {
            stars = 2
        } else {
            stars = 1
        }

        return TigerLevelResult(level: level, score: score, trailsOpened: trailsOpened, coins: totalCoins, stars: stars, movesLeft: moves, maxCombo: maxCombo)
    }

    private mutating func redrawTide() {
        for y in 0..<height {
            for x in 0..<width {
                let point = TidePoint(x: x, y: y)
                let phase = x * 2 + y + tide + level.id
                let shouldFlood = phase % level.floodModulo == 0 && point != tiger
                cells[index(point)].flooded = shouldFlood && cells[index(point)].marked == false
            }
        }
    }

    private func contains(_ point: TidePoint) -> Bool {
        point.x >= 0 && point.y >= 0 && point.x < width && point.y < height
    }

    private func index(_ point: TidePoint) -> Int {
        point.y * width + point.x
    }

    private func randomKind(avoiding point: TidePoint, seed: Int) -> TigerTileKind {
        let options = TigerTileKind.allCases
        return options[(point.x * 3 + point.y * 5 + seed + Int.random(in: 0..<options.count)) % options.count]
    }

    private func initialTrails(for level: TigerLevel) -> [TideTrail] {
        (0..<3).map { offset in makeTrail(seed: level.id + offset) }
    }

    private func makeTrail(seed: Int? = nil) -> TideTrail {
        let templates: [(String, [TigerTileKind], Int)] = [
            ("Lantern Reef", [.coin, .shell, .moon], 44),
            ("Bamboo Crest", [.bamboo, .ember, .lotus], 40),
            ("Silver Pool", [.moon, .coin, .shell], 46),
            ("Firefly Run", [.ember, .lotus, .bamboo], 38),
            ("Jade Tide", [.lotus, .coin, .ember], 52),
            ("Temple Stripe", [.shell, .bamboo, .moon], 50)
        ]

        let choice: (String, [TigerTileKind], Int)
        if let seed {
            choice = templates[seed % templates.count]
        } else {
            choice = templates.randomElement() ?? templates[0]
        }
        return TideTrail(name: choice.0, needs: choice.1, progress: 0, reward: choice.2)
    }
}
