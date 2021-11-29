//
//  SnipMaskWindow.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/28.
//

import Cocoa

class SnipMaskWindow: NSWindow {
    /// Start position of dragging
    private var startPoint: NSPoint = .zero

    /// End position of dragging
    private var endPoint: NSPoint = .zero

    private var snipRect: NSRect {
        let minX = min(startPoint.x, endPoint.x)
        let minY = min(startPoint.y, endPoint.y)
        let width = abs(endPoint.x - startPoint.x)
        let height = abs(endPoint.y - startPoint.y)
        return NSMakeRect(minX, minY, width, height)
    }

    private let maskLayer = CAShapeLayer()

    private let snipBox = SnipBox(frame: .zero)

    init(screen: NSScreen) {
        super.init(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)

        maskLayer.fillColor = CGColor(gray: 0.5, alpha: 0.5)
        maskLayer.fillRule = .evenOdd

        contentView?.addSubview(snipBox)
        contentView?.wantsLayer = true
        contentView?.layer?.addSublayer(maskLayer)
        level = .statusBar

        CGDisplayCreateImage(CGMainDisplayID()).map { image in
            let screenshot = NSImage(cgImage: image, size: self.frame.size)
            self.backgroundColor = NSColor(patternImage: screenshot)
            updateMask()
        }
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        startPoint = event.locationInWindow
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        endPoint = event.locationInWindow
        updateMask()
    }

    private func updateMask() {
        let path = CGMutablePath()
        path.addRect(frame)
        path.addRect(snipRect)

        maskLayer.path = path
        snipBox.frame = snipRect.insetBy(dx: -6, dy: -6)

        updateTrackingArea()
    }

    private func updateTrackingArea() {}
}
