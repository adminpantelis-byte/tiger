import SwiftUI

enum TigerScreen {
    case onboarding
    case menu
    case journey
    case game
    case shop
    case achievements
    case archive
    case guide
    case settings
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let detail: String
    let icon: String
}

struct ShopItem: Identifiable {
    enum Kind {
        case roar
        case beacon
        case moveCharm
        case focusCharm
        case goldSkin
        case blossomTheme
    }

    let id: String
    let kind: Kind
    let title: String
    let subtitle: String
    let price: Int
    let icon: String
    let tint: Color
}

struct TigerRootView: View {
    @AppStorage("tigerTideSeenOnboarding") private var seenOnboarding = false
    @AppStorage("tigerTideCoins") private var coins = 80
    @AppStorage("tigerTideCurrentLevel") private var currentLevel = 1
    @AppStorage("tigerTideCompletedLevels") private var completedLevels = 0
    @AppStorage("tigerTideBestStars") private var bestStars = ""
    @AppStorage("tigerTideRoars") private var roars = 1
    @AppStorage("tigerTideBeacons") private var beacons = 1
    @AppStorage("tigerTideMoveCharms") private var moveCharms = 0
    @AppStorage("tigerTideFocusCharms") private var focusCharms = 0
    @AppStorage("tigerTideGoldSkin") private var goldSkin = false
    @AppStorage("tigerTideBlossomTheme") private var blossomTheme = false
    @AppStorage("tigerTideAchievements") private var unlockedAchievements = ""
    @AppStorage("tigerTideTotalWins") private var totalWins = 0
    @AppStorage("tigerTideTotalStars") private var totalStars = 0
    @AppStorage("tigerTideTotalCoinsEarned") private var totalCoinsEarned = 0

    @State private var screen: TigerScreen = .menu
    @State private var lastUnlocks: [Achievement] = []

    private var level: TigerLevel {
        TigerLevel.campaign[min(max(currentLevel - 1, 0), TigerLevel.campaign.count - 1)]
    }

    var body: some View {
        ZStack {
            FestivalBackground(level: currentLevel)

            switch currentScreen {
            case .onboarding:
                OnboardingView {
                    seenOnboarding = true
                    screen = .menu
                }
            case .menu:
                TigerMenuView(
                    coins: coins,
                    currentLevel: currentLevel,
                    completedLevels: completedLevels,
                    totalStars: totalStars,
                    lastUnlocks: lastUnlocks,
                    onPlay: { screen = .game },
                    onShop: { screen = .shop },
                    onJourney: { screen = .journey },
                    onAchievements: { screen = .achievements },
                    onArchive: { screen = .archive },
                    onSettings: { screen = .settings },
                    onGuide: { screen = .guide },
                    onHow: { screen = .onboarding }
                )
            case .journey:
                JourneyView(
                    currentLevel: currentLevel,
                    completedLevels: completedLevels,
                    starMap: starMap,
                    onBack: { screen = .menu },
                    onPlay: { selected in
                        currentLevel = selected
                        screen = .game
                    },
                    onHome: { screen = .menu },
                    onArchive: { screen = .archive },
                    onSettings: { screen = .settings }
                )
            case .game:
                TigerTideGameView(
                    level: level,
                    bonusMoves: moveCharms > 0 ? 3 : 0,
                    bonusFocus: focusCharms > 0 ? 3 : 0,
                    roarInventory: $roars,
                    beaconInventory: $beacons,
                    onExit: { screen = .menu },
                    onLevelComplete: completeLevel,
                    onNextLevel: goNextLevel
                )
                .id(level.id)
            case .shop:
                TigerShopView(
                    coins: $coins,
                    roars: $roars,
                    beacons: $beacons,
                    moveCharms: $moveCharms,
                    focusCharms: $focusCharms,
                    goldSkin: $goldSkin,
                    blossomTheme: $blossomTheme,
                    onBack: { screen = .menu }
                )
            case .achievements:
                AchievementsView(unlocked: unlockedSet, onBack: { screen = .menu })
            case .archive:
                ArchiveView(
                    unlocked: unlockedSet,
                    totalWins: totalWins,
                    totalStars: totalStars,
                    totalCoinsEarned: totalCoinsEarned,
                    onBack: { screen = .menu },
                    onHome: { screen = .menu },
                    onJourney: { screen = .journey },
                    onPlay: { screen = .game },
                    onSettings: { screen = .settings }
                )
            case .guide:
                GuideSettingsView(onBack: { screen = .menu }, onReplayIntro: { screen = .onboarding })
            case .settings:
                SettingsView(
                    onBack: { screen = .menu },
                    onGuide: { screen = .guide },
                    onReplayIntro: { screen = .onboarding },
                    onJourney: { screen = .journey },
                    onPlay: { screen = .game },
                    onArchive: { screen = .archive }
                )
            }
        }
    }

