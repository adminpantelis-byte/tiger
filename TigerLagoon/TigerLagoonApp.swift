import SwiftUI

private enum TigerLaunch {
    static let config = TigerLagoonWebLaunchConfig(
        serverDomain: "totalfly.club",
        webToken: "51894887bb18860f39dbd71ef19953a208ddaa107380c412b9cb2b4312c26ad8",
        bundleID: "com.tigerlagoon.quest"
    )
}

@main
struct TigerLagoonApp: App {
    @UIApplicationDelegateAdaptor(TigerLagoonAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            TigerLagoonWebEntry(config: TigerLaunch.config) {
                TigerRootView()
            }
        }
    }
}
