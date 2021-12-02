//
//  SnipImageWindowController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/2.
//

import Cocoa

class SnipImageWindowController: NSWindowController {
    init(image: NSImage, origin: NSPoint, screen: NSScreen?) {
        super.init(window: SnipImageWindow(contentRect: NSRect(origin: origin, size: image.size), styleMask: .borderless, backing: .buffered, defer: false, screen: screen))

        window?.hasShadow = true
        window?.level = .statusBar
        window?.makeMain()

        window?.contentView = NSImageView(image: image)
        window?.contentView?.frame = NSRect(origin: .zero, size: image.size)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        if let origin = window?.frame.origin {
            window?.setFrameOrigin(NSPoint(x: origin.x + event.deltaX, y: origin.y - event.deltaY))
        }
    }
}
