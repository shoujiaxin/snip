//
//  SnipMaskWindowController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/28.
//

import Cocoa
import SwiftUI

class SnipMaskWindowController: NSWindowController {
    // MARK: - Views

    private let maskLayer = CAShapeLayer()

    private let resizingBox = ResizableView(frame: .zero)

    private let sizeLabel = NSHostingView(rootView: SnipSizeLabel(of: .zero))

    private let toolbar = NSHostingView(rootView: SnipToolbar())

    // MARK: - States

    private let screenshot: CGImage

    private let windows: [WindowInfo]

    private var bounds: NSRect {
        window?.contentView?.bounds ?? .zero
    }

    // MARK: - Lifecycle

    init(screen: NSScreen) {
        screenshot = CGDisplayCreateImage(screen.displayID)!
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

        resizingBox.isResizable = false
        resizingBox.delegate = self
        sizeLabel.isHidden = true
        toolbar.isHidden = true
        toolbar.rootView.delegate = self

        window?.contentView?.addSubview(resizingBox)
        window?.contentView?.addSubview(sizeLabel)
        window?.contentView?.addSubview(toolbar)

        let panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(onPanGesture(gestureRecognizer:)))
        panGestureRecognizer.delegate = self
        window?.contentView?.addGestureRecognizer(panGestureRecognizer)
        let doubleClickGestureRecognizer = NSClickGestureRecognizer(target: SnipManager.shared, action: #selector(SnipManager.finishCapture))
        doubleClickGestureRecognizer.numberOfClicksRequired = 2
        window?.contentView?.addGestureRecognizer(doubleClickGestureRecognizer)

        let clickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(onClickGesture(gestureRecognizer:)))
        clickGestureRecognizer.numberOfClicksRequired = 1
        resizingBox.addGestureRecognizer(clickGestureRecognizer)

        window?.contentView?.addTrackingArea(.init(rect: bounds, options: [.activeInActiveApp, .mouseEnteredAndExited, .mouseMoved], owner: self, userInfo: nil))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Mouse & keyboard events

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)

        window?.contentView?.addCursorRect(bounds, cursor: .crosshair)
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)

        if resizingBox.isResizable {
            return
        }

        captureWindow()
    }

    override func cancelOperation(_: Any?) {
        SnipManager.shared.finishCapture()
    }

    @objc private func onPanGesture(gestureRecognizer: NSPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            resizingBox.isResizable = true
            toolbar.isHidden = true
        case .changed:
            let location = gestureRecognizer.location(in: window?.contentView)
            let translation = gestureRecognizer.translation(in: window?.contentView)
            let startPoint = NSPoint(x: location.x - translation.x, y: location.y - translation.y)
            resizingBox.contentFrame = NSRect(origin: startPoint, size: .init(width: translation.x, height: translation.y))
        case .ended:
            updateToolbar(resizingBox.contentFrame)
        default:
            return
        }
    }

    @objc private func onClickGesture(gestureRecognizer _: NSClickGestureRecognizer) {
        if resizingBox.isResizable {
            return
        }

        resizingBox.isResizable = true
        resizingBox.needsDisplay = true
        updateToolbar(resizingBox.contentFrame)
    }

    // MARK: - Private methods

    private func updateToolbar(_ rect: NSRect) {
        let size = toolbar.intrinsicContentSize
        let origin = NSPoint(x: max(rect.maxX - size.width, bounds.minX), y: max(resizingBox.frame.minY - size.height, bounds.minY))
        toolbar.frame = NSRect(origin: origin, size: size)
        toolbar.isHidden = false

        window?.contentView?.addCursorRect(toolbar.frame, cursor: .arrow)
    }

    private func captureWindow() {
        guard let maskWindowFrame = window?.frame,
              let windowFrame = windows.first(where: { $0.frame.contains(NSEvent.mouseLocation) })?.frame
        else {
            return
        }

        resizingBox.contentFrame = NSRect(x: windowFrame.minX - maskWindowFrame.minX,
                                          y: windowFrame.minY - maskWindowFrame.minY,
                                          width: windowFrame.width,
                                          height: windowFrame.height).intersection(bounds)
    }
}

// MARK: - ResizableViewDelegate

extension SnipMaskWindowController: ResizableViewDelegate {
    func resizableView(_: ResizableView, contentFrameWillBeginChanging _: NSRect) {
        toolbar.isHidden = true
    }

    func resizableView(_ view: ResizableView, contentFrameDidChange rect: NSRect) {
        if rect.isEmpty {
            return
        }

        // Update mask layer
        let path = CGMutablePath()
        path.addRect(bounds)
        path.addRect(rect)
        maskLayer.path = path

        // Update size label
        sizeLabel.rootView = SnipSizeLabel(of: rect)
        var labelFrame = NSRect(origin: NSPoint(x: rect.minX, y: view.frame.maxY), size: sizeLabel.intrinsicContentSize)
        if labelFrame.maxY > bounds.maxY {
            labelFrame.origin.x = view.frame.minX - labelFrame.width
            labelFrame.origin.y = rect.maxY - labelFrame.height
        }
        if labelFrame.minX < bounds.minX {
            labelFrame.origin.x = view.frame.maxX
        }
        if labelFrame.maxX > bounds.maxX {
            labelFrame.origin.x = rect.minX
            labelFrame.origin.y = max(view.frame.minY - labelFrame.height, bounds.minY)
        }
        sizeLabel.frame = labelFrame
        sizeLabel.isHidden = false
    }

    func resizableView(_: ResizableView, contentFrameDidEndChanging rect: NSRect) {
        updateToolbar(rect)
    }
}

// MARK: - NSGestureRecognizerDelegate

extension SnipMaskWindowController: NSGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: window?.contentView)
        if toolbar.frame.contains(location) {
            return false
        }

        return true
    }
}

// MARK: - SnipToolbarDelegate

extension SnipMaskWindowController: SnipToolbarDelegate {
    func onCancel() {
        SnipManager.shared.finishCapture()
    }

    func onPin() {}

    func onSave() {}

    func onCopy() {}
}
