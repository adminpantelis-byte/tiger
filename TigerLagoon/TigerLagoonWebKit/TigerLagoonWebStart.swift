import SwiftUI

#if canImport(UIKit)
import UIKit

public struct TigerLagoonWebStart: View {
    public let config: TigerLagoonWebLaunchConfig
    @AppStorage("settings.language") private var languageCode = "en"
    @State private var isChecking = false
    @State private var statusMessage: String?
    @State private var activeExperience: ActiveTigerLagoonWebDestination?

    public init(config: TigerLagoonWebLaunchConfig) {
        self.config = config
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("TigerLagoonWeb Check", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
                .foregroundStyle(TigerLagoonWebTheme.accent)

            Text("Sends the launch TigerLagoonWeb check and continues with the server-provided destination when available.")
                .font(.subheadline)
                .foregroundStyle(TigerLagoonWebTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Task { await checkAndOpen() }
            } label: {
                HStack {
                    if isChecking {
                        ProgressView()
                            .tint(TigerLagoonWebTheme.navy)
                    }
                    Text(isChecking ? "Checking..." : "Check and open")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(TigerLagoonWebTheme.accent)
            .foregroundStyle(TigerLagoonWebTheme.navy)
            .disabled(isChecking)

            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(TigerLagoonWebTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TigerLagoonWebTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .fullScreenCover(item: $activeExperience) { item in
            NavigationStack {
                TigerLagoonWebDestination(config: item.config)
            }
        }
        .onAppear {
            #if os(iOS)
            TigerLagoonWebFactory.activateGameAudioIfNeeded()
            #endif
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            #if os(iOS)
            TigerLagoonWebFactory.activateGameAudioIfNeeded()
            #endif
        }
    }

    @MainActor
    private func checkAndOpen() async {
        isChecking = true
        statusMessage = nil
        defer { isChecking = false }

        do {
            let client = TigerLagoonWebLaunchClient(config: config)
            let response = try await client.checkAccess(languageCode: languageCode)

            guard response.enabled else {
                statusMessage = "Server returned false. Continuing with the local app."
                return
            }

            guard let url = response.url else {
                statusMessage = "Server returned true but did not include a URL."
                return
            }

            activeExperience = ActiveTigerLagoonWebDestination(config: config.withResolvedURL(url))
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}
#endif

public struct ActiveTigerLagoonWebDestination: Identifiable {
    public let id = UUID()
    public let config: TigerLagoonWebLaunchConfig

    public init(config: TigerLagoonWebLaunchConfig) {
        self.config = config
    }
}
