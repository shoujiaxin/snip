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

    private let sizeLabel = NSHostingView(rootView: SnipSizeLabel(size: .zero))

    private var toolbar: NSHostingView<SnipToolbar>!

    // MARK: - States

    private let screenshot: NSImage

    private let windows: [WindowInfo]

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

        setupWindow()
        setupMaskLayer()
        setupResizingBox()
        setupSizeLabel()
        setupToolbar()
        setupGestureRecognizers()
        setupTrackingAreas()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupWindow() {
        window?.level = .init(Int(CGWindowLevel.max))
        window?.makeMain()
    }

    private func setupMaskLayer() {
        maskLayer.fillColor = CGColor(gray: 0.5, alpha: 0.5)
        maskLayer.fillRule = .evenOdd
        maskLayer.path = CGPath(rect: bounds, transform: nil)
        window?.contentView?.wantsLayer = true
        window?.contentView?.layer?.contents = screenshot
        window?.contentView?.layer?.addSublayer(maskLayer)
    }

    private func setupResizingBox() {
        resizingBox.isResizable = false
        resizingBox.delegate = self
        window?.contentView?.addSubview(resizingBox)
        window?.makeFirstResponder(resizingBox)
    }

    private func setupSizeLabel() {
        sizeLabel.isHidden = true
        window?.contentView?.addSubview(sizeLabel)
    }

    private func setupToolbar() {
        let controller = SnipToolbarController(items: [
            .button(name: "Cancel", iconName: "xmark") { [weak self] in self?.onCancel() },
            .button(name: "Pin", iconName: "pin") { [weak self] in self?.onPin() },
            .button(name: "Save", iconName: "square.and.arrow.down") { [weak self] in self?.onSave() },
            .button(name: "Copy", iconName: "doc.on.doc") { [weak self] in self?.onCopy() },
        ])
        toolbar = NSHostingView(rootView: SnipToolbar(controller: controller))
        toolbar.isHidden = true
        window?.contentView?.addSubview(toolbar)
    }

    private func setupGestureRecognizers() {
        let panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(onPanGesture(gestureRecognizer:)))
        panGestureRecognizer.delegate = self
        window?.contentView?.addGestureRecognizer(panGestureRecognizer)

        let doubleClickGestureRecognizer = NSClickGestureRecognizer(target: SnipManager.shared, action: #selector(SnipManager.finishCapture))
        doubleClickGestureRecognizer.numberOfClicksRequired = 2
        window?.contentView?.addGestureRecognizer(doubleClickGestureRecognizer)

        let clickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(onClickGesture(gestureRecognizer:)))
        clickGestureRecognizer.numberOfClicksRequired = 1
        resizingBox.addGestureRecognizer(clickGestureRecognizer)
    }

    private func setupTrackingAreas() {
        window?.contentView?.addTrackingArea(.init(rect: bounds, options: [.activeInActiveApp, .mouseEnteredAndExited, .mouseMoved], owner: self, userInfo: nil))
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
        case .ended:
            updateToolbar(resizingBox.contentFrame)
        default:
            break
        }

        let location = gestureRecognizer.location(in: window?.contentView)
        let translation = gestureRecognizer.translation(in: window?.contentView)
        let startPoint = NSPoint(x: location.x - translation.x, y: location.y - translation.y)
        let rect = NSRect(origin: startPoint, size: .init(width: translation.x, height: translation.y))
        resizingBox.contentFrame = NSEvent.modifierFlags == .shift ? rect.square() : rect
    }

    @objc private func onClickGesture(gestureRecognizer _: NSClickGestureRecognizer) {
        if resizingBox.isResizable {
            return
        }

        resizingBox.isResizable = true
        updateToolbar(resizingBox.contentFrame)
    }

    // MARK: - Update UI

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
        sizeLabel.rootView.size = rect.size
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

// MARK: - Snip toolbar actions

private extension SnipMaskWindowController {
    func onCancel() {
        SnipManager.shared.finishCapture()
    }

    func onPin() {
        guard let windowFrame = window?.frame else {
            return
        }

        let imageFrame = resizingBox.contentFrame
        let image = screenshot.cropped(to: imageFrame)
        SnipManager.shared.pinScreenshot(image, at: .init(x: windowFrame.origin.x + imageFrame.origin.x, y: windowFrame.origin.y + imageFrame.origin.y))
    }

    func onSave() {
        guard let window = window else {
            return
        }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.nameFieldStringValue = "Snip \(Date().string)"
        savePanel.beginSheetModal(for: window) { [unowned self] response in
            if response == .OK, let url = savePanel.url {
                try? self.screenshot.cropped(to: self.resizingBox.contentFrame).tiffRepresentation?.write(to: url)
                SnipManager.shared.finishCapture()
            }
        }
    }

    func onCopy() {
        let image = screenshot.cropped(to: resizingBox.contentFrame)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([image])
        SnipManager.shared.finishCapture()
    }
}
