# WebView Camera Gallery Kit

Standalone copy of the Tiger Lagoon WebView layer with:

- camera upload support for web file inputs
- photo library upload support
- files picker fallback
- WebKit media capture permission handling for liveness checks
- iOS 15 compatible navigation wrappers

Required generated Info.plist keys in the host app:

- `NSCameraUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSPhotoLibraryUsageDescription`

Do not add this folder to the Tiger Lagoon target while the main `TigerLagoon/TigerLagoonWebKit` folder is still included, because both folders define the same Swift types.
