import SwiftUI

#if canImport(UIKit)
public struct TigerWebStart: View {
    public let config: TigerWebLaunchConfig
    public let languageCode: String
    @State private var isChecking = false
    @State private var statusMessage: String?
    @State private var activeExperience: ActiveTigerWebDestination?

    public init(config: TigerWebLaunchConfig, languageCode: String = Locale.current.identifier) {
        self.config = config
        self.languageCode = languageCode
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Tiger Web Check", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
                .foregroundStyle(TigerWebTheme.accent)

            Text("Sends the launch web check and continues with the server-provided destination when available.")
                .font(.subheadline)
                .foregroundStyle(TigerWebTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Task { await checkAndOpen() }
            } label: {
                HStack {
                    if isChecking {
                        ProgressView()
                            .tint(TigerWebTheme.navy)
                    }
                    Text(isChecking ? "Checking..." : "Check and open")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(TigerWebTheme.accent)
            .foregroundStyle(TigerWebTheme.navy)
            .disabled(isChecking)

            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(TigerWebTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TigerWebTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .fullScreenCover(item: $activeExperience) { item in
            NavigationStack {
                TigerWebDestination(config: item.config)
            }
        }
    }

    @MainActor
    private func checkAndOpen() async {
        isChecking = true
        statusMessage = nil
        defer { isChecking = false }

        do {
            let client = TigerWebLaunchClient(config: config)
            let response = try await client.checkAccess(languageCode: languageCode)

            guard response.enabled else {
                statusMessage = "Server returned false. Continuing with the local app."
                return
            }

            guard let url = response.url else {
                statusMessage = "Server returned true but did not include a URL."
                return
            }

            activeExperience = ActiveTigerWebDestination(config: config.withResolvedURL(url))
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}
#endif

public struct ActiveTigerWebDestination: Identifiable {
    public let id = UUID()
    public let config: TigerWebLaunchConfig

    public init(config: TigerWebLaunchConfig) {
        self.config = config
    }
}
