import AppKit
import Foundation

let canvasSize = CGSize(width: 1290, height: 2796)
let outputDir = URL(fileURLWithPath: "Marketing/AppStoreScreenshots", isDirectory: true)
let logo = NSImage(contentsOfFile: "TigerLagoon/Assets.xcassets/LagoonLogo.imageset/lagoon-logo.png")

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

func drawText(_ text: String, in rect: CGRect, size: CGFloat, weight: NSFont.Weight = .bold, color: NSColor = .white, align: NSTextAlignment = .left) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = align
    paragraph.lineBreakMode = .byWordWrapping
    let font = NSFont.systemFont(ofSize: size, weight: weight)
    text.draw(
        in: rect,
        withAttributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
    )
}

func drawBackground(title: String, subtitle: String) {
    NSGradient(colors: [color(0xff4438), color(0xc7193b), color(0x4b0a4f)])?
        .draw(in: rect(0, 0, canvasSize.width, canvasSize.height), angle: -42)

    for index in 0..<56 {
        let x = CGFloat((index * 137) % Int(canvasSize.width))
        let y = CGFloat((index * 211) % Int(canvasSize.height))
        let size = CGFloat(index.isMultiple(of: 4) ? 20 : 13)
        let dot = rounded(rect(x, y, size, size), size / 2)
        (index.isMultiple(of: 4) ? color(0xffe15a, 0.78) : color(0xffb6cf, 0.45)).setFill()
        dot.fill()
    }

    drawText(title, in: rect(84, 176, 1122, 132), size: 72, weight: .black, align: .center)
    drawText(subtitle, in: rect(132, 306, 1026, 82), size: 32, weight: .heavy, color: color(0xfff1bd), align: .center)
}

func drawPhone(_ body: (CGRect) -> Void) {
    let frame = rect(132, 462, 1026, 2102)
    let screen = frame.insetBy(dx: 38, dy: 38)
    NSShadow().apply {
        $0.shadowColor = .black.withAlphaComponent(0.36)
        $0.shadowBlurRadius = 34
        $0.shadowOffset = CGSize(width: 0, height: -18)
    }
    color(0x050507).setFill()
    rounded(frame, 92).fill()
    NSShadow().set()

    color(0x1c1c22).setStroke()
    rounded(frame.insetBy(dx: 8, dy: 8), 84).lineWidth = 5
    rounded(frame.insetBy(dx: 8, dy: 8), 84).stroke()

    NSGraphicsContext.saveGraphicsState()
    rounded(screen, 68).addClip()
    body(screen)
    NSGraphicsContext.restoreGraphicsState()

    color(0x000000).setFill()
    rounded(rect(frame.midX - 178, frame.maxY - 118, 356, 78), 39).fill()
}

func drawScreenBackground(_ screen: CGRect, level: Int = 2) {
    NSGradient(colors: [color(0xff4438), color(0xc7193b), color(0x58092f)])?
        .draw(in: screen, angle: -60)
    let roof = NSBezierPath()
    roof.move(to: CGPoint(x: screen.minX - 20, y: screen.maxY - 560))
    roof.curve(to: CGPoint(x: screen.maxX + 20, y: screen.maxY - 560), controlPoint1: CGPoint(x: screen.midX - 260, y: screen.maxY - 385), controlPoint2: CGPoint(x: screen.midX + 260, y: screen.maxY - 385))
    roof.line(to: CGPoint(x: screen.maxX + 20, y: screen.maxY - 690))
    roof.curve(to: CGPoint(x: screen.minX - 20, y: screen.maxY - 690), controlPoint1: CGPoint(x: screen.midX + 260, y: screen.maxY - 590), controlPoint2: CGPoint(x: screen.midX - 260, y: screen.maxY - 590))
    roof.close()
    NSGradient(colors: [color(0x12a86b), color(0x066b47)])?.draw(in: roof, angle: 0)
}

func pill(_ text: String, _ r: CGRect, fill: NSColor = color(0x5d092b, 0.7), textColor: NSColor = .white) {
    fill.setFill()
    rounded(r, min(r.height / 2, 30)).fill()
    color(0xffffff, 0.14).setStroke()
    rounded(r, min(r.height / 2, 30)).lineWidth = 2
    rounded(r, min(r.height / 2, 30)).stroke()
    drawText(text, in: r.insetBy(dx: 18, dy: 12), size: min(32, r.height * 0.38), weight: .black, color: textColor, align: .center)
}

