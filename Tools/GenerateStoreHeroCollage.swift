import AppKit
import Foundation

let canvasSize = CGSize(width: 1920, height: 1080)
let outputURL = URL(fileURLWithPath: "Marketing/AppStoreScreenshots/00-hero-collage.png")
let logo = NSImage(contentsOfFile: "TigerLagoon/Assets.xcassets/LagoonLogo.imageset/lagoon-logo.png")
let gameplay = NSImage(contentsOfFile: "Marketing/AppStoreScreenshots/02-gameplay.png")
let home = NSImage(contentsOfFile: "Marketing/AppStoreScreenshots/01-home.png")
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
    NSGradient(colors: [color(0xfff0b2), color(0xff4438), color(0x9b0d4d), color(0x4b0a4f)])?
        .draw(in: rect(0, 0, canvasSize.width, canvasSize.height), angle: -28)

    NSGradient(colors: [color(0x60d6f5, 0.68), color(0xffffff, 0.08), .clear])?
        .draw(in: rect(-120, 560, 760, 560), angle: 15)
    NSGradient(colors: [color(0xffe15a, 0.58), color(0xff6fb1, 0.22), .clear])?
        .draw(in: rect(1050, 120, 980, 820), angle: -20)

    for index in 0..<70 {
        let x = CGFloat((index * 197 + 41) % Int(canvasSize.width + 180)) - 90
        let y = CGFloat((index * 113 + 77) % Int(canvasSize.height + 140)) - 70
        let size = CGFloat(index.isMultiple(of: 5) ? 40 : 18)
        let path = rounded(rect(x, y, size, size), size / 2)
        (index.isMultiple(of: 5) ? color(0xffe15a, 0.7) : color(0xffffff, 0.3)).setFill()
        path.fill()
    }

    drawFruit(rect(30, 770, 220, 220), rotate: -12)
    drawFruit(rect(1690, 30, 180, 180), rotate: 18)
    drawEnvelope(rect(104, 132, 170, 124), rotate: -20)
    drawEnvelope(rect(1580, 728, 170, 124), rotate: 20)
}

func drawPhone(image: NSImage?, in frame: CGRect, rotate degrees: CGFloat) {
    guard let image else { return }

    NSGraphicsContext.saveGraphicsState()
    let transform = NSAffineTransform()
    transform.translateX(by: frame.midX, yBy: frame.midY)
    transform.rotate(byDegrees: degrees)
    transform.translateX(by: -frame.midX, yBy: -frame.midY)
    transform.concat()

    let shadow = NSShadow()
    shadow.shadowColor = .black.withAlphaComponent(0.48)
    shadow.shadowBlurRadius = 28
    shadow.shadowOffset = CGSize(width: 0, height: -12)
    shadow.set()

    color(0x050507).setFill()
    rounded(frame, 58).fill()
    NSShadow().set()

    let bezel = frame.insetBy(dx: 11, dy: 11)
    color(0x1f2028).setStroke()
    rounded(bezel, 49).lineWidth = 5
    rounded(bezel, 49).stroke()

    let screen = frame.insetBy(dx: 22, dy: 22)
    NSGraphicsContext.saveGraphicsState()
    rounded(screen, 42).addClip()
    image.draw(in: screen, from: .zero, operation: .sourceOver, fraction: 1)
    NSGraphicsContext.restoreGraphicsState()

    color(0x000000).setFill()
    rounded(rect(frame.midX - frame.width * 0.18, frame.maxY - 68, frame.width * 0.36, 42), 21).fill()

    NSGraphicsContext.restoreGraphicsState()
}

func drawTigerHero() {
    guard let logo else { return }

    let glow = NSBezierPath(ovalIn: rect(472, 196, 836, 780))
    NSGradient(colors: [color(0xffe15a, 0.36), color(0xff5a36, 0.14), .clear])?
        .draw(in: glow, relativeCenterPosition: .zero)

    logo.draw(in: rect(526, 198, 720, 720), from: .zero, operation: .sourceOver, fraction: 1)

    drawText("TIGER LAGOON", in: rect(522, 98, 744, 82), size: 72, weight: .black, color: .white, align: .center)
    drawText("Festival puzzle levels, boosters and star wins", in: rect(570, 48, 650, 42), size: 30, weight: .heavy, color: color(0xfff0b2), align: .center)
}

