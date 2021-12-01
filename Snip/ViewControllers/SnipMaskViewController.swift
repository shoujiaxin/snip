//
//  SnipMaskViewController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/30.
//

import Cocoa
import SwiftUI

class SnipMaskViewController: NSViewController {
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

    private let snipMask = SnipMask(frame: .zero)

    private let snipSizeLabel = NSHostingView(rootView: SnipSizeLabel(of: .zero))

    // MARK: - States

    private let frame: NSRect

    private var mouseState: MouseState = .normal

    private var snipBeginLocation: NSPoint = .zero

    private var snipEndLocation: NSPoint = .zero

    private var snipRect: NSRect = .zero

    // MARK: - Initializers

    init(frame: NSRect) {
        self.frame = frame

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        // Do NOT call `super.loadView()` here, since there is no xib file

        view = NSView(frame: frame)

        maskLayer.fillColor = CGColor(gray: 0.5, alpha: 0.5)
        maskLayer.fillRule = .evenOdd
        maskLayer.path = CGPath(rect: frame, transform: nil)
        view.wantsLayer = true
        view.layer?.addSublayer(maskLayer)

        view.addSubview(snipMask)
        view.addSubview(snipSizeLabel)

        view.addTrackingArea(NSTrackingArea(rect: frame, options: [.activeAlways, .mouseMoved], owner: self, userInfo: nil))
    }

    // MARK: - Mouse events

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        // Drag begin
        let currentLocation = event.locationInWindow
        snipBeginLocation = currentLocation
        snipEndLocation = currentLocation

        // Unify coordinate
        snipRect = snipRect.intersection(frame)
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
            if snipRect.maxX > frame.width {
                snipRect.origin.x = frame.width - snipRect.width
            }
            if snipRect.maxY > frame.height {
                snipRect.origin.y = frame.height - snipRect.height
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
        } else {
            mouseState = .normal
            NSCursor.arrow.set()
        }
    }

    // MARK: - Private methods

    private func updateMask() {
        let rect = snipRect.intersection(frame)

        let path = CGMutablePath()
        path.addRect(frame)
        path.addRect(rect)
        maskLayer.path = path

        let inset = -snipMask.borderFrameWidth / 2
        snipMask.frame = rect.insetBy(dx: inset, dy: inset)

        snipSizeLabel.rootView = SnipSizeLabel(of: rect)
        let labelOrigin = NSPoint(x: rect.minX, y: snipMask.frame.maxY)
        let labelSize = snipSizeLabel.intrinsicContentSize
        // TODO: Layout the label on screen
        snipSizeLabel.frame = NSRect(origin: labelOrigin, size: labelSize)
    }
}
