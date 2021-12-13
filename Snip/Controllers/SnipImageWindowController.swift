//
//  SnipImageWindowController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/2.
//

import Cocoa

class SnipImageWindowController: NSWindowController {
    // MARK: - Lifecycle

    init(image: NSImage, location: NSPoint) {
        super.init(window: SnipImageWindow(contentRect: NSRect(origin: location, size: image.size), styleMask: .borderless, backing: .buffered, defer: false))

        window?.hasShadow = true
        window?.level = .statusBar
        window?.makeMain()

        window?.contentView = NSImageView(image: image)
        window?.contentView?.frame = NSRect(origin: .zero, size: image.size)

        let doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(onDoubleClick))
        doubleClickGestureRecognizer.numberOfClicksRequired = 2
        window?.contentView?.addGestureRecognizer(doubleClickGestureRecognizer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Mouse events

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        window?.performDrag(with: event)
    }

    @objc private func onDoubleClick() {
        window?.cancelOperation(self)
    }
}
