//
//  ResizingHandle.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/4/18.
//

import Cocoa

class ResizingHandle: NSView {
    var fillColor: NSColor = .controlAccentColor

    var borderColor: NSColor = .white

    var borderWidth: CGFloat = 1

    var cursor: NSCursor?

    override func draw(_ dirtyRect: NSRect) {
        guard dirtyRect.width >= 2 * borderWidth, dirtyRect.height >= 2 * borderWidth else {
            return
        }

        // Centering
        let size = min(dirtyRect.width, dirtyRect.height)
        let rect = NSRect(x: (dirtyRect.width - size) / 2,
                          y: (dirtyRect.height - size) / 2,
                          width: size,
                          height: size).insetBy(dx: borderWidth, dy: borderWidth)

        let path = NSBezierPath()
        path.appendOval(in: rect)
        fillColor.setFill()
        path.fill()
        borderColor.setStroke()
        path.lineWidth = borderWidth
        path.stroke()
    }
}