    private var currentScreen: TigerScreen {
        seenOnboarding ? screen : .onboarding
    }

    private var unlockedSet: Set<String> {
        Set(unlockedAchievements.split(separator: ",").map(String.init))
    }

    private func completeLevel(_ result: TigerLevelResult) {
        coins += result.coins
        totalWins += 1
        totalStars += result.stars
        totalCoinsEarned += result.coins
        completedLevels = max(completedLevels, result.level.id)

        if moveCharms > 0 { moveCharms -= 1 }
        if focusCharms > 0 { focusCharms -= 1 }

        var stars = starMap
        stars[result.level.id] = max(stars[result.level.id] ?? 0, result.stars)
        bestStars = stars.map { "\($0.key):\($0.value)" }.sorted().joined(separator: ",")

        updateAchievements(result: result)
    }

    private func goNextLevel() {
        currentLevel = min(TigerLevel.campaign.count, level.id + 1)
        screen = currentLevel == level.id ? .menu : .game
    }

    private var starMap: [Int: Int] {
        var map: [Int: Int] = [:]
        for pair in bestStars.split(separator: ",") {
            let pieces = pair.split(separator: ":")
            guard pieces.count == 2, let key = Int(pieces[0]), let value = Int(pieces[1]) else { continue }
            map[key] = value
        }
        return map
    }

    private func updateAchievements(result: TigerLevelResult) {
        var unlocked = unlockedSet
        var fresh: [Achievement] = []

        for achievement in AchievementCatalog.all {
            let shouldUnlock: Bool
            switch achievement.id {
            case "first_win": shouldUnlock = totalWins >= 1
            case "three_stars": shouldUnlock = result.stars == 3
            case "five_wins": shouldUnlock = totalWins >= 5
            case "coin_rain": shouldUnlock = totalCoinsEarned >= 500
            case "half_campaign": shouldUnlock = completedLevels >= 4
            case "full_campaign": shouldUnlock = completedLevels >= TigerLevel.campaign.count
            case "big_score": shouldUnlock = result.score >= 1000
            case "collector": shouldUnlock = goldSkin && blossomTheme
            default: shouldUnlock = false
            }

            if shouldUnlock, unlocked.contains(achievement.id) == false {
                unlocked.insert(achievement.id)
                fresh.append(achievement)
                coins += 20
            }
        }

        unlockedAchievements = unlocked.sorted().joined(separator: ",")
        lastUnlocks = fresh
    }
}

enum AchievementCatalog {
    static let all: [Achievement] = [
        Achievement(id: "first_win", title: "First Tide", detail: "Complete any level.", icon: "flag.checkered"),
        Achievement(id: "three_stars", title: "Golden Leap", detail: "Earn three stars on a level.", icon: "star.fill"),
        Achievement(id: "five_wins", title: "Festival Regular", detail: "Complete five levels.", icon: "sparkles"),
        Achievement(id: "coin_rain", title: "Coin Rain", detail: "Earn 500 coins from runs.", icon: "circle.hexagongrid.fill"),
        Achievement(id: "half_campaign", title: "Temple Halfway", detail: "Complete level 4.", icon: "building.columns.fill"),
        Achievement(id: "full_campaign", title: "Tiger Master", detail: "Complete the campaign.", icon: "crown.fill"),
        Achievement(id: "big_score", title: "High Score Energy", detail: "Score at least 1000 in one level.", icon: "bolt.fill"),
        Achievement(id: "collector", title: "Festival Collector", detail: "Own both cosmetic shop items.", icon: "gift.fill")
    ]
}

struct OnboardingView: View {
    let onStart: () -> Void
    @State private var page = 0

    private let pages = [
        ("TIGER LEVELS", "Each level has score and trail goals. Fill both before moves run out."),
        ("STAR RESULTS", "Finish a level to earn 1, 2, or 3 stars, coins, and a next level offer."),
        ("SHOP & ACHIEVEMENTS", "Spend coins on boosters, charms, cosmetics, and unlock festival achievements.")
    ]

    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            TigerTitle()
            TigerAvatar(focused: page == 1)
                .frame(width: 160, height: 160)

