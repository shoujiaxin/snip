//
//  SnipImageWindowController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/2.
//

import Cocoa
import SwiftUI

class SnipImageWindowController: NSWindowController {
    // MARK: - Views

    private let toolbar = NSHostingView(rootView: EditToolbar())

    // MARK: - States

    private let image: NSImage

    // MARK: - Lifecycle

    init(image: NSImage, location: NSPoint) {
        self.image = image

        super.init(window: SnipWindow(contentRect: NSRect(origin: location, size: image.size), styleMask: .borderless, backing: .buffered, defer: false))

        window?.aspectRatio = image.size
        window?.hasShadow = true
        window?.level = .statusBar
        window?.makeMain()
        window?.styleMask = .resizable

        window?.contentView?.wantsLayer = true
        window?.contentView?.layer?.contents = image

        toolbar.isHidden = true
        toolbar.rootView.delegate = self

        window?.contentView?.addSubview(toolbar)

        let doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(onDoubleClick))
        doubleClickGestureRecognizer.numberOfClicksRequired = 2
        window?.contentView?.addGestureRecognizer(doubleClickGestureRecognizer)

        updateToolbar()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Mouse & keyboard events

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        window?.performDrag(with: event)
    }

    override func keyDown(with event: NSEvent) {
        if event.characters == " " {
            toolbar.isHidden.toggle()
        }
    }

    override func cancelOperation(_: Any?) {
        SnipManager.shared.removeScreenshot(self)
    }

    @objc private func onDoubleClick() {
        window?.cancelOperation(self)
    }

    // MARK: - Private methods

    private func updateToolbar() {
        guard let frame = window?.frame else {
            return
        }

        let size = toolbar.intrinsicContentSize
        let origin = NSPoint(x: frame.width - size.width, y: 0)
        toolbar.frame = NSRect(origin: origin, size: size)
    }
}

// MARK: - EditToolbarDelegate

extension SnipImageWindowController: EditToolbarDelegate {
    func onSave() {
        // TODO: Save
    }

    func onCopy() {
        // TODO: Copy
    }

    func onDone() {
        toolbar.isHidden = true
    }
}
