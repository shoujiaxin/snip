//
//  Extensions.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/1.
//

import Cocoa

extension NSScreen {
    static var current: NSScreen? {
        screens.first { screen in
            screen.frame.contains(NSEvent.mouseLocation)
        }
    }

    var displayID: CGDirectDisplayID {
        deviceDescription[.init("NSScreenNumber")] as! CGDirectDisplayID
    }
}

extension NSRect {
    enum Corner {
        case bottomLeft
        case bottomRight
        case topLeft
        case topRight
    }

    enum Edge {
        case bottom
        case left
        case right
        case top
    }

    mutating func moveCorner(_ corner: Corner, dx: CGFloat, dy: CGFloat) {
        switch corner {
        case .bottomLeft:
            origin.x += dx
            origin.y += dy
            size.width -= dx
            size.height -= dy
        case .bottomRight:
            origin.y += dy
            size.width += dx
            size.height -= dy
        case .topLeft:
            origin.x += dx
            size.width -= dx
            size.height += dy
        case .topRight:
            size.width += dx
            size.height += dy
        }
    }

    mutating func moveEdge(_ edge: Edge, delta: CGFloat) {
        switch edge {
        case .bottom:
            origin.y += delta
            size.height -= delta
        case .left:
            origin.x += delta
            size.width -= delta
        case .right:
            size.width += delta
        case .top:
            size.height += delta
        }
    }

    mutating func offsetBy(dx: CGFloat, dy: CGFloat, in rect: NSRect) {
        let boundRect = rect.standardized
        var newRect = offsetBy(dx: dx, dy: dy).standardized

        if newRect.minX < boundRect.minX {
            newRect.origin.x = boundRect.minX
        }
        if newRect.minY < boundRect.minY {
            newRect.origin.y = boundRect.minY
        }
        if newRect.maxX > boundRect.maxX {
            newRect.origin.x = boundRect.maxX - newRect.width
        }
        if newRect.maxY > boundRect.maxY {
            newRect.origin.y = boundRect.maxY - newRect.height
        }

        self = newRect
    }
}
