import AppKit
import Foundation

let sliceSize = CGSize(width: 1290, height: 2796)
let sliceCount = 3
let canvasSize = CGSize(width: sliceSize.width * CGFloat(sliceCount), height: sliceSize.height)
let outputDir = URL(fileURLWithPath: "Marketing/AppStoreScreenshots", isDirectory: true)

let logo = NSImage(contentsOfFile: "TigerLagoon/Assets.xcassets/LagoonLogo.imageset/lagoon-logo.png")
let home = NSImage(contentsOfFile: "Marketing/AppStoreScreenshots/01-home.png")
let gameplay = NSImage(contentsOfFile: "Marketing/AppStoreScreenshots/02-gameplay.png")
let win = NSImage(contentsOfFile: "Marketing/AppStoreScreenshots/03-win.png")

func color(_ hex: Int, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(
        calibratedRed: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: alpha
    )
}

func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
    CGRect(x: x, y: y, width: w, height: h)
}

func rounded(_ rect: CGRect, _ radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func drawText(_ text: String, in rect: CGRect, size: CGFloat, weight: NSFont.Weight = .black, color: NSColor = .white, align: NSTextAlignment = .left) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = align
    paragraph.lineBreakMode = .byWordWrapping
    text.draw(
        in: rect,
        withAttributes: [
            .font: NSFont.systemFont(ofSize: size, weight: weight),
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
    )
}

func drawBackground() {
    NSGradient(colors: [color(0xff6a43), color(0xe53245), color(0x8a1352), color(0x3f0a47)])?
        .draw(in: rect(0, 0, canvasSize.width, canvasSize.height), angle: -16)

    let moon = NSBezierPath(ovalIn: rect(1380, 1660, 1110, 1110))
    NSGradient(colors: [color(0xfff1bd, 0.72), color(0xffe15a, 0.18), .clear])?
        .draw(in: moon, relativeCenterPosition: .zero)

    let ribbon = NSBezierPath()
    ribbon.move(to: CGPoint(x: 0, y: 1080))
    ribbon.curve(to: CGPoint(x: canvasSize.width, y: 1260), controlPoint1: CGPoint(x: 940, y: 1420), controlPoint2: CGPoint(x: 2500, y: 820))
    ribbon.line(to: CGPoint(x: canvasSize.width, y: 1030))
    ribbon.curve(to: CGPoint(x: 0, y: 850), controlPoint1: CGPoint(x: 2470, y: 610), controlPoint2: CGPoint(x: 910, y: 1180))
    ribbon.close()
    NSGradient(colors: [color(0x12a86b, 0.78), color(0x066b47, 0.72)])?.draw(in: ribbon, angle: 0)

    for index in 0..<42 {
        let x = CGFloat((index * 293 + 140) % Int(canvasSize.width))
        let y = CGFloat((index * 211 + 180) % Int(canvasSize.height))
        let size = CGFloat(index.isMultiple(of: 5) ? 22 : 11)
        (index.isMultiple(of: 5) ? color(0xffe15a, 0.62) : color(0xffffff, 0.22)).setFill()
        NSBezierPath(ovalIn: rect(x, y, size, size)).fill()
    }
}

func drawPhone(image: NSImage?, in frame: CGRect, rotate degrees: CGFloat, opacity: CGFloat = 1) {
    guard let image else { return }

    NSGraphicsContext.saveGraphicsState()
    let transform = NSAffineTransform()
    transform.translateX(by: frame.midX, yBy: frame.midY)
    transform.rotate(byDegrees: degrees)
    transform.translateX(by: -frame.midX, yBy: -frame.midY)
    transform.concat()

    let shadow = NSShadow()
    shadow.shadowColor = .black.withAlphaComponent(0.36 * opacity)
    shadow.shadowBlurRadius = 34
    shadow.shadowOffset = CGSize(width: 0, height: -18)
    shadow.set()

    color(0x07070a, opacity).setFill()
    rounded(frame, 88).fill()
    NSShadow().set()

    color(0x24242c, opacity).setStroke()
    rounded(frame.insetBy(dx: 12, dy: 12), 78).lineWidth = 6
    rounded(frame.insetBy(dx: 12, dy: 12), 78).stroke()

    let screen = frame.insetBy(dx: 32, dy: 32)
    NSGraphicsContext.saveGraphicsState()
    rounded(screen, 60).addClip()
    image.draw(in: screen, from: .zero, operation: .sourceOver, fraction: opacity)
    NSGraphicsContext.restoreGraphicsState()

    color(0x000000, opacity).setFill()
    rounded(rect(frame.midX - frame.width * 0.18, frame.maxY - 98, frame.width * 0.36, 58), 29).fill()

    NSGraphicsContext.restoreGraphicsState()
}

func drawTiger() {
    guard let logo else { return }

    let glow = NSBezierPath(ovalIn: rect(1070, 620, 1720, 1720))
    NSGradient(colors: [color(0xffe15a, 0.34), color(0xff6f3d, 0.18), .clear])?
        .draw(in: glow, relativeCenterPosition: .zero)

    logo.draw(in: rect(1180, 680, 1500, 1500), from: .zero, operation: .sourceOver, fraction: 1)
}

func drawTrail() {
    let path = NSBezierPath()
    path.move(to: CGPoint(x: 460, y: 820))
    path.curve(to: CGPoint(x: 3420, y: 980), controlPoint1: CGPoint(x: 1160, y: 520), controlPoint2: CGPoint(x: 2500, y: 1320))
    color(0xffe15a, 0.42).setStroke()
    path.lineWidth = 12
    path.stroke()

    let thin = NSBezierPath()
    thin.move(to: CGPoint(x: 520, y: 770))
    thin.curve(to: CGPoint(x: 3360, y: 910), controlPoint1: CGPoint(x: 1200, y: 470), controlPoint2: CGPoint(x: 2480, y: 1230))
    color(0xffffff, 0.22).setStroke()
    thin.lineWidth = 4
    thin.stroke()
}

func drawCleanDecor() {
    let coins: [(CGFloat, CGFloat, CGFloat)] = [
        (350, 440, 54), (640, 2050, 44), (1030, 880, 36),
        (2810, 1960, 54), (3210, 720, 48), (3540, 1720, 38)
    ]
    for coin in coins {
        color(0xffe15a, 0.84).setFill()
        NSBezierPath(ovalIn: rect(coin.0, coin.1, coin.2, coin.2 * 0.78)).fill()
    }

    drawEnvelope(rect(290, 1540, 210, 150), rotate: -14, alpha: 0.76)
    drawEnvelope(rect(3260, 420, 210, 150), rotate: 14, alpha: 0.76)
}

func drawEnvelope(_ r: CGRect, rotate degrees: CGFloat, alpha: CGFloat) {
    NSGraphicsContext.saveGraphicsState()
    let t = NSAffineTransform()
    t.translateX(by: r.midX, yBy: r.midY)
    t.rotate(byDegrees: degrees)
    t.translateX(by: -r.midX, yBy: -r.midY)
    t.concat()
    color(0xd71932, alpha).setFill()
    rounded(r, 18).fill()
    color(0xffe15a, alpha).setStroke()
    rounded(r.insetBy(dx: 12, dy: 12), 12).lineWidth = 4
    rounded(r.insetBy(dx: 12, dy: 12), 12).stroke()
    drawText("福", in: r.insetBy(dx: 10, dy: 14), size: 68, weight: .black, color: color(0xffe15a, alpha), align: .center)
    NSGraphicsContext.restoreGraphicsState()
}

func drawCopy() {
    drawText("Tiger Lagoon", in: rect(120, 220, 1050, 92), size: 78, weight: .black, align: .center)
    drawText("festival puzzle adventure", in: rect(160, 172, 970, 44), size: 34, weight: .heavy, color: color(0xfff1bd), align: .center)

    drawText("Open Rune Trails", in: rect(1420, 220, 1030, 92), size: 80, weight: .black, align: .center)
    drawText("leap, match and beat the tide", in: rect(1450, 172, 970, 44), size: 34, weight: .heavy, color: color(0xfff1bd), align: .center)

    drawText("Boosters & Stars", in: rect(2710, 220, 1030, 92), size: 80, weight: .black, align: .center)
    drawText("win levels and unlock rewards", in: rect(2740, 172, 970, 44), size: 34, weight: .heavy, color: color(0xfff1bd), align: .center)
}

func makeBitmap(width: Int, height: Int) -> NSBitmapImageRep {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
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
    return rep
}

func write(_ rep: NSBitmapImageRep, to url: URL) throws {
    guard let data = rep.representation(using: .png, properties: [:]) else {
        fatalError("Unable to encode \(url.lastPathComponent)")
    }
    try data.write(to: url, options: .atomic)
}

try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

let panorama = makeBitmap(width: Int(canvasSize.width), height: Int(canvasSize.height))
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: panorama)
drawBackground()
drawPhone(image: home, in: rect(210, 660, 760, 1600), rotate: -12, opacity: 0.88)
drawPhone(image: gameplay, in: rect(2570, 690, 760, 1600), rotate: 11, opacity: 0.9)
drawTiger()
drawTrail()
drawPhone(image: win, in: rect(3180, 1040, 420, 884), rotate: 5, opacity: 0.92)
drawCleanDecor()
drawCopy()
NSGraphicsContext.restoreGraphicsState()