func drawLightSwirls() {
    for offset in [0, 52, 104] as [CGFloat] {
        let path = NSBezierPath()
        path.move(to: CGPoint(x: 230 + offset, y: 318 + offset * 0.1))
        path.curve(to: CGPoint(x: 1670 - offset * 0.45, y: 508 + offset * 0.2), controlPoint1: CGPoint(x: 560, y: 144 + offset), controlPoint2: CGPoint(x: 1200, y: 856 - offset))
        color(0xffe15a, 0.56 - offset / 260).setStroke()
        path.lineWidth = 8 - offset / 28
        path.stroke()
    }

    for index in 0..<42 {
        let x = CGFloat(240 + (index * 37) % 1320)
        let y = CGFloat(250 + (index * 83) % 420)
        color(index.isMultiple(of: 3) ? 0xffe15a : 0xffffff, 0.78).setFill()
        NSBezierPath(ovalIn: rect(x, y, 10, 10)).fill()
    }
}

func drawCoins() {
    for index in 0..<30 {
        let x = CGFloat(80 + (index * 151) % 1760)
        let y = CGFloat(110 + (index * 97) % 850)
        let w = CGFloat(index.isMultiple(of: 4) ? 50 : 34)
        let coin = NSBezierPath(ovalIn: rect(x, y, w, w * 0.78))
        color(0xffe15a).setFill()
        coin.fill()
        color(0xffffff, 0.45).setStroke()
        coin.lineWidth = 2
        coin.stroke()
    }
}

func drawFruit(_ r: CGRect, rotate degrees: CGFloat) {
    NSGraphicsContext.saveGraphicsState()
    let t = NSAffineTransform()
    t.translateX(by: r.midX, yBy: r.midY)
    t.rotate(byDegrees: degrees)
    t.translateX(by: -r.midX, yBy: -r.midY)
    t.concat()
    NSGradient(colors: [color(0xffb340), color(0xff7a22)])?.draw(in: NSBezierPath(ovalIn: r), angle: 12)
    color(0x39c96b).setFill()
    NSBezierPath(ovalIn: rect(r.midX - 20, r.maxY - 8, 72, 34)).fill()
    NSGraphicsContext.restoreGraphicsState()
}

func drawEnvelope(_ r: CGRect, rotate degrees: CGFloat) {
    NSGraphicsContext.saveGraphicsState()
    let t = NSAffineTransform()
    t.translateX(by: r.midX, yBy: r.midY)
    t.rotate(byDegrees: degrees)
    t.translateX(by: -r.midX, yBy: -r.midY)
    t.concat()
    color(0xd71932).setFill()
    rounded(r, 14).fill()
    color(0xffe15a).setStroke()
    rounded(r.insetBy(dx: 10, dy: 10), 10).lineWidth = 4
    rounded(r.insetBy(dx: 10, dy: 10), 10).stroke()
    drawText("福", in: r.insetBy(dx: 10, dy: 12), size: 58, weight: .black, color: color(0xffe15a), align: .center)
    NSGraphicsContext.restoreGraphicsState()
}

try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)

guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(canvasSize.width),
    pixelsHigh: Int(canvasSize.height),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fatalError("Unable to create hero bitmap")
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
drawBackground()
drawPhone(image: home, in: rect(214, 132, 390, 820), rotate: -17)
drawPhone(image: gameplay, in: rect(1084, 122, 402, 846), rotate: 11)
drawPhone(image: gameplay, in: rect(1540, 264, 254, 536), rotate: 4)
drawLightSwirls()
drawCoins()
drawTigerHero()
drawEnvelope(rect(1340, 112, 176, 126), rotate: -16)
NSGraphicsContext.restoreGraphicsState()

guard let data = rep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode hero collage")
}
try data.write(to: outputURL, options: .atomic)
print(outputURL.path)