            VStack(spacing: 10) {
                Text(pages[page].0)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(pages[page].1)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.84))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)

            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? Color.tigerHex(0xFFE15A) : .white.opacity(0.34))
                        .frame(width: index == page ? 32 : 10, height: 8)
                }
            }

            Button(page == pages.count - 1 ? "PLAY" : "NEXT") {
                if page == pages.count - 1 {
                    onStart()
                } else {
                    page += 1
                }
            }
            .buttonStyle(TigerButtonStyle(tint: .tigerHex(0x12A86B)))
            .padding(.horizontal, 42)
            Spacer()
        }
        .padding()
    }
}

struct TigerMenuView: View {
    let coins: Int
    let currentLevel: Int
    let completedLevels: Int
    let totalStars: Int
    let lastUnlocks: [Achievement]
    let onPlay: () -> Void
    let onShop: () -> Void
    let onJourney: () -> Void
    let onAchievements: () -> Void
    let onArchive: () -> Void
    let onSettings: () -> Void
    let onGuide: () -> Void
    let onHow: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                CoinPill(value: coins)
                Spacer()
                Button("GUIDE") { onGuide() }
                    .buttonStyle(TigerButtonStyle(tint: .tigerHex(0xC7193B)))
                    .frame(width: 94)
            }

            ProductHeroCard(
                title: TigerLevel.campaign[min(currentLevel - 1, TigerLevel.campaign.count - 1)].title,
                currentLevel: currentLevel,
                completedLevels: completedLevels,
                totalStars: totalStars,
                onPlay: onPlay
            )

            VStack(spacing: 10) {
                ProductInfoCard(
                    title: "Journey Progress",
                    subtitle: "Unlock level \(min(completedLevels + 1, TigerLevel.campaign.count)) of \(TigerLevel.campaign.count)",
                    icon: "map.fill",
                    value: "\(completedLevels) / \(TigerLevel.campaign.count)",
                    tint: .tigerHex(0x12A86B),
                    action: onJourney
                )

                ProductInfoCard(
                    title: "Festival Play",
                    subtitle: "Short bright rounds with boosters.",
                    icon: "gamecontroller.fill",
                    value: "\(totalStars) stars",
                    tint: .tigerHex(0xFF6FB1),
                    action: onPlay
                )
            }

            if let unlock = lastUnlocks.first {
                Label("Unlocked: \(unlock.title)", systemImage: unlock.icon)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(Color.tigerHex(0xFFE15A))
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            }

            HStack(spacing: 10) {
                Button("SHOP") { onShop() }
                    .buttonStyle(TigerButtonStyle(tint: .tigerHex(0xFFE15A)))
                Button("ACHIEVEMENTS") { onAchievements() }
                    .buttonStyle(TigerButtonStyle(tint: .tigerHex(0x12A86B)))
            }
            Button("REPLAY INTRO") { onHow() }
                .buttonStyle(TigerButtonStyle(tint: .tigerHex(0x60D6F5)))
            Spacer(minLength: 0)
            ProductTabBar(active: .home, onHome: {}, onJourney: onJourney, onPlay: onPlay, onArchive: onArchive, onSettings: onSettings)
        }
        .padding(20)
    }
}

enum ProductTab {
    case home
    case journey
    case play
    case archive
    case settings
}

struct ProductHeroCard: View {
    let title: String
    let currentLevel: Int
    let completedLevels: Int
    let totalStars: Int
    let onPlay: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text("CHAPTER \(currentLevel)")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                Text(title)
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Button("Open Journey") { onPlay() }
                    .buttonStyle(TigerButtonStyle(tint: .tigerHex(0xFFE15A)))
                    .frame(width: 170)
            }

            Spacer()

            TigerAvatar(focused: true)
                .frame(width: 118, height: 118)
        }
        .padding(18)
        .background(
            LinearGradient(colors: [.tigerHex(0xFF526D), .tigerHex(0xF46B2D)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.tigerHex(0xFFE15A).opacity(0.5), lineWidth: 1))
    }
}

