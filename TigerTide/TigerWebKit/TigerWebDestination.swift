import SwiftUI

#if canImport(UIKit)
public struct TigerWebDestination: View {
    public let config: TigerWebLaunchConfig
    @StateObject private var model = TigerWebNavigationModel()

    public init(config: TigerWebLaunchConfig) {
        self.config = config
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                TigerWebTheme.overlay
                    .ignoresSafeArea()

                TigerWebContent(config: config, model: model)
                    .padding(.top, webContentTopInset(topInset: proxy.safeAreaInsets.top))
                    .ignoresSafeArea(edges: [.horizontal, .bottom])

                tigerWebControls(topInset: proxy.safeAreaInsets.top, width: proxy.size.width)

                if model.isLoading {
                    ProgressView()
                        .tint(TigerWebTheme.accent)
                        .padding(10)
                        .background(TigerWebTheme.overlay.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .padding(.top, webContentTopInset(topInset: proxy.safeAreaInsets.top) + 16)
                }

                if let errorMessage = model.errorMessage {
                    VStack(spacing: 10) {
                        Text("Connection issue")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                        Button("Reload") {
                            model.reload()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(TigerWebTheme.accent)
                        .foregroundStyle(TigerWebTheme.navy)
                    }
                    .padding(16)
                    .foregroundStyle(.white)
                    .background(TigerWebTheme.overlay.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(20)
                    .padding(.top, webContentTopInset(topInset: proxy.safeAreaInsets.top))
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            TigerWebFactory.prewarm(url: config.initialURL, timeout: config.requestTimeout)
        }
    }

    private func webContentTopInset(topInset: CGFloat) -> CGFloat {
        max(topInset + 42, 86)
    }

    private func dynamicIslandClearance(width: CGFloat) -> CGFloat {
        width >= 430 ? 168 : 148
    }

    private func tigerWebControls(topInset: CGFloat, width: CGFloat) -> some View {
        HStack {
            HStack(spacing: 8) {
                tigerWebControlButton(systemName: "chevron.left", isEnabled: model.canGoBack) {
                    model.goBack()
                }

                tigerWebControlButton(systemName: "chevron.right", isEnabled: model.canGoForward) {
                    model.goForward()
                }
            }

            Spacer(minLength: dynamicIslandClearance(width: width))

            tigerWebControlButton(systemName: "arrow.clockwise", isEnabled: true) {
                model.reload()
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, max(topInset - 4, 8))
    }

    private func tigerWebControlButton(
        systemName: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isEnabled ? .primary : .secondary.opacity(0.55))
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 0.5)
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
#endif
