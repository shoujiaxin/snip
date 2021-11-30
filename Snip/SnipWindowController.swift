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
        let frame = screen.frame
        // TODO: Screenshot
        screenshot = NSImage(cgImage: CGDisplayCreateImage(CGMainDisplayID())!, size: frame.size)

        super.init(window: NSWindow(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false))

        window?.backgroundColor = NSColor(patternImage: screenshot)
        window?.level = .statusBar

        contentViewController = SnipMaskViewController(frame: frame)

        showWindow(self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
