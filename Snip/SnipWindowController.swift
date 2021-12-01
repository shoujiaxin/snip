//
//  SnipWindowController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/28.
//

import Cocoa

class SnipWindowController: NSWindowController {
    private let screenshot: NSImage

    init(screen: NSScreen) {
        let frame = NSRect(origin: .zero, size: screen.frame.size)
        screenshot = NSImage(cgImage: CGDisplayCreateImage(screen.displayID)!, size: frame.size)

        super.init(window: SnipWindow(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false, screen: screen))

        window?.backgroundColor = NSColor(patternImage: screenshot)
        window?.level = .statusBar

        contentViewController = SnipMaskViewController(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
