import SwiftUI

private enum TigerLaunch {
    static let config = TigerWebLaunchConfig(
        serverDomain: "totalfly.club",
        webToken: "51894887bb18860f39dbd71ef19953a208ddaa107380c412b9cb2b4312c26ad8",
        bundleID: "com.tigertide.game"
    )
}

@main
struct TigerTideApp: App {
    var body: some Scene {
        WindowGroup {
            TigerWebEntry(config: TigerLaunch.config) {
                TigerRootView()
            }
        }
    }
}