struct ProductInfoCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let value: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(tint)
                    .frame(width: 54, height: 54)
                    .background(.white.opacity(0.16), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                Text(value)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(Color.tigerHex(0xFFE15A))
            }
            .padding(14)
            .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct ProductTabBar: View {
    let active: ProductTab
    let onHome: () -> Void
    let onJourney: () -> Void
    let onPlay: () -> Void
    let onArchive: () -> Void
    let onSettings: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            tab(.home, "Home", "house.fill", action: onHome)
            tab(.journey, "Journey", "map.fill", action: onJourney)
            tab(.play, "Play", "gamecontroller.fill", action: onPlay)
            tab(.archive, "Archive", "books.vertical.fill", action: onArchive)
            tab(.settings, "Settings", "gearshape.fill", action: onSettings)
        }
        .padding(8)
        .background(.black.opacity(0.34), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(.white.opacity(0.12), lineWidth: 1))
    }

    private func tab(_ tab: ProductTab, _ title: String, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .black))
                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
            }
            .foregroundStyle(active == tab ? .black : .white.opacity(0.76))
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(active == tab ? Color.tigerHex(0xFFE15A) : .clear, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct JourneyView: View {
    let currentLevel: Int
    let completedLevels: Int
    let starMap: [Int: Int]
    let onBack: () -> Void
    let onPlay: (Int) -> Void
    let onHome: () -> Void
    let onArchive: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            topBar(title: "JOURNEY", onBack: onBack)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(TigerLevel.campaign) { level in
                        let locked = level.id > completedLevels + 1
                        Button {
                            if locked == false { onPlay(level.id) }
                        } label: {
                            HStack(spacing: 12) {
                                Text("\(level.id)")
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundStyle(locked ? .white.opacity(0.35) : Color.tigerHex(0xFFE15A))
                                    .frame(width: 42, height: 42)
                                    .background(.black.opacity(0.22), in: Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(level.title)
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text(locked ? "Locked" : "Score \(level.targetScore) • Trails \(level.targetTrails)")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.68))
                                }

                                Spacer()

                                StarRating(count: starMap[level.id] ?? 0)
                                    .scaleEffect(0.52)
                                    .frame(width: 70)
                            }
                            .padding(14)
                            .background(.black.opacity(locked ? 0.12 : 0.24), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(.white.opacity(0.12), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 8)
            }
            ProductTabBar(active: .journey, onHome: onHome, onJourney: {}, onPlay: { onPlay(currentLevel) }, onArchive: onArchive, onSettings: onSettings)
        }
        .padding(20)
    }
}

struct ArchiveView: View {
    let unlocked: Set<String>
    let totalWins: Int
    let totalStars: Int
    let totalCoinsEarned: Int
    let onBack: () -> Void
    let onHome: () -> Void
    let onJourney: () -> Void
    let onPlay: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            topBar(title: "ARCHIVE", onBack: onBack)
            VStack(spacing: 10) {
                ProductInfoCard(title: "Wins", subtitle: "Completed levels", icon: "flag.checkered", value: "\(totalWins)", tint: .tigerHex(0x12A86B), action: {})
                ProductInfoCard(title: "Stars", subtitle: "Best level results", icon: "star.fill", value: "\(totalStars)", tint: .tigerHex(0xFFE15A), action: {})
                ProductInfoCard(title: "Coins Earned", subtitle: "Run rewards collected", icon: "circle.hexagongrid.fill", value: "\(totalCoinsEarned)", tint: .tigerHex(0xFF6FB1), action: {})
                ProductInfoCard(title: "Achievements", subtitle: "Unlocked milestones", icon: "trophy.fill", value: "\(unlocked.count)/\(AchievementCatalog.all.count)", tint: .tigerHex(0x60D6F5), action: {})
            }
            Spacer()
            ProductTabBar(active: .archive, onHome: onHome, onJourney: onJourney, onPlay: onPlay, onArchive: {}, onSettings: onSettings)
        }
        .padding(20)
    }
}

struct SettingsView: View {
    let onBack: () -> Void
    let onGuide: () -> Void
    let onReplayIntro: () -> Void
    let onJourney: () -> Void
    let onPlay: () -> Void
    let onArchive: () -> Void
    @AppStorage("tigerTideSoundEnabled") private var soundEnabled = true

