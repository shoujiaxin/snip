//
//  SnipWindowController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/28.
//

import Cocoa

class SnipWindowController: NSWindowController {
    private enum MouseState {
        case normal
        case drag
        case resizeBottomLeft
        case resizeBottom
        case resizeBottomRight
        case resizeLeft
        case resizeRight
        case resizeTopLeft
        case resizeTop
        case resizeTopRight
    }

    // MARK: - Views

    private let maskLayer = CAShapeLayer()

    private let snipBox = SnipBox(frame: .zero)

    // MARK: - States

    private let windowFrame: NSRect

    private let screenshot: NSImage?

    private var mouseState: MouseState = .normal

    private var snipBeginLocation: NSPoint = .zero

    private var snipEndLocation: NSPoint = .zero

    private var snipRect: NSRect = .zero

    // MARK: - Initializers

    init(screen: NSScreen) {
        windowFrame = screen.frame

        screenshot = CGDisplayCreateImage(CGMainDisplayID()).map { NSImage(cgImage: $0, size: screen.frame.size) }

        super.init(window: NSWindow(contentRect: windowFrame, styleMask: .borderless, backing: .buffered, defer: false, screen: screen))

        if let image = screenshot {
            window?.backgroundColor = NSColor(patternImage: image)
        }

        maskLayer.fillColor = CGColor(gray: 0.5, alpha: 0.5)
        maskLayer.fillRule = .evenOdd
        maskLayer.path = CGPath(rect: windowFrame, transform: nil)
        window?.contentView?.wantsLayer = true
        window?.contentView?.layer?.addSublayer(maskLayer)

        window?.contentView?.addSubview(snipBox)
        window?.contentView?.addTrackingArea(NSTrackingArea(rect: windowFrame, options: [.activeAlways, .mouseMoved], owner: self, userInfo: nil))

        window?.level = .statusBar

        showWindow(self)
    }

    required init?(coder: NSCoder) {
        windowFrame = .zero
        screenshot = nil

        super.init(coder: coder)
    }

    // MARK: - Mouse events

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        // Drag begin
        let currentLocation = event.locationInWindow
        snipBeginLocation = currentLocation
        snipEndLocation = currentLocation

        // Unify coordinate
        snipRect = snipRect.intersection(windowFrame)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        let currentLocation = event.locationInWindow
        let deltaX = currentLocation.x - snipEndLocation.x
        let deltaY = currentLocation.y - snipEndLocation.y
        switch mouseState {
        case .normal:
            snipRect = NSRect(x: snipBeginLocation.x, y: snipBeginLocation.y, width: currentLocation.x - snipBeginLocation.x, height: currentLocation.y - snipBeginLocation.y)
        case .drag:
            snipRect = snipRect.offsetBy(dx: deltaX, dy: deltaY)
            if snipRect.origin.x < 0 {
                snipRect.origin.x = 0
            }
            if snipRect.origin.y < 0 {
                snipRect.origin.y = 0
            }
            if snipRect.maxX > windowFrame.width {
                snipRect.origin.x = windowFrame.width - snipRect.width
            }
            if snipRect.maxY > windowFrame.height {
                snipRect.origin.y = windowFrame.height - snipRect.height
            }
        case .resizeBottomLeft:
            snipRect.origin.x += deltaX
            snipRect.origin.y += deltaY
            snipRect.size.width -= deltaX
            snipRect.size.height -= deltaY
        case .resizeBottom:
            snipRect.origin.y += deltaY
            snipRect.size.height -= deltaY
        case .resizeBottomRight:
            snipRect.origin.y += deltaY
            snipRect.size.width += deltaX
            snipRect.size.height -= deltaY
        case .resizeLeft:
            snipRect.origin.x += deltaX
            snipRect.size.width -= deltaX
        case .resizeRight:
            snipRect.size.width += deltaX
        case .resizeTopLeft:
            snipRect.origin.x += deltaX
            snipRect.size.width -= deltaX
            snipRect.size.height += deltaY
        case .resizeTop:
            snipRect.size.height += deltaY
        case .resizeTopRight:
            snipRect.size.width += deltaX
            snipRect.size.height += deltaY
        }

        snipEndLocation = currentLocation

        updateMask()
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)

        let point = event.locationInWindow
        if snipBox.contentFrame.contains(point) {
            mouseState = .drag
            NSCursor.openHand.set()
        } else if snipBox.bottomLeftCornerFrame.contains(point) {
            mouseState = .resizeBottomLeft
            NSCursor.crosshair.set() // TODO: Cursor
        } else if snipBox.bottomRightCornerFrame.contains(point) {
            mouseState = .resizeBottomRight
            NSCursor.crosshair.set() // TODO: Cursor
        } else if snipBox.topLeftCornerFrame.contains(point) {
            mouseState = .resizeTopLeft
            NSCursor.crosshair.set() // TODO: Cursor
        } else if snipBox.topRightCornerFrame.contains(point) {
            mouseState = .resizeTopRight
            NSCursor.crosshair.set() // TODO: Cursor
        } else if snipBox.bottomBorderFrame.contains(point) {
            mouseState = .resizeBottom
            NSCursor.resizeDown.set()
        } else if snipBox.leftBorderFrame.contains(point) {
            mouseState = .resizeLeft
            NSCursor.resizeLeft.set()
        } else if snipBox.rightBorderFrame.contains(point) {
            mouseState = .resizeRight
            NSCursor.resizeRight.set()
        } else if snipBox.topBorderFrame.contains(point) {
            mouseState = .resizeTop
            NSCursor.resizeUp.set()
        } else {
            mouseState = .normal
            NSCursor.arrow.set()
        }
    }

    // MARK: - Private methods

    private func updateMask() {
        let rect = snipRect.intersection(windowFrame)

        let path = CGMutablePath()
        path.addRect(windowFrame)
        path.addRect(rect)
        maskLayer.path = path

        let inset = -snipBox.borderFrameWidth / 2
        snipBox.frame = rect.insetBy(dx: inset, dy: inset)
    }
}