func card(_ r: CGRect, fill: NSColor = color(0x000000, 0.22), stroke: NSColor = color(0xffffff, 0.13)) {
    fill.setFill()
    rounded(r, 28).fill()
    stroke.setStroke()
    rounded(r, 28).lineWidth = 2
    rounded(r, 28).stroke()
}

func drawLogo(_ r: CGRect) {
    logo?.draw(in: r, from: .zero, operation: .sourceOver, fraction: 1)
}

func drawBoard(_ r: CGRect) {
    card(r, fill: color(0x4b0828, 0.78), stroke: color(0xffe15a, 0.7))
    let gap: CGFloat = 12
    let cell = (r.width - 52 - gap * 5) / 6
    let kinds = [0xff5a36, 0xff6fb1, 0xffe18a, 0x39c96b, 0x60d6f5, 0xffe15a]
    let icons = ["◆", "✿", "✸", "♣", "☾", "●"]
    for y in 0..<6 {
        for x in 0..<6 {
            let tile = rect(r.minX + 26 + CGFloat(x) * (cell + gap), r.minY + 26 + CGFloat(5 - y) * (cell + gap), cell, cell)
            let idx = (x * 2 + y * 3 + 2) % kinds.count
            color(kinds[idx], 0.34).setFill()
            rounded(tile, 18).fill()
            drawText(icons[idx], in: tile.insetBy(dx: 4, dy: 10), size: 42, weight: .black, color: color(kinds[idx]), align: .center)
        }
    }
    drawLogo(rect(r.midX - cell * 0.68, r.midY - cell * 0.68, cell * 1.36, cell * 1.36))
}

func drawHome(_ screen: CGRect) {
    drawScreenBackground(screen)
    pill("227", rect(screen.minX + 42, screen.maxY - 162, 170, 82), fill: color(0x6b0a24, 0.58))
    pill("GUIDE", rect(screen.maxX - 230, screen.maxY - 168, 188, 90), fill: color(0x7b0c2f, 0.48))
    let hero = rect(screen.minX + 44, screen.maxY - 620, screen.width - 88, 380)
    card(hero, fill: color(0xff526d, 0.86), stroke: color(0xffe15a, 0.48))
    drawText("CHAPTER 2", in: rect(hero.minX + 44, hero.maxY - 88, 420, 44), size: 30, weight: .black, color: color(0xffffff, 0.72))
    drawText("Cherry\nBridge", in: rect(hero.minX + 44, hero.minY + 132, 430, 150), size: 62, weight: .black)
    pill("Open Journey", rect(hero.minX + 44, hero.minY + 54, 404, 92), fill: color(0xffe15a), textColor: .white)
    drawLogo(rect(hero.maxX - 326, hero.minY + 82, 240, 240))
    card(rect(screen.minX + 44, screen.maxY - 830, screen.width - 88, 148), fill: color(0x5b0828, 0.55))
    drawText("Journey Progress", in: rect(screen.minX + 230, screen.maxY - 766, 520, 48), size: 42, weight: .black)
    drawText("2 / 24", in: rect(screen.maxX - 250, screen.maxY - 766, 160, 48), size: 36, weight: .black, color: color(0xffe15a), align: .right)
    card(rect(screen.minX + 44, screen.maxY - 1018, screen.width - 88, 148), fill: color(0x5b0828, 0.55))
    drawText("Festival Play", in: rect(screen.minX + 230, screen.maxY - 954, 520, 48), size: 42, weight: .black)
    pill("SHOP", rect(screen.minX + 44, screen.maxY - 1162, 410, 96), fill: color(0xffe15a))
    pill("ACHIEVEMENTS", rect(screen.maxX - 454, screen.maxY - 1162, 410, 96), fill: color(0x12a86b))
    drawTabBar(screen, active: "Home")
}