let panoramaURL = outputDir.appendingPathComponent("06-sliced-panorama-full.png")
try write(panorama, to: panoramaURL)
print(panoramaURL.path)

let panoramaImage = NSImage(size: canvasSize)
panoramaImage.addRepresentation(panorama)

let preview = makeBitmap(width: Int(canvasSize.width), height: Int(canvasSize.height))
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: preview)
panoramaImage.draw(in: rect(0, 0, canvasSize.width, canvasSize.height), from: .zero, operation: .sourceOver, fraction: 1)
for cut in 1..<sliceCount {
    let x = CGFloat(cut) * sliceSize.width
    let path = NSBezierPath()
    path.move(to: CGPoint(x: x, y: 0))
    path.line(to: CGPoint(x: x, y: canvasSize.height))
    color(0xffffff, 0.72).setStroke()
    path.lineWidth = 6
    path.setLineDash([26, 20], count: 2, phase: 0)
    path.stroke()
}
NSGraphicsContext.restoreGraphicsState()
let previewURL = outputDir.appendingPathComponent("06-sliced-panorama-preview.png")
try write(preview, to: previewURL)
print(previewURL.path)

for index in 0..<sliceCount {
    let slice = makeBitmap(width: Int(sliceSize.width), height: Int(sliceSize.height))
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: slice)
    panoramaImage.draw(
        in: rect(0, 0, sliceSize.width, sliceSize.height),
        from: rect(CGFloat(index) * sliceSize.width, 0, sliceSize.width, sliceSize.height),
        operation: .sourceOver,
        fraction: 1
    )
    NSGraphicsContext.restoreGraphicsState()

    let url = outputDir.appendingPathComponent(String(format: "06-sliced-panorama-%02d.png", index + 1))
    try write(slice, to: url)
    print(url.path)
}
