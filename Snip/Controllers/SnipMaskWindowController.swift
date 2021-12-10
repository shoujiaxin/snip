//
//  SnipMaskWindowController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/28.
//

import Cocoa
import SwiftUI

class SnipMaskWindowController: NSWindowController {
    private enum MouseState {
        case normal
        case drag
        case resizeBottomLeft
        case resizeBottomRight
        case resizeTopLeft
        case resizeTopRight
        case resizeBottom
        case resizeLeft
        case resizeRight
        case resizeTop
    }

    // MARK: - Views

    private let maskLayer = CAShapeLayer()

    private let snipMask = SnipMask(frame: .zero)

    private let snipSizeLabel = NSHostingView(rootView: SnipSizeLabel(of: .zero))

    private let snipToolbar = NSHostingView(rootView: SnipToolbar())

    // MARK: - States

    private let screenshot: NSImage

    private let windows: [WindowInfo]

    private var mouseState: MouseState = .normal

    private var snipRect: NSRect = .zero

    private var bounds: NSRect {
        window?.contentView?.bounds ?? .zero
    }

    // MARK: - Lifecycle

    init(screen: NSScreen) {
        screenshot = NSImage(cgImage: CGDisplayCreateImage(screen.displayID)!, size: screen.frame.size)
        if let windowList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, .zero) as? [NSDictionary] {
            windows = windowList.compactMap { info in
                let data = try? JSONSerialization.data(withJSONObject: info, options: .fragmentsAllowed)
                return data.flatMap { try? JSONDecoder().decode(WindowInfo.self, from: $0) }
            }
        } else {
            windows = []
        }

