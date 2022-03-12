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

    /// The mouse location when scaling begins.
    private var scalingCenter: NSPoint = .zero

    // MARK: - Lifecycle

    init(image: NSImage, location: NSPoint) {
        editor = SnipImageEditor(image)

        super.init(window: SnipWindow(contentRect: .init(origin: location, size: image.size).insetBy(dx: -20, dy: -20), styleMask: .borderless, backing: .buffered, defer: false))

        window?.aspectRatio = image.size
        window?.backgroundColor = .clear
        window?.delegate = self
        window?.isOpaque = false
        window?.level = .init(Int(CGWindowLevel.max))
        window?.makeMain()

        window?.contentView = NSHostingView(rootView: SnipImageView().environmentObject(editor))

        let toolbarItems: [ToolbarItem] = [
            .tabItem(name: "Shape", iconName: "rectangle") {},
            .tabItem(name: "Arrow", iconName: "arrow.up.right") {},
            .tabItem(name: "Draw", iconName: "scribble") {},
            .tabItem(name: "Highlight", iconName: "highlighter") {},
            .tabItem(name: "Mosaic", iconName: "mosaic") {},
            .tabItem(name: "Text", iconName: "character") {},
            .divider,
            .button(name: "Undo", iconName: "arrow.uturn.backward") {},
            .button(name: "Redo", iconName: "arrow.uturn.forward") {},
            .divider,
            .button(name: "Save", iconName: "square.and.arrow.down") { [weak self] in self?.onSave() },
            .button(name: "Copy", iconName: "doc.on.doc") { [weak self] in self?.onCopy() },
            .button(name: "Done", iconName: "checkmark") { [weak self] in self?.onDone() },
        ]
        let toolbar = NSHostingView(rootView: ToolbarView(items: toolbarItems))
        toolbarWindow.animationBehavior = .utilityWindow
        toolbarWindow.backgroundColor = .clear
        toolbarWindow.contentView = toolbar
        toolbarWindow.isOpaque = false
        toolbarWindow.styleMask = .borderless
        toolbarWindow.setFrame(.init(origin: .zero, size: toolbar.intrinsicContentSize), display: false)

        let doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(onDoubleClickGesture))
        doubleClickGestureRecognizer.numberOfClicksRequired = 2
        window?.contentView?.addGestureRecognizer(doubleClickGestureRecognizer)

        hideToolbar()
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

    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)

        switch event.phase {
        case .began:
            scalingFrame = window?.frame
            scalingFactor = 1.0
            scalingCenter = NSEvent.mouseLocation
        case .changed:
            var delta = event.scrollingDeltaY / 60
            delta = min(delta, 0.1)
            delta = max(delta, -0.1)
            scalingFactor += delta
            scalingFactor = min(scalingFactor, 5)
            scalingFactor = max(scalingFactor, 0)
            scaled(by: scalingFactor, at: scalingCenter)
        default:
            return
        }
    }

    override func keyDown(with event: NSEvent) {
        if event.characters == " " {
            if toolbarWindow.isVisible {
                hideToolbar()
            } else {
                showToolbar()
            }
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

    private func hideToolbar() {
        toolbarWindow.setIsVisible(false)
        window?.removeChildWindow(toolbarWindow)
    }

    private func showToolbar() {
        guard let frame = window?.frame else {
            return
        }

        let origin = NSPoint(x: frame.maxX - toolbarWindow.frame.width - 20, y: frame.minY - toolbarWindow.frame.height + 10)
        let size = toolbarWindow.frame.size
        toolbarWindow.setFrame(.init(origin: origin, size: size), display: true)
        toolbarWindow.setIsVisible(true)
        window?.addChildWindow(toolbarWindow, ordered: .above)
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

// MARK: - Edit toolbar actions

private extension SnipImageWindowController {
    func onSave() {
        // TODO: Save
    }

    func onCopy() {
        // TODO: Copy
    }

    func onDone() {
        hideToolbar()
    }
}
