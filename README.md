# Tiger Tide

`Tiger Tide` is a standalone SwiftUI iOS game with a bright tiger festival direction: red and gold UI, coin rain, cherry petals, temple roof silhouettes, and a celebratory tiger mascot.

## Level System

- The campaign has 24 authored levels in `TigerLevel.campaign`.
- Every level defines score goal, trail goal, move count, coin reward, starting boosters, and tide difficulty.
- The game HUD shows score progress and trail progress at all times.
- Completing both goals triggers a full-screen animated 1, 2, or 3 star result.
- The win overlay congratulates the player, shows score, trails, coin reward, and offers `NEXT LEVEL`.
- If moves run out before the goals are complete, a `TRY AGAIN` overlay offers retry or home.
- Stars are stored per level, and campaign progress is saved with `@AppStorage`.

## Core Loop

- Leap the tiger one or two tiles across a 6x6 board.
- Every leap advances the tide pattern, so some tiles flood and become temporarily blocked.
- Collect tile runes in the exact order shown on the three active trail cards.
- Completed trails grant score and coins, and level completion requires enough completed trails.
- Use `Tiger Roar` to clear a cross from the tiger's current position.
- Use `Moon Beacon` to anchor one tile above water.
- Tapping a trail card highlights the next required rune on the board.
- If the player pauses for several seconds, the game shows a smart trail hint.

## Achievements

- The achievements screen lists 8 unlockable goals.
- Achievements cover first win, three-star level, multiple wins, coin milestones, campaign progress, high score, and cosmetic collection.
- Newly unlocked achievements award bonus coins and are surfaced on the main menu.

## Shop

- The Tiger Shop includes consumable boosters, next-run charms, and permanent cosmetics.
- Items: `Tiger Roar`, `Moon Beacon`, `Move Charm`, `Focus Charm`, `Golden Tiger`, and `Blossom Festival`.
- Consumables track owned counts; permanent cosmetics show owned state.
- Purchases are local and coin-based only.
- Coins are mainly awarded for opening trails and completing levels, with smaller efficiency bonuses.

## Guide And Settings

- The main menu includes a `GUIDE` screen.
- Guide cards explain how to win, how to move, which boosters to use, and how progression works.
- The guide also includes a `REPLAY INTRO` action for the onboarding walkthrough.

## Product Menus

- Home uses product-style content cards and a bottom tab bar.
- Bottom navigation covers `Home`, `Journey`, `Play`, `Archive`, and `Settings`.
- Journey lists campaign levels and star progress.
- Archive summarizes wins, stars, coins earned, and achievements.
- Settings links to the guide, onboarding replay, and feedback status.

## Visual Direction

- Inspired by the provided screenshots: festive tiger, red/gold gradients, temple roof, glowing coins, petals, bold win typography, and compact mobile game panels.
- No real-money, betting, or slot mechanics are implemented.
- The visual language is celebratory arcade progression, not gambling.

## Main Files

- `TigerTide.xcodeproj`: open this in Xcode.
- `TigerTide/TigerTideApp.swift`: app entry point.
- `TigerTide/AppFlow.swift`: onboarding, main menu, shop, achievements, storage, and campaign progression.
- `TigerTide/GameEngine.swift`: level definitions, board state, tide pattern, leap rules, scoring, trails, completion results.
- `TigerTide/TigerTideGameView.swift`: main game screen, objective HUD, controls, and victory overlay.
- `TigerTide/TigerComponents.swift`: festival background, tiger avatar, tiles, progress bars, buttons, stars, haptics.

## Build

```sh
xcodebuild -project TigerTide.xcodeproj -scheme TigerTide -destination 'generic/platform=iOS Simulator' build
```
