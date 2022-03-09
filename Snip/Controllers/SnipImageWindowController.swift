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

    private let toolbarWindow = NSWindow()

    // MARK: - States

    private let image: NSImage

    private let editor = SnipImageEditor()

    // MARK: - Lifecycle

    init(image: NSImage, location: NSPoint) {
        self.image = image

        super.init(window: SnipWindow(contentRect: .init(origin: location, size: image.size).insetBy(dx: -10, dy: -10), styleMask: .borderless, backing: .buffered, defer: false))

        window?.aspectRatio = image.size
        window?.backgroundColor = .clear
        window?.delegate = self
        window?.isOpaque = false
        window?.level = .init(Int(CGWindowLevel.max))
        window?.makeMain()

        window?.contentView = NSHostingView(rootView: SnipImageView(image: image).environmentObject(editor))

        let toolbar = NSHostingView(rootView: EditToolbar(delegate: self))
        toolbarWindow.alphaValue = 0
        toolbarWindow.backgroundColor = .clear
        toolbarWindow.contentView = toolbar
        toolbarWindow.isOpaque = false
        toolbarWindow.order(.above, relativeTo: window!.windowNumber)
        toolbarWindow.setFrame(.init(origin: .init(x: location.x + image.size.width - toolbar.intrinsicContentSize.width,
                                                   y: location.y - toolbar.intrinsicContentSize.height / 2),
                                     size: toolbar.intrinsicContentSize),
                               display: false)
        toolbarWindow.styleMask = .borderless
        window?.addChildWindow(toolbarWindow, ordered: .above)

        let doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(onDoubleClickGesture))
        doubleClickGestureRecognizer.numberOfClicksRequired = 2
        window?.contentView?.addGestureRecognizer(doubleClickGestureRecognizer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Mouse & keyboard events

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        window?.performDrag(with: event)
        toolbarWindow.performDrag(with: event)
    }

    override func keyDown(with event: NSEvent) {
        if event.characters == " " {
            toolbarWindow.alphaValue = 1 - toolbarWindow.alphaValue
        }
    }

    override func cancelOperation(_: Any?) {
        SnipManager.shared.removeScreenshot(self)
    }

    @objc private func onDoubleClickGesture() {
        window?.cancelOperation(self)
    }
}

// MARK: - NSWindowDelegate

extension SnipImageWindowController: NSWindowDelegate {
    func windowDidBecomeKey(_: Notification) {
        editor.isFocused = true
    }

    func windowDidResignKey(_: Notification) {
        editor.isFocused = false
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
        toolbarWindow.alphaValue = 0
    }
}
