#!/usr/bin/env swift
//
// make-icon.swift — generate AppIcon.icns for MarkdownViewer.
//
// Pure CoreGraphics, no SVG dependency, no brew. Runs on Apple CommandLineTools.
// The glyph (M + down arrow) is drawn from scratch with our own coordinates —
// not traced from any third-party mark — so no attribution / licensing issue.
//
// Usage: ./scripts/make-icon.swift <output-path>.icns
//        (or: swift scripts/make-icon.swift <output-path>.icns)
//

import AppKit
import CoreGraphics
import Foundation

let args = CommandLine.arguments
guard args.count == 2 else {
    FileHandle.standardError.write("usage: make-icon.swift <output-path>.icns\n".data(using: .utf8)!)
    exit(2)
}
let outputPath = args[1]

// MARK: - Drawing

/// Draws the icon at `size`×`size` and returns PNG-encoded bytes.
func drawIcon(size: CGFloat) -> Data {
    let width = Int(size)
    let height = Int(size)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesPerRow = width * 4
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

    guard let ctx = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: bitmapInfo
    ) else {
        fatalError("CGContext init failed at size \(size)")
    }

    // Flip so the y-axis points DOWN (matches the design coords used below).
    ctx.translateBy(x: 0, y: size)
    ctx.scaleBy(x: 1, y: -1)

    // Scale the 1024-design-canvas to the requested pixel size.
    let s = size / 1024.0
    ctx.scaleBy(x: s, y: s)

    // ---- Background: rounded-square (squircle approximation) with vertical gradient.
    let corner: CGFloat = 230  // ~22.5% of 1024 — Big Sur-ish corner radius
    let bgRect = CGRect(x: 0, y: 0, width: 1024, height: 1024)
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: corner, cornerHeight: corner, transform: nil)
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()

    // Indigo-500 → Blue-500 vertical gradient.
    let topColor = CGColor(red: 99/255.0,  green: 102/255.0, blue: 241/255.0, alpha: 1.0)   // #6366F1
    let botColor = CGColor(red: 59/255.0,  green: 130/255.0, blue: 246/255.0, alpha: 1.0)   // #3B82F6
    let gradient = CGGradient(
        colorsSpace: colorSpace,
        colors: [topColor, botColor] as CFArray,
        locations: [0.0, 1.0]
    )!
    // After the flip above, y=0 is the top of the icon in design coords.
    ctx.drawLinearGradient(
        gradient,
        start: CGPoint(x: 512, y: 0),
        end: CGPoint(x: 512, y: 1024),
        options: []
    )

    // Subtle inset highlight along the top edge for depth.
    let highlightPath = CGPath(roundedRect: bgRect, cornerWidth: corner, cornerHeight: corner, transform: nil)
    ctx.addPath(highlightPath)
    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.18))
    ctx.setLineWidth(6)
    ctx.strokePath()

    ctx.restoreGState()

    // ---- Glyph: white M and white down-arrow, hand-drawn coordinates.
    ctx.setFillColor(.white)

    // M shape — outline traced clockwise.
    // Bounding box: x ∈ [150, 630], y ∈ [340, 690].
    let m = CGMutablePath()
    m.move(to: CGPoint(x: 150, y: 690))   // bottom-left outer
    m.addLine(to: CGPoint(x: 150, y: 340)) // top-left outer
    m.addLine(to: CGPoint(x: 264, y: 340)) // top of left leg, inner side
    m.addLine(to: CGPoint(x: 390, y: 478)) // top of the V "bridge"
    m.addLine(to: CGPoint(x: 516, y: 340)) // top of right leg, inner side
    m.addLine(to: CGPoint(x: 630, y: 340)) // top-right outer
    m.addLine(to: CGPoint(x: 630, y: 690)) // bottom-right outer
    m.addLine(to: CGPoint(x: 516, y: 690)) // bottom of right leg, inner side
    m.addLine(to: CGPoint(x: 516, y: 500)) // top-right of inner V cutout
    m.addLine(to: CGPoint(x: 390, y: 638)) // bottom point of inner V cutout
    m.addLine(to: CGPoint(x: 264, y: 500)) // top-left of inner V cutout
    m.addLine(to: CGPoint(x: 264, y: 690)) // bottom of left leg, inner side
    m.closeSubpath()

    // Down-arrow shape — vertical bar with chevron tip.
    // Bounding box: x ∈ [670, 870], y ∈ [340, 690].
    let arrow = CGMutablePath()
    arrow.move(to: CGPoint(x: 670, y: 500))    // top-left of chevron base
    arrow.addLine(to: CGPoint(x: 730, y: 500)) // meets left edge of bar
    arrow.addLine(to: CGPoint(x: 730, y: 340)) // top-left of bar
    arrow.addLine(to: CGPoint(x: 830, y: 340)) // top-right of bar
    arrow.addLine(to: CGPoint(x: 830, y: 500)) // bottom-right of bar
    arrow.addLine(to: CGPoint(x: 870, y: 500)) // top-right of chevron base
    arrow.addLine(to: CGPoint(x: 770, y: 690)) // chevron tip (slightly offset for visual balance)
    arrow.closeSubpath()

    ctx.addPath(m)
    ctx.addPath(arrow)
    ctx.fillPath()

    // ---- Encode as PNG.
    guard let image = ctx.makeImage() else { fatalError("makeImage failed at size \(size)") }
    let rep = NSBitmapImageRep(cgImage: image)
    guard let png = rep.representation(using: .png, properties: [:]) else {
        fatalError("PNG encode failed at size \(size)")
    }
    return png
}

// MARK: - Iconset assembly

let fm = FileManager.default
let workDir = NSTemporaryDirectory() + "MarkdownViewer-AppIcon-\(UUID().uuidString)"
let iconsetDir = workDir + "/AppIcon.iconset"

try fm.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)
defer { try? fm.removeItem(atPath: workDir) }

// (pixel size, filename) — per iconutil's required iconset layout
let entries: [(Int, String)] = [
    (16,   "icon_16x16.png"),
    (32,   "icon_16x16@2x.png"),
    (32,   "icon_32x32.png"),
    (64,   "icon_32x32@2x.png"),
    (128,  "icon_128x128.png"),
    (256,  "icon_128x128@2x.png"),
    (256,  "icon_256x256.png"),
    (512,  "icon_256x256@2x.png"),
    (512,  "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

var pngCache: [Int: Data] = [:]
for (px, name) in entries {
    if pngCache[px] == nil {
        pngCache[px] = drawIcon(size: CGFloat(px))
    }
    let dest = URL(fileURLWithPath: "\(iconsetDir)/\(name)")
    try pngCache[px]!.write(to: dest)
}

// MARK: - iconutil → .icns

let outputURL = URL(fileURLWithPath: outputPath)
try? fm.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)

let task = Process()
task.launchPath = "/usr/bin/iconutil"
task.arguments = ["-c", "icns", "-o", outputURL.path, iconsetDir]
try task.run()
task.waitUntilExit()

guard task.terminationStatus == 0 else {
    FileHandle.standardError.write("iconutil failed with status \(task.terminationStatus)\n".data(using: .utf8)!)
    exit(1)
}

let attrs = try fm.attributesOfItem(atPath: outputURL.path)
let bytes = (attrs[.size] as? Int) ?? 0
print("→ \(outputURL.path) (\(bytes) bytes)")
