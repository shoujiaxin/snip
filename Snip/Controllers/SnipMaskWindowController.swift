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

    private let mask = SnipMask(frame: .zero)

    private let sizeLabel = NSHostingView(rootView: SnipSizeLabel(of: .zero))

    private let toolbar = NSHostingView(rootView: SnipToolbar())

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
            windows = windowList
                .compactMap { info in
                    let data = try? JSONSerialization.data(withJSONObject: info, options: .fragmentsAllowed)
                    return data.flatMap { try? JSONDecoder().decode(WindowInfo.self, from: $0) }
                }
                .filter { screen.frame.contains($0.frame) && $0.ownerName != "Dock" }
        } else {
            windows = []
        }

        super.init(window: SnipWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false))

        window?.level = .init(Int(CGWindowLevel.max))
        window?.makeMain()

        maskLayer.fillColor = CGColor(gray: 0.5, alpha: 0.5)
        maskLayer.fillRule = .evenOdd
        maskLayer.path = CGPath(rect: bounds, transform: nil)
        window?.contentView?.wantsLayer = true
        window?.contentView?.layer?.contents = screenshot
        window?.contentView?.layer?.addSublayer(maskLayer)

        let moveAndResizeGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(onMoveOrResize(gestureRecognizer:)))
        moveAndResizeGestureRecognizer.delegate = self
        mask.addGestureRecognizer(moveAndResizeGestureRecognizer)
        let confirmWindowCaptureGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(confirmWindowCapture(gestureRecognizer:)))
        confirmWindowCaptureGestureRecognizer.numberOfClicksRequired = 1
        mask.addGestureRecognizer(confirmWindowCaptureGestureRecognizer)
        sizeLabel.isHidden = true
        toolbar.isHidden = true
        toolbar.rootView.delegate = self

        window?.contentView?.addSubview(mask)
        window?.contentView?.addSubview(sizeLabel)
        window?.contentView?.addSubview(toolbar)

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

        if snipRect.isEmpty {
            captureWindow()
            NSCursor.crosshair.set()
            return
        }

        let point = event.locationInWindow
        if mask.contentFrame.contains(point) {
            mouseState = .drag
            NSCursor.openHand.set()
        } else if mask.bottomLeftCornerFrame.contains(point) {
            mouseState = .resizeBottomLeft
            NSCursor.crosshair.set() // TODO: Cursor
        } else if mask.bottomRightCornerFrame.contains(point) {
            mouseState = .resizeBottomRight
            NSCursor.crosshair.set() // TODO: Cursor
        } else if mask.topLeftCornerFrame.contains(point) {
            mouseState = .resizeTopLeft
            NSCursor.crosshair.set() // TODO: Cursor
        } else if mask.topRightCornerFrame.contains(point) {
            mouseState = .resizeTopRight
            NSCursor.crosshair.set() // TODO: Cursor
        } else if mask.bottomBorderFrame.contains(point) {
            mouseState = .resizeBottom
            NSCursor.resizeDown.set()
        } else if mask.leftBorderFrame.contains(point) {
            mouseState = .resizeLeft
            NSCursor.resizeLeft.set()
        } else if mask.rightBorderFrame.contains(point) {
            mouseState = .resizeRight
            NSCursor.resizeRight.set()
        } else if mask.topBorderFrame.contains(point) {
            mouseState = .resizeTop
            NSCursor.resizeUp.set()
        } else if toolbar.frame.contains(point) {
            NSCursor.arrow.set()
        } else {
            mouseState = .normal
            NSCursor.crosshair.set()
        }
    }

    override func cancelOperation(_: Any?) {
        SnipManager.shared.finishCapture()
    }

    @objc private func onSnip(gestureRecognizer: NSPanGestureRecognizer) {
        let location = gestureRecognizer.location(in: window?.contentView)
        switch gestureRecognizer.state {
        case .began:
            snipRect = NSRect(origin: location, size: .zero)
            toolbar.isHidden = true
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

    @objc private func confirmWindowCapture(gestureRecognizer _: NSClickGestureRecognizer) {
        if snipRect.isEmpty, !mask.frame.isEmpty {
            snipRect = mask.maskFrame
            updateToolbar(rect: snipRect)
        }
    }

    // MARK: - Private methods

    private func updateMask(rect: NSRect) {
        let path = CGMutablePath()
        path.addRect(bounds)
        path.addRect(rect)
        maskLayer.path = path

        mask.maskFrame = rect
    }

    private func updateSizeLabel(rect: NSRect) {
        sizeLabel.rootView = SnipSizeLabel(of: rect)
        var labelFrame = NSRect(origin: NSPoint(x: rect.minX, y: mask.frame.maxY), size: sizeLabel.intrinsicContentSize)
        if labelFrame.maxY > bounds.maxY {
            labelFrame.origin.x = mask.frame.minX - labelFrame.width
            labelFrame.origin.y = rect.maxY - labelFrame.height
        }
        if labelFrame.minX < bounds.minX {
            labelFrame.origin.x = mask.frame.maxX
        }
        if labelFrame.maxX > bounds.maxX {
            labelFrame.origin.x = rect.minX
            labelFrame.origin.y = max(mask.frame.minY - labelFrame.height, bounds.minY)
        }
        sizeLabel.frame = labelFrame
        sizeLabel.isHidden = rect.isEmpty
    }

    private func updateToolbar(rect: NSRect) {
        let size = toolbar.intrinsicContentSize
        let origin = NSPoint(x: max(rect.maxX - size.width, bounds.minX), y: max(mask.frame.minY - size.height, bounds.minY))
        toolbar.frame = NSRect(origin: origin, size: size)
        toolbar.isHidden = rect.isEmpty
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
                return
            }
        }
    }
}

// MARK: - SnipToolbarDelegate

extension SnipMaskWindowController: SnipToolbarDelegate {
    func onCancel() {
        SnipManager.shared.finishCapture()
    }

    func onPin() {
        guard let windowFrame = window?.frame else {
            return
        }

        let image = screenshot.cropped(to: snipRect)
        SnipManager.shared.pinScreenshot(image, at: NSPoint(x: windowFrame.origin.x + snipRect.origin.x, y: windowFrame.origin.y + snipRect.origin.y))
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
        if toolbar.frame.contains(location) {
            return false
        }

        if gestureRecognizer.view == mask, snipRect.isEmpty {
            return false
        }

        return true
    }
}
