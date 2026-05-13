import AppKit
import Foundation

let logoURL = URL(fileURLWithPath: "TigerTide/Assets.xcassets/TigerLogo.imageset/tiger-logo.png")
let iconURL = URL(fileURLWithPath: "TigerTide/Assets.xcassets/AppIcon.appiconset/app-icon.png")

guard let image = NSImage(contentsOf: logoURL) else {
    fatalError("Unable to load logo")
}

let size = NSSize(width: 1024, height: 1024)
guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(size.width),
    pixelsHigh: Int(size.height),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fatalError("Unable to create bitmap")
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

let rect = NSRect(origin: .zero, size: size)
image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)

NSGradient(colors: [
    NSColor(calibratedRed: 1.0, green: 0.78, blue: 0.16, alpha: 0.18),
    NSColor(calibratedRed: 0.98, green: 0.16, blue: 0.34, alpha: 0.13),
    NSColor(calibratedRed: 0.24, green: 0.82, blue: 1.0, alpha: 0.10)
])?.draw(in: rect, angle: -34)

NSColor(calibratedRed: 1.0, green: 0.96, blue: 0.72, alpha: 0.16).setStroke()
let ring = NSBezierPath(roundedRect: rect.insetBy(dx: 28, dy: 28), xRadius: 132, yRadius: 132)
ring.lineWidth = 12
ring.stroke()

NSColor(calibratedRed: 0.07, green: 0.86, blue: 0.62, alpha: 0.11).setFill()
NSBezierPath(ovalIn: NSRect(x: 708, y: 80, width: 238, height: 238)).fill()

NSGraphicsContext.restoreGraphicsState()

guard let data = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode logo")
}

try data.write(to: logoURL, options: .atomic)
try data.write(to: iconURL, options: .atomic)