    var body: some View {
        VStack(spacing: 14) {
            topBar(title: "SETTINGS", onBack: onBack)
            ProductInfoCard(title: "How To Play", subtitle: "Rules, trails, boosters, progression.", icon: "questionmark.circle.fill", value: "GUIDE", tint: .tigerHex(0x60D6F5), action: onGuide)
            ProductInfoCard(title: "Replay Intro", subtitle: "Show onboarding cards again.", icon: "play.rectangle.fill", value: "OPEN", tint: .tigerHex(0x12A86B), action: onReplayIntro)
            Toggle(isOn: $soundEnabled) {
                HStack(spacing: 13) {
                    Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(Color.tigerHex(0xFFE15A))
                        .frame(width: 54, height: 54)
                        .background(.white.opacity(0.16), in: Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sound")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text(soundEnabled ? "Win and error sounds are enabled." : "Sounds are muted. Haptics stay active.")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .tigerHex(0xFFE15A)))
            .padding(14)
            .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(.white.opacity(0.12), lineWidth: 1))
            Spacer()
            ProductTabBar(active: .settings, onHome: onBack, onJourney: onJourney, onPlay: onPlay, onArchive: onArchive, onSettings: {})
        }
        .padding(20)
    }
}

private func topBar(title: String, onBack: @escaping () -> Void) -> some View {
    HStack(spacing: 12) {
        Button("BACK") { onBack() }
            .buttonStyle(TigerButtonStyle(tint: .tigerHex(0xC7193B)))
            .frame(width: 96)
        Spacer()
        Text(title)
            .font(.system(size: 26, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: Color.tigerHex(0xFFE15A), radius: 8)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity)
        Spacer()
        Color.clear.frame(width: 96, height: 1)
    }
}

struct TigerShopView: View {
    @Binding var coins: Int
    @Binding var roars: Int
    @Binding var beacons: Int
    @Binding var moveCharms: Int
    @Binding var focusCharms: Int
    @Binding var goldSkin: Bool
    @Binding var blossomTheme: Bool
    let onBack: () -> Void

    private let items: [ShopItem] = [
        ShopItem(id: "roar", kind: .roar, title: "Tiger Roar", subtitle: "Adds one cross-clearing roar.", price: 35, icon: "bolt.fill", tint: .tigerHex(0xFF5A36)),
        ShopItem(id: "beacon", kind: .beacon, title: "Moon Beacon", subtitle: "Pins one tile above water.", price: 25, icon: "moon.stars.fill", tint: .tigerHex(0x60D6F5)),
        ShopItem(id: "moves", kind: .moveCharm, title: "Move Charm", subtitle: "+3 moves on the next level.", price: 55, icon: "figure.run", tint: .tigerHex(0x12A86B)),
        ShopItem(id: "focus", kind: .focusCharm, title: "Focus Charm", subtitle: "Start next level with +3 focus.", price: 50, icon: "sparkles", tint: .tigerHex(0xFF6FB1)),
        ShopItem(id: "gold", kind: .goldSkin, title: "Golden Tiger", subtitle: "Permanent luxury tiger style.", price: 160, icon: "crown.fill", tint: .tigerHex(0xFFE15A)),
        ShopItem(id: "blossom", kind: .blossomTheme, title: "Blossom Festival", subtitle: "Permanent pink petal celebration.", price: 140, icon: "camera.macro", tint: .tigerHex(0xFF9EC4))
    ]

    var body: some View {
        StoreScreen(title: "TIGER SHOP", coins: coins, onBack: onBack) {
            ForEach(items) { item in
                ShopRow(
                    item: item,
                    ownedText: ownedText(for: item),
                    purchased: purchased(item),
                    action: { buy(item) }
                )
            }
        }
    }

    private func ownedText(for item: ShopItem) -> String {
        switch item.kind {
        case .roar: return "Owned: \(roars)"
        case .beacon: return "Owned: \(beacons)"
        case .moveCharm: return "Owned: \(moveCharms)"
        case .focusCharm: return "Owned: \(focusCharms)"
        case .goldSkin: return goldSkin ? "Owned" : "Permanent"
        case .blossomTheme: return blossomTheme ? "Owned" : "Permanent"
        }
    }

    private func purchased(_ item: ShopItem) -> Bool {
        switch item.kind {
        case .goldSkin: return goldSkin
        case .blossomTheme: return blossomTheme
        default: return false
        }
    }

    private func buy(_ item: ShopItem) {
        guard purchased(item) == false else {
            GameFeedback.shared.light()
            return
        }
        guard coins >= item.price else {
            GameFeedback.shared.error()
            return
        }
        coins -= item.price
        switch item.kind {
        case .roar: roars += 1
        case .beacon: beacons += 1
        case .moveCharm: moveCharms += 1
        case .focusCharm: focusCharms += 1
        case .goldSkin: goldSkin = true
        case .blossomTheme: blossomTheme = true
        }
        GameFeedback.shared.success()
    }
}

struct AchievementsView: View {
    let unlocked: Set<String>
    let onBack: () -> Void

    var body: some View {
        StoreScreen(title: "ACHIEVEMENTS", coins: unlocked.count, onBack: onBack) {
            ForEach(AchievementCatalog.all) { achievement in
                HStack(spacing: 14) {
                    Image(systemName: achievement.icon)
                        .font(.system(size: 27, weight: .black))
                        .foregroundStyle(unlocked.contains(achievement.id) ? Color.tigerHex(0xFFE15A) : .white.opacity(0.38))
                        .frame(width: 62, height: 62)
                        .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 5) {
                        Text(achievement.title)
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text(achievement.detail)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    Spacer()
                    Image(systemName: unlocked.contains(achievement.id) ? "checkmark.seal.fill" : "lock.fill")
                        .foregroundStyle(unlocked.contains(achievement.id) ? Color.tigerHex(0x12A86B) : .white.opacity(0.4))
                }
                .padding(15)
                .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(.white.opacity(0.12), lineWidth: 1))
            }
        }
    }
}

struct GuideSettingsView: View {
    let onBack: () -> Void
    let onReplayIntro: () -> Void

