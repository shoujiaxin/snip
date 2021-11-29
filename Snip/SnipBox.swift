//
//  SnipBox.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/29.
//

import Cocoa

class SnipBox: NSView {
    private enum DragPoint: CaseIterable {
        case bottomLeft
        case bottomMid
        case bottomRight
        case midLeft
        case midRight
        case topLeft
        case topMid
        case topRight

        func rect(in rect: NSRect, radius: CGFloat) -> NSRect {
            let x: CGFloat
            let y: CGFloat

            switch self {
            case .bottomLeft:
                x = NSMinX(rect)
                y = NSMinY(rect)
            case .bottomMid:
                x = NSMidX(rect)
                y = NSMinY(rect)
            case .bottomRight:
                x = NSMaxX(rect)
                y = NSMinY(rect)
            case .midLeft:
                x = NSMinX(rect)
                y = NSMidY(rect)
            case .midRight:
                x = NSMaxX(rect)
                y = NSMidY(rect)
            case .topLeft:
                x = NSMinX(rect)
                y = NSMaxY(rect)
            case .topMid:
                x = NSMidX(rect)
                y = NSMaxY(rect)
            case .topRight:
                x = NSMaxX(rect)
                y = NSMaxY(rect)
            }

            return NSMakeRect(x - radius, y - radius, 2 * radius, 2 * radius)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let rect = dirtyRect.insetBy(dx: 6, dy: 6)

        let border = NSBezierPath(rect: rect)
        border.lineWidth = 3
        NSColor.controlAccentColor.setStroke()
        border.stroke()

        if rect.width > 50, rect.height > 50 {
            let points = NSBezierPath()
            for point in DragPoint.allCases {
                points.appendOval(in: point.rect(in: rect, radius: 5.0))
            }
            NSColor.white.setFill()
            points.fill()
            NSColor.controlAccentColor.setStroke()
            points.stroke()
        }
    }
}