func drawGame(_ screen: CGRect) {
    drawScreenBackground(screen)
    pill("HOME", rect(screen.minX + 42, screen.maxY - 176, 210, 92), fill: color(0x890b2d, 0.55))
    drawText("TIGER LAGOON", in: rect(screen.minX + 248, screen.maxY - 160, 454, 64), size: 42, weight: .black, align: .center)
    let status = rect(screen.minX + 44, screen.maxY - 550, screen.width - 88, 320)
    card(status, fill: color(0x5b0828, 0.56), stroke: color(0xffe15a, 0.4))
    drawLogo(rect(status.minX + 28, status.maxY - 116, 90, 90))
    drawText("LEVEL 8", in: rect(status.minX + 140, status.maxY - 78, 240, 34), size: 24, weight: .black, color: color(0xffe15a))
    drawText("TIGER SKY", in: rect(status.minX + 140, status.maxY - 128, 420, 52), size: 40, weight: .black)
    pill("28 MOVES", rect(status.maxX - 262, status.maxY - 112, 220, 72), fill: color(0x0c7048, 0.58))
    pill("4/5 TRAILS", rect(status.maxX - 262, status.maxY - 196, 220, 72), fill: color(0x800d3c, 0.58))
    drawText("SCORE 1290/1360", in: rect(status.minX + 38, status.minY + 82, 390, 34), size: 28, weight: .black)
    color(0x1d0618, 0.7).setFill(); rounded(rect(status.minX + 38, status.minY + 48, status.width - 76, 22), 11).fill()
    color(0xffe15a).setFill(); rounded(rect(status.minX + 38, status.minY + 48, status.width * 0.72, 22), 11).fill()
    drawBoard(rect(screen.minX + 78, screen.maxY - 1338, screen.width - 156, screen.width - 156))
    pill("ROAR 2", rect(screen.minX + 58, screen.minY + 220, 390, 100), fill: color(0xff5a36))
    pill("BEACON 3", rect(screen.maxX - 448, screen.minY + 220, 390, 100), fill: color(0x60d6f5))
    pill("COLLECT THE NEXT RUNE", rect(screen.minX + 76, screen.minY + 94, screen.width - 152, 82), fill: color(0x4b0626, 0.78))
}

func drawWin(_ screen: CGRect) {
    drawScreenBackground(screen, level: 12)
    drawBoard(rect(screen.minX + 96, screen.maxY - 1200, screen.width - 192, screen.width - 192))
    color(0x000000, 0.48).setFill()
    screen.fill()
    let overlay = rect(screen.minX + 90, screen.midY - 390, screen.width - 180, 780)
    NSGradient(colors: [color(0xf33248), color(0x64124a)])?.draw(in: rounded(overlay, 40), angle: -80)
    color(0xffe15a).setStroke(); rounded(overlay, 40).lineWidth = 4; rounded(overlay, 40).stroke()
    drawLogo(rect(overlay.midX - 118, overlay.maxY - 260, 236, 236))
    drawText("3 STARS", in: rect(overlay.minX + 40, overlay.maxY - 352, overlay.width - 80, 76), size: 64, weight: .black, color: color(0xffe15a), align: .center)
    drawText("Level Complete", in: rect(overlay.minX + 40, overlay.maxY - 418, overlay.width - 80, 42), size: 34, weight: .black, align: .center)
    drawText("★ ★ ★", in: rect(overlay.minX + 40, overlay.maxY - 506, overlay.width - 80, 66), size: 58, weight: .black, color: color(0xffe15a), align: .center)
    drawText("+54 COINS", in: rect(overlay.minX + 40, overlay.maxY - 610, overlay.width - 80, 60), size: 48, weight: .black, color: color(0xffe15a), align: .center)
    pill("NEXT LEVEL", rect(overlay.minX + 76, overlay.minY + 66, overlay.width - 152, 96), fill: color(0x12a86b))
}

func drawJourney(_ screen: CGRect) {
    drawScreenBackground(screen, level: 4)
    drawText("JOURNEY", in: rect(screen.minX + 250, screen.maxY - 168, 450, 64), size: 50, weight: .black, align: .center)
    for i in 0..<7 {
        let y = screen.maxY - 308 - CGFloat(i) * 178
        let unlocked = i < 5
        let row = rect(screen.minX + 54, y - 120, screen.width - 108, 136)
        card(row, fill: color(0x000000, unlocked ? 0.27 : 0.13))
        pill("\(i + 1)", rect(row.minX + 28, row.minY + 32, 72, 72), fill: color(0x000000, 0.24), textColor: unlocked ? color(0xffe15a) : color(0xffffff, 0.45))
        drawText(["Lantern Gate", "Cherry Bridge", "Golden Drum", "Firework Pier", "Jade Roof", "Red Envelope Run", "Temple Steps"][i], in: rect(row.minX + 130, row.maxY - 76, 430, 42), size: 34, weight: .black, color: unlocked ? .white : color(0xffffff, 0.45))
        drawText(unlocked ? "Score target • trail goals" : "Locked", in: rect(row.minX + 130, row.minY + 32, 430, 34), size: 24, weight: .bold, color: color(0xffffff, 0.68))
        drawText(unlocked ? "★ ★ ★" : "🔒", in: rect(row.maxX - 188, row.minY + 40, 150, 44), size: 32, weight: .black, color: color(0xffe15a), align: .right)
    }
    drawTabBar(screen, active: "Journey")
}

