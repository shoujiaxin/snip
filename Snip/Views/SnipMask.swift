//
//  SnipMask.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/29.
//

import Cocoa

class SnipMask: NSView {
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
                x = rect.minX
                y = rect.minY
            case .bottomMid:
                x = rect.midX
                y = rect.minY
            case .bottomRight:
                x = rect.maxX
                y = rect.minY
            case .midLeft:
                x = rect.minX
                y = rect.midY
            case .midRight:
                x = rect.maxX
                y = rect.midY
            case .topLeft:
                x = rect.minX
                y = rect.maxY
            case .topMid:
                x = rect.midX
                y = rect.maxY
            case .topRight:
                x = rect.maxX
                y = rect.maxY
            }

            return NSRect(x: x - radius, y: y - radius, width: 2 * radius, height: 2 * radius)
        }
    }

    var borderWidth: CGFloat = 3

    var dragPointRadius: CGFloat = 5.0

    var borderFrameWidth: CGFloat {
        2 * (dragPointRadius + NSBezierPath.defaultLineWidth)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let inset = borderFrameWidth / 2
        let rect = dirtyRect.insetBy(dx: inset, dy: inset)

        let border = NSBezierPath(rect: rect)
        border.lineWidth = borderWidth
        NSColor.controlAccentColor.setStroke()
        border.stroke()

        if rect.width > 50, rect.height > 50 {
            let points = NSBezierPath()
            for point in DragPoint.allCases {
                points.appendOval(in: point.rect(in: rect, radius: dragPointRadius))
            }
            NSColor.controlAccentColor.setFill()
            points.fill()
            NSColor.white.setStroke()
            points.stroke()
        }
    }
}

extension SnipMask {
    var contentFrame: NSRect {
        frame.insetBy(dx: borderFrameWidth, dy: borderFrameWidth)
    }

    var bottomLeftCornerFrame: NSRect {
        NSRect(x: frame.minX, y: frame.minY, width: borderFrameWidth, height: borderFrameWidth)
    }

    var bottomRightCornerFrame: NSRect {
        NSRect(x: frame.maxX - borderFrameWidth, y: frame.minY, width: borderFrameWidth, height: borderFrameWidth)
    }

    var topLeftCornerFrame: NSRect {
        NSRect(x: frame.minX, y: frame.maxY - borderFrameWidth, width: borderFrameWidth, height: borderFrameWidth)
    }

    var topRightCornerFrame: NSRect {
        NSRect(x: frame.maxX - borderFrameWidth, y: frame.maxY - borderFrameWidth, width: borderFrameWidth, height: borderFrameWidth)
    }

    var bottomBorderFrame: NSRect {
        NSRect(x: frame.minX, y: frame.minY, width: frame.width, height: borderFrameWidth)
    }

    var leftBorderFrame: NSRect {
        NSRect(x: frame.minX, y: frame.minY, width: borderFrameWidth, height: frame.height)
    }

    var rightBorderFrame: NSRect {
        NSRect(x: frame.maxX - borderFrameWidth, y: frame.minY, width: borderFrameWidth, height: frame.height)
    }

    var topBorderFrame: NSRect {
        NSRect(x: frame.minX, y: frame.maxY - borderFrameWidth, width: frame.width, height: borderFrameWidth)
    }
}