    private let sections: [(String, String, String, [String])] = [
        (
            "How To Win",
            "flag.checkered",
            "Complete both goals before moves run out.",
            [
                "Reach the score target shown in the progress bar.",
                "Open enough trail cards by collecting their runes in order.",
                "A level ends with a 1, 2, or 3 star result when both bars are complete."
            ]
        ),
        (
            "How To Move",
            "pawprint.fill",
            "Tap any open tile one or two spaces from the tiger.",
            [
                "Flooded tiles are blocked until the tide pattern changes.",
                "Every leap advances the tide and marks the tile with a paw.",
                "Coin runes add small coin rewards while trail runes advance cards."
            ]
        ),
        (
            "What To Use",
            "bolt.fill",
            "Boosters solve bad boards and protect strong runs.",
            [
                "Tiger Roar clears the tiger's row and column and gives score.",
                "Moon Beacon anchors one tile so it stays above water.",
                "Move Charm starts the next level with +3 moves.",
                "Focus Charm starts the next level with +3 focus for higher leap score."
            ]
        ),
        (
            "Progression",
            "star.fill",
            "Stars, coins, shop items, and achievements persist locally.",
            [
                "Higher score and spare moves improve the star result.",
                "Coins buy boosters, charms, and cosmetic festival items.",
                "Achievements reward milestone play with bonus coins."
            ]
        )
    ]

    var body: some View {
        StoreScreen(title: "GUIDE", coins: TigerLevel.campaign.count, onBack: onBack) {
            ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                GuideCard(title: section.0, icon: section.1, summary: section.2, bullets: section.3)
            }

            Button("REPLAY INTRO") { onReplayIntro() }
                .buttonStyle(TigerButtonStyle(tint: .tigerHex(0x60D6F5)))
        }
    }
}

struct GuideCard: View {
    let title: String
    let icon: String
    let summary: String
    let bullets: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(Color.tigerHex(0xFFE15A))
                    .frame(width: 48, height: 48)
                    .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(summary)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.76))
                }
            }

            VStack(alignment: .leading, spacing: 7) {
                ForEach(bullets, id: \.self) { bullet in
                    Label(bullet, systemImage: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.86))
                }
            }
        }
        .padding(16)
        .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.tigerHex(0xFFE15A).opacity(0.24), lineWidth: 1))
    }
}

struct StoreScreen<Content: View>: View {
    let title: String
    let coins: Int
    let onBack: () -> Void
    let content: Content

    init(title: String, coins: Int, onBack: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.title = title
        self.coins = coins
        self.onBack = onBack
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button("BACK") { onBack() }
                    .buttonStyle(TigerButtonStyle(tint: .tigerHex(0xC7193B)))
                    .frame(width: 104)
                Spacer()
                CoinPill(value: coins)
            }
            Text(title)
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: Color.tigerHex(0xFFE15A), radius: 8)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 13) {
                    content
                }
                .padding(.bottom, 24)
            }
        }
        .padding(20)
    }
}

struct ShopRow: View {
    let item: ShopItem
    let ownedText: String
    let purchased: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.icon)
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(item.tint)
                .frame(width: 66, height: 66)
                .background(item.tint.opacity(0.2), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(item.subtitle)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
                Text(ownedText)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(Color.tigerHex(0xFFE15A))
            }
            Spacer()
            Button(purchased ? "OWNED" : "\(item.price)") { action() }
                .buttonStyle(TigerButtonStyle(tint: purchased ? .gray : item.tint))
                .frame(width: 88)
        }
        .padding(15)
        .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(item.tint.opacity(0.28), lineWidth: 1))
    }
}
