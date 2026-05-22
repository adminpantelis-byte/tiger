import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let sourceURL = URL(fileURLWithPath: "/Users/allonsy/Downloads/ChatGPT Image 21 трав. 2026 р., 23_21_23.png")
let logoURL = URL(fileURLWithPath: "TigerLagoon/Assets.xcassets/LagoonLogo.imageset/lagoon-logo.png")
let iconURL = URL(fileURLWithPath: "TigerLagoon/Assets.xcassets/AppIcon.appiconset/app-icon.png")
let outputSize = CGSize(width: 1024, height: 1024)

guard
    let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
    let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
else {
    fatalError("Unable to load source logo at \(sourceURL.path)")
}

func writeOpaquePNG(to url: URL) throws {
    let width = Int(outputSize.width)
    let height = Int(outputSize.height)
    let bytesPerRow = width * 4
    var pixels = [UInt8](repeating: 0, count: bytesPerRow * height)

    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
        fatalError("Unable to create sRGB color space")
    }

    guard let context = CGContext(
        data: &pixels,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue | CGImageByteOrderInfo.order32Big.rawValue
    ) else {
        fatalError("Unable to create opaque RGB context")
    }

    context.interpolationQuality = .high
    context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
    context.fill(CGRect(origin: .zero, size: outputSize))

    let sourceSize = CGSize(width: image.width, height: image.height)
    let scale = max(outputSize.width / sourceSize.width, outputSize.height / sourceSize.height)
    let drawSize = CGSize(width: sourceSize.width * scale, height: sourceSize.height * scale)
    let drawRect = CGRect(
        x: (outputSize.width - drawSize.width) / 2,
        y: (outputSize.height - drawSize.height) / 2,
        width: drawSize.width,
        height: drawSize.height
    )
    context.draw(image, in: drawRect)

    guard let rendered = context.makeImage() else {
        fatalError("Unable to render opaque image")
    }
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        fatalError("Unable to create PNG destination")
    }
    CGImageDestinationAddImage(destination, rendered, nil)
    guard CGImageDestinationFinalize(destination) else {
        fatalError("Unable to write PNG at \(url.path)")
    }
}

try writeOpaquePNG(to: logoURL)
try writeOpaquePNG(to: iconURL)