        super.init(window: SnipMaskWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false))

        window?.backgroundColor = NSColor(patternImage: screenshot)
        window?.level = .init(Int(CGWindowLevel.max))
        window?.makeMain()

        maskLayer.fillColor = CGColor(gray: 0.5, alpha: 0.5)
        maskLayer.fillRule = .evenOdd
        maskLayer.path = CGPath(rect: bounds, transform: nil)
        window?.contentView?.wantsLayer = true
        window?.contentView?.layer?.addSublayer(maskLayer)

        snipMask.addGestureRecognizer(NSPanGestureRecognizer(target: self, action: #selector(onMoveOrResize(gestureRecognizer:))))
        snipSizeLabel.isHidden = snipRect.isEmpty
        snipToolbar.isHidden = snipRect.isEmpty
        snipToolbar.rootView.delegate = self

        window?.contentView?.addSubview(snipMask)
        window?.contentView?.addSubview(snipSizeLabel)
        window?.contentView?.addSubview(snipToolbar)

        let snipGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(onSnip(gestureRecognizer:)))
        snipGestureRecognizer.delegate = self
        window?.contentView?.addGestureRecognizer(snipGestureRecognizer)
        window?.contentView?.addTrackingArea(NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseMoved], owner: self, userInfo: nil))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Mouse events

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)

        let point = event.locationInWindow
        if snipMask.contentFrame.contains(point) {
            mouseState = .drag
            NSCursor.openHand.set()
        } else if snipMask.bottomLeftCornerFrame.contains(point) {
            mouseState = .resizeBottomLeft
            NSCursor.crosshair.set() // TODO: Cursor
        } else if snipMask.bottomRightCornerFrame.contains(point) {
            mouseState = .resizeBottomRight
            NSCursor.crosshair.set() // TODO: Cursor
        } else if snipMask.topLeftCornerFrame.contains(point) {
            mouseState = .resizeTopLeft
            NSCursor.crosshair.set() // TODO: Cursor
        } else if snipMask.topRightCornerFrame.contains(point) {
            mouseState = .resizeTopRight
            NSCursor.crosshair.set() // TODO: Cursor
        } else if snipMask.bottomBorderFrame.contains(point) {
            mouseState = .resizeBottom
            NSCursor.resizeDown.set()
        } else if snipMask.leftBorderFrame.contains(point) {
            mouseState = .resizeLeft
            NSCursor.resizeLeft.set()
        } else if snipMask.rightBorderFrame.contains(point) {
            mouseState = .resizeRight
            NSCursor.resizeRight.set()
        } else if snipMask.topBorderFrame.contains(point) {
            mouseState = .resizeTop
            NSCursor.resizeUp.set()
        } else if snipToolbar.frame.contains(point) {
            NSCursor.arrow.set()
        } else {
            mouseState = .normal
            NSCursor.crosshair.set()
        }

        if snipRect.isEmpty {
            captureWindow()
        }
    }

    private func captureWindow() {
        guard let maskWindow = window else {
            return
        }

        let location = NSEvent.mouseLocation
        for window in windows {
            let windowFrame = window.frame
            if windowFrame.contains(location) {
                let rect = NSRect(x: windowFrame.minX - maskWindow.frame.minX,
                                  y: windowFrame.minY - maskWindow.frame.minY,
                                  width: windowFrame.width,
                                  height: windowFrame.height).intersection(bounds)
                updateMask(rect: rect)
                updateSizeLabel(rect: rect)
                updateToolbar(rect: rect)
                return
            }
        }
    }

    @objc private func onSnip(gestureRecognizer: NSPanGestureRecognizer) {
        let location = gestureRecognizer.location(in: window?.contentView)
        switch gestureRecognizer.state {
        case .began:
            snipRect = NSRect(origin: location, size: .zero)
            snipToolbar.isHidden = true
        case .changed:
            snipRect.size = CGSize(width: location.x - snipRect.origin.x, height: location.y - snipRect.origin.y)
            // Standardize coordinate for multi displays
            let rect = snipRect.intersection(bounds)
            // Update UI
            updateMask(rect: rect)
            updateSizeLabel(rect: rect)
        case .ended:
            snipRect = snipRect.intersection(bounds)
            updateToolbar(rect: snipRect)
        default:
            return
        }
    }

    @objc private func onMoveOrResize(gestureRecognizer: NSPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: window?.contentView)
        switch mouseState {
        case .drag:
            snipRect.offsetBy(dx: translation.x, dy: translation.y, in: bounds)
        case .resizeBottomLeft:
            snipRect.moveCorner(.bottomLeft, dx: translation.x, dy: translation.y)
        case .resizeBottomRight:
            snipRect.moveCorner(.bottomRight, dx: translation.x, dy: translation.y)
        case .resizeTopLeft:
            snipRect.moveCorner(.topLeft, dx: translation.x, dy: translation.y)
        case .resizeTopRight:
            snipRect.moveCorner(.topRight, dx: translation.x, dy: translation.y)
        case .resizeBottom:
            snipRect.moveEdge(.bottom, delta: translation.y)
        case .resizeLeft:
            snipRect.moveEdge(.left, delta: translation.x)
        case .resizeRight:
            snipRect.moveEdge(.right, delta: translation.x)
        case .resizeTop:
            snipRect.moveEdge(.top, delta: translation.y)
        default:
            return
        }

        // Standardize coordinate for multi displays
        let rect = snipRect.intersection(bounds)
        // Update UI
        updateMask(rect: rect)
        updateSizeLabel(rect: rect)
        updateToolbar(rect: rect)
        // Reset translation of pan gesture
        gestureRecognizer.setTranslation(.zero, in: window?.contentView)

        if gestureRecognizer.state == .ended {
            snipRect = rect
        }
    }

    // MARK: - Private methods

    private func updateMask(rect: NSRect) {
        let path = CGMutablePath()
        path.addRect(bounds)
        path.addRect(rect)
        maskLayer.path = path

        let inset = -snipMask.borderFrameWidth / 2
        snipMask.frame = rect.insetBy(dx: inset, dy: inset)
    }

    private func updateSizeLabel(rect: NSRect) {
        snipSizeLabel.rootView = SnipSizeLabel(of: rect)
        let size = snipSizeLabel.intrinsicContentSize
        let origin = NSPoint(x: min(rect.minX, bounds.maxX - size.width), y: min(snipMask.frame.maxY, bounds.maxY - size.height))
        snipSizeLabel.frame = NSRect(origin: origin, size: size)
        snipSizeLabel.isHidden = rect.isEmpty
    }

    private func updateToolbar(rect: NSRect) {
        let size = snipToolbar.intrinsicContentSize
        let origin = NSPoint(x: max(rect.maxX - size.width, bounds.minX), y: max(snipMask.frame.minY - size.height, bounds.minY))
        snipToolbar.frame = NSRect(origin: origin, size: size)
        snipToolbar.isHidden = rect.isEmpty
    }
}

// MARK: - SnipToolbarDelegate

extension SnipMaskWindowController: SnipToolbarDelegate {
    func onCancel() {
        SnipManager.shared.finishCapture()
    }

    func onPin() {
        let image = screenshot.cropped(to: snipRect)
        SnipManager.shared.pinScreenshot(image, at: snipRect.origin)
    }

    func onSave() {
        guard let window = window else {
            return
        }

        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = Date().string + ".png"
        savePanel.beginSheetModal(for: window) { [unowned self] response in
            if response == .OK, let url = savePanel.url {
                try? self.screenshot.cropped(to: self.snipRect).tiffRepresentation?.write(to: url)
                SnipManager.shared.finishCapture()
            }
        }
    }

    func onCopy() {
        let image = screenshot.cropped(to: snipRect)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([image])
        SnipManager.shared.finishCapture()
    }
}

// MARK: - NSGestureRecognizerDelegate

extension SnipMaskWindowController: NSGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: window?.contentView)
        return !snipToolbar.frame.contains(location)
    }
}
