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

    private let editor: SnipImageEditor

    /// The window's frame when scaling.
    private var scalingFrame: NSRect?

    /// The scale of the window when scaling.
    private var scalingFactor: CGFloat = 1.0

    // MARK: - Lifecycle

    init(image: NSImage, location: NSPoint) {
        editor = SnipImageEditor(image)

        super.init(window: SnipWindow(contentRect: .init(origin: location, size: image.size).insetBy(dx: -10, dy: -10), styleMask: .borderless, backing: .buffered, defer: false))

        window?.aspectRatio = image.size
        window?.backgroundColor = .clear
        window?.delegate = self
        window?.isOpaque = false
        window?.level = .init(Int(CGWindowLevel.max))
        window?.makeMain()

        window?.contentView = NSHostingView(rootView: SnipImageView().environmentObject(editor))

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

    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)

        switch event.phase {
        case .began:
            scalingFrame = window?.frame
            scalingFactor = 1.0
        case .changed:
            var delta = event.scrollingDeltaY / 60
            delta = min(delta, 0.1)
            delta = max(delta, -0.1)
            scalingFactor += delta
            scalingFactor = min(scalingFactor, 5)
            scalingFactor = max(scalingFactor, 0)
            scaled(by: scalingFactor, at: NSEvent.mouseLocation)
        default:
            return
        }
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

    private func scaled(by scale: CGFloat, at location: NSPoint) {
        guard let frame = scalingFrame else {
            return
        }

        let transform = CGAffineTransform(translationX: location.x, y: location.y)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: -location.x, y: -location.y)
        let scaledFrame = frame.applying(transform)
        if scaledFrame.width < 50 || scaledFrame.height < 50 {
            return
        }

        window?.setFrame(scaledFrame, display: true)
        editor.imageScaled(scaledFrame)
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
