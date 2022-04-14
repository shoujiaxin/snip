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

    private let imageCanvasViewController: ImageCanvasViewController

    private let scaleLabel = NSHostingView(rootView: ScaleLabel(scale: 1.0))

    private var toolbarWindowController: MarkupToolbarWindowController!

    private var toolbarController: SnipToolbarController!

    // MARK: - States

    /// Original size of the image.
    private let originalSize: NSSize

    /// The frame of the image canvas when scaling.
    private var scalingFrame: NSRect?

    /// The scale of the image canvas when scaling.
    private var scalingFactor: CGFloat = 1.0 {
        didSet {
            scalingFactor = min(scalingFactor, 5)
            scalingFactor = max(scalingFactor, 0)
        }
    }

    /// The mouse location when scaling begins.
    private var scalingCenter: NSPoint = .zero

    private var minScaledSize: CGFloat {
        0.1 * min(originalSize.width, originalSize.height)
    }

    // MARK: - Constants

    private static let contentInset: CGFloat = 20

    // MARK: - Lifecycle

    init(image: NSImage, location: NSPoint) {
        imageCanvasViewController = .init(image: image)
        originalSize = image.size

        super.init(window: SnipWindow(contentRect: .init(origin: location, size: image.size).insetBy(dx: -Self.contentInset, dy: -Self.contentInset), styleMask: .borderless, backing: .buffered, defer: false))

        setupWindow()
        setupImageCanvas()
        setupScaleLabel()
        setupToolbar()
        setupGestureRecognizers()

        hideToolbar()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupWindow() {
        window?.backgroundColor = .clear
        window?.delegate = self
        window?.hasShadow = false
        window?.isOpaque = false
        window?.level = .init(Int(CGWindowLevel.max))
        window?.makeMain()
    }

    private func setupImageCanvas() {
        guard let contentView = window?.contentView else {
            return
        }
        let imageCanvas = imageCanvasViewController.view
        imageCanvas.shadow = .init()
        imageCanvas.wantsLayer = true
        imageCanvas.layer?.borderColor = NSColor.controlAccentColor.cgColor.copy(alpha: 0.6)
        imageCanvas.layer?.shadowColor = NSColor.controlAccentColor.cgColor
        imageCanvas.layer?.shadowOpacity = 0.8
        imageCanvas.layer?.shadowRadius = 6
        imageCanvas.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageCanvas)
        let top = imageCanvas.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Self.contentInset)
        let right = imageCanvas.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Self.contentInset)
        let bottom = imageCanvas.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Self.contentInset)
        let left = imageCanvas.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Self.contentInset)
        contentView.addConstraints([top, right, bottom, left])

        NSAnimationContext.runAnimationGroup { _ in
            let key = "borderWidth"
            let animation = CABasicAnimation(keyPath: key)
            animation.duration = 0.2
            animation.repeatCount = 2
            animation.fromValue = 2
            animation.toValue = 0
            imageCanvas.layer?.add(animation, forKey: key)
        }
    }

    private func setupScaleLabel() {
        guard let contentView = window?.contentView else {
            return
        }
        scaleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scaleLabel)
        let top = scaleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Self.contentInset)
        let left = scaleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Self.contentInset)
        contentView.addConstraints([top, left])
    }

    private func setupToolbar() {
        toolbarController = SnipToolbarController(items: [
            .tabItem(name: "Shape", iconName: "rectangle") { [weak self] in
                self?.imageCanvasViewController.markupState = .rectangle
            } onDeselect: { [weak self] in
                self?.imageCanvasViewController.markupState = .none
            },
            .tabItem(name: "Arrow", iconName: "arrow.up.right") {},
            .tabItem(name: "Draw", iconName: "scribble") {},
            .tabItem(name: "Highlight", iconName: "highlighter") {},
            .tabItem(name: "Mosaic", iconName: "mosaic") {},
            .tabItem(name: "Text", iconName: "character") {},
            .divider,
            .button(name: "Undo", iconName: "arrow.uturn.backward") {},
            .button(name: "Redo", iconName: "arrow.uturn.forward") {},
            .divider,
            .button(name: "Save", iconName: "square.and.arrow.down") { [weak self] in
                self?.imageCanvasViewController.save()
            },
            .button(name: "Copy", iconName: "doc.on.doc") { [weak self] in
                self?.imageCanvasViewController.copy()
            },
            .button(name: "Done", iconName: "checkmark") { [weak self] in
                self?.toolbarController.selectedItem = nil
                self?.hideToolbar()
            },
        ])
        toolbarWindowController = .init(controller: toolbarController)
    }

    private func setupGestureRecognizers() {
        let doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(onDoubleClickGesture))
        doubleClickGestureRecognizer.numberOfClicksRequired = 2
        window?.contentView?.addGestureRecognizer(doubleClickGestureRecognizer)

        let magnificationGestureRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(onMagnificationGesture(gestureRecognizer:)))
        window?.contentView?.addGestureRecognizer(magnificationGestureRecognizer)
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
            beginScaling()
        case .changed:
            var delta = event.scrollingDeltaY / 60
            delta = min(delta, 0.1)
            delta = max(delta, -0.1)
            scalingFactor += delta
            scaled(by: scalingFactor, at: scalingCenter)
        default:
            return
        }
    }

    override func keyDown(with event: NSEvent) {
        if event.characters == " " {
            if toolbarWindowController.isVisible {
                hideToolbar()
            } else {
                showToolbar()
            }
        }
    }

    override func cancelOperation(_: Any?) {
        guard toolbarController.selectedItem == nil else {
            toolbarController.selectedItem = nil
            return
        }
        guard !toolbarWindowController.isVisible else {
            hideToolbar()
            return
        }
        SnipManager.shared.removeScreenshot(self)
    }

    @objc private func onDoubleClickGesture() {
        window?.cancelOperation(self)
    }

    @objc private func onMagnificationGesture(gestureRecognizer: NSMagnificationGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            beginScaling()
        case .changed:
            scalingFactor = gestureRecognizer.magnification + 1.0
            scaled(by: scalingFactor, at: scalingCenter)
        default:
            return
        }
    }

    private func beginScaling() {
        scalingFrame = window?.frame.insetBy(dx: Self.contentInset, dy: Self.contentInset)
        scalingFactor = 1.0
        scalingCenter = NSEvent.mouseLocation
    }

    private func scaled(by scale: CGFloat, at location: NSPoint) {
        guard toolbarController.selectedItem == nil, let frame = scalingFrame else {
            return
        }

        let transform = CGAffineTransform(translationX: location.x, y: location.y)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: -location.x, y: -location.y)
        let scaledFrame = frame.applying(transform)
        if scaledFrame.width <= minScaledSize || scaledFrame.height <= minScaledSize {
            return
        }

        window?.setFrame(scaledFrame.insetBy(dx: -Self.contentInset, dy: -Self.contentInset), display: true)
        scaleLabel.rootView.scale = scaledFrame.width / originalSize.width

        updateToolbarFrame()
    }

    private func hideToolbar() {
        toolbarWindowController.window.map { window?.removeChildWindow($0) }
        toolbarWindowController.close()
    }

    private func showToolbar() {
        toolbarWindowController.showWindow(self)
        toolbarWindowController.window.map { window?.addChildWindow($0, ordered: .above) }

        updateToolbarFrame()
    }

    private func updateToolbarFrame() {
        guard let frame = window?.frame, let toolbarWindow = toolbarWindowController.window else {
            return
        }

        let origin = NSPoint(x: frame.maxX - toolbarWindow.frame.width - Self.contentInset,
                             y: frame.minY - toolbarWindow.frame.height + Self.contentInset / 2)
        let size = toolbarWindow.frame.size
        toolbarWindow.setFrame(.init(origin: origin, size: size), display: true)
    }
}

// MARK: - NSWindowDelegate

extension SnipImageWindowController: NSWindowDelegate {
    func windowDidBecomeKey(_: Notification) {
        imageCanvasViewController.view.layer?.shadowColor = NSColor.controlAccentColor.cgColor
    }

    func windowDidResignKey(_: Notification) {
        imageCanvasViewController.view.layer?.shadowColor = NSColor.gray.cgColor
    }
}
