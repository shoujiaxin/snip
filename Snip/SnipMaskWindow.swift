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

    private let maskLayer = CAShapeLayer()

    init(screen: NSScreen) {
        super.init(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)

        contentView?.wantsLayer = true
        contentView?.layer?.addSublayer(maskLayer)
        level = .statusBar
        maskLayer.fillColor = CGColor(gray: 0.5, alpha: 0.5)
        maskLayer.fillRule = .evenOdd

        CGDisplayCreateImage(CGMainDisplayID()).map { image in
            let screenshot = NSImage(cgImage: image, size: self.frame.size)
            self.backgroundColor = NSColor(patternImage: screenshot)
            updateMask()
        }
    }

    override func mouseDown(with event: NSEvent) {
        startPoint = event.locationInWindow
    }

    override func mouseDragged(with event: NSEvent) {
        endPoint = event.locationInWindow
        updateMask()
    }

    private func updateMask() {
        let path = CGMutablePath()
        path.addRect(CGRect(origin: .zero, size: frame.size))
        path.addRect(CGRect(origin: startPoint, size: CGSize(width: endPoint.x - startPoint.x, height: endPoint.y - startPoint.y)))

        maskLayer.path = path
    }
}