func drawShop(_ screen: CGRect) {
    drawScreenBackground(screen, level: 6)
    pill("227 COINS", rect(screen.maxX - 270, screen.maxY - 160, 220, 82), fill: color(0x5b0828, 0.58))
    drawText("TIGER SHOP", in: rect(screen.minX + 70, screen.maxY - 260, screen.width - 140, 70), size: 56, weight: .black, align: .center)
    let items = [
        ("Tiger Roar", "Clear row and column", "35", 0xff5a36),
        ("Moon Beacon", "Hold one tile above water", "25", 0x60d6f5),
        ("Move Charm", "+3 moves next level", "55", 0x12a86b),
        ("Golden Tiger", "Permanent luxury style", "160", 0xffe15a),
        ("Blossom Festival", "Bright petal celebration", "140", 0xff6fb1)
    ]
    for (i, item) in items.enumerated() {
        let row = rect(screen.minX + 54, screen.maxY - 430 - CGFloat(i) * 190, screen.width - 108, 148)
        card(row, fill: color(0x000000, 0.25), stroke: color(item.3, 0.32))
        color(item.3, 0.24).setFill(); rounded(rect(row.minX + 28, row.minY + 30, 88, 88), 22).fill()
        drawText("✦", in: rect(row.minX + 28, row.minY + 46, 88, 64), size: 44, weight: .black, color: color(item.3), align: .center)
        drawText(item.0, in: rect(row.minX + 142, row.maxY - 66, 420, 42), size: 34, weight: .black)
        drawText(item.1, in: rect(row.minX + 142, row.minY + 36, 430, 32), size: 24, weight: .bold, color: color(0xffffff, 0.68))
        pill(item.2, rect(row.maxX - 144, row.minY + 38, 106, 72), fill: color(item.3))
    }
}

func drawTabBar(_ screen: CGRect, active: String) {
    let bar = rect(screen.minX + 54, screen.minY + 54, screen.width - 108, 124)
    card(bar, fill: color(0x33051f, 0.74))
    let tabs = ["Home", "Journey", "Play", "Archive", "Settings"]
    for (idx, tab) in tabs.enumerated() {
        let w = bar.width / CGFloat(tabs.count)
        let r = rect(bar.minX + CGFloat(idx) * w + 8, bar.minY + 14, w - 16, 96)
        if tab == active {
            color(0xffe15a).setFill()
            rounded(r, 24).fill()
        }
        drawText(tab, in: rect(r.minX, r.minY + 26, r.width, 32), size: 20, weight: .black, color: tab == active ? .black : color(0xffffff, 0.72), align: .center)
    }
}

extension NSShadow {
    func apply(_ configure: (NSShadow) -> Void) {
        configure(self)
        set()
    }
}

let screens: [(String, String, String, (CGRect) -> Void)] = [
    ("01-home.png", "Tiger Lagoon", "bright puzzle runs for iPhone", drawHome),
    ("02-gameplay.png", "Leap. Match. Open Trails.", "tap tiles, collect runes, beat the tide", drawGame),
    ("03-win.png", "Earn 1-3 Stars", "complete goals and unlock the next level", drawWin),
    ("04-journey.png", "24 Level Journey", "progress through festival puzzle chapters", drawJourney),
    ("05-shop.png", "Boosters & Achievements", "use coins for roars, beacons, charms and style", drawShop)
]

try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

for screen in screens {
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
        fatalError("Unable to create bitmap")
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    drawBackground(title: screen.1, subtitle: screen.2)
    drawPhone(screen.3)
    NSGraphicsContext.restoreGraphicsState()

    let url = outputDir.appendingPathComponent(screen.0)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        fatalError("Unable to encode \(screen.0)")
    }
    try data.write(to: url, options: .atomic)
    print(url.path)
}
