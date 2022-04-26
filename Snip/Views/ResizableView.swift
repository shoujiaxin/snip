//
//  ResizableView.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/2/21.
//

import Cocoa

class ResizableView: NSView {
    // MARK: - Controls

    /// Frame of the content in the parent view's coordinate system.
    var contentFrame: NSRect {
        get {
            var rect = frame.insetBy(dx: borderInset, dy: borderInset)
            if frame.origin == .zero {
                // Otherwise the origin will be inf
                rect.origin = .zero
            }
            assert(rect.origin.x.isFinite && rect.origin.y.isFinite && rect.width.isFinite && rect.height.isFinite)
            return rect
        }
        set {
            var rect = superview?.bounds.intersection(newValue) ?? newValue
            rect.size.width = max(rect.width, 1.0)
            rect.size.height = max(rect.height, 1.0)
            frame = rect.integral.insetBy(dx: -borderInset, dy: -borderInset)
            assert(frame.origin.x.isFinite && frame.origin.y.isFinite && frame.width.isFinite && frame.height.isFinite)
        }
    }

    /// Whether the view is resizable.
    var isResizable: Bool = true {
        willSet {
            resizingHandles.forEach { $0.isHidden = !newValue }
            gestureRecognizers.first?.isEnabled = newValue
            needsDisplay = isResizable != newValue
        }
    }

    /// The delegate of the resizable view.
    weak var delegate: ResizableViewDelegate?

    // MARK: - UI configurations

    /// The color of the resizable view's border.
    var borderColor: NSColor = .controlAccentColor

    /// The width of the resizable view's border.
    var borderWidth: CGFloat = 2

    /// The color of the resizing handle.
    var handleColor: NSColor = .controlAccentColor {
        willSet {
            resizingHandles.forEach { $0.fillColor = newValue }
        }
    }

    /// The color of the resizing handle's border.
    var handleBorderColor: NSColor = .white {
        willSet {
            resizingHandles.forEach { $0.borderColor = newValue }
        }
    }

    // MARK: - Constants

    /// The radius of the resizing handle.
    private let handleRadius: CGFloat = 5

    /// The width of the resizing handle's border.
    private let handleBorderWidth: CGFloat = 1

    // MARK: - Subviews

    private var resizingHandles: [ResizingHandle] = []

    /// The content of the resizable view.
    var content: NSView? {
        willSet {
            guard let view = newValue else {
                content?.removeFromSuperview()
                return
            }
            contentFrame.size = view.frame.size
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view, positioned: .below, relativeTo: self)
            addConstraints([
                view.topAnchor.constraint(equalTo: topAnchor, constant: borderInset),
                view.rightAnchor.constraint(equalTo: rightAnchor, constant: -borderInset),
                view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -borderInset),
                view.leftAnchor.constraint(equalTo: leftAnchor, constant: borderInset),
            ])
        }
    }

    // MARK: - States

    /// Inset between the view's frame and its content's frame.
    private var borderInset: CGFloat {
        if borderWidth / 2 < handleRadius + handleBorderWidth {
            return borderWidth / 2 + handleRadius + handleBorderWidth
        } else {
            return borderWidth
        }
    }

    /// The content's frame used when resizing. This rectangle would have a negative height or width.
    private var resizingFrame: NSRect = .zero

    /// The current state of resizing.
    private var resizingState: ResizingState = .none

    // MARK: - Lifecycle

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        setupResizingHandles()

        addGestureRecognizer(NSPanGestureRecognizer(target: self, action: #selector(onPanGesture(gestureRecognizer:))))
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupResizingHandles() {
        let handleSize = 2 * (handleRadius + handleBorderWidth)
        let inset = borderWidth > handleSize ? (borderWidth - handleSize) / 2 : 0
        let makeHandle: () -> ResizingHandle = {
            let handle = ResizingHandle()
            handle.fillColor = self.handleColor
            handle.borderColor = self.handleBorderColor
            handle.borderWidth = self.handleBorderWidth
            handle.translatesAutoresizingMaskIntoConstraints = false

            self.addSubview(handle)
            self.resizingHandles.append(handle)

            return handle
        }

        // Top left corner
        let topLeftHandle = makeHandle()
        topLeftHandle.cursor = .resizeUpLeft
        addConstraints([
            topLeftHandle.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            topLeftHandle.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            topLeftHandle.widthAnchor.constraint(equalToConstant: handleSize),
            topLeftHandle.heightAnchor.constraint(equalToConstant: handleSize),
        ])

        // Top right corner
        let topRightHandle = makeHandle()
        topRightHandle.cursor = .resizeUpRight
        addConstraints([
            topRightHandle.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            topRightHandle.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            topRightHandle.widthAnchor.constraint(equalToConstant: handleSize),
            topRightHandle.heightAnchor.constraint(equalToConstant: handleSize),
        ])

        // Bottom right corner
        let bottomRightHandle = makeHandle()
        bottomRightHandle.cursor = .resizeDownRight
        addConstraints([
            bottomRightHandle.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            bottomRightHandle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            bottomRightHandle.widthAnchor.constraint(equalToConstant: handleSize),
            bottomRightHandle.heightAnchor.constraint(equalToConstant: handleSize),
        ])

        // Bottom left corner
        let bottomLeftHandle = makeHandle()
        bottomLeftHandle.cursor = .resizeDownLeft
        addConstraints([
            bottomLeftHandle.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            bottomLeftHandle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            bottomLeftHandle.widthAnchor.constraint(equalToConstant: handleSize),
            bottomLeftHandle.heightAnchor.constraint(equalToConstant: handleSize),
        ])

        // Top edge
        let topHandle = makeHandle()
        topHandle.cursor = .resizeUp
        let topHandleLeftConstraint = topHandle.leftAnchor.constraint(equalTo: topLeftHandle.rightAnchor)
        topHandleLeftConstraint.priority = .defaultLow
        let topHandleRightConstraint = topHandle.rightAnchor.constraint(equalTo: topRightHandle.leftAnchor)
        topHandleRightConstraint.priority = .defaultLow
        addConstraints([
            topHandleLeftConstraint,
            topHandleRightConstraint,
            topHandle.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            topHandle.heightAnchor.constraint(equalToConstant: handleSize),
        ])

        // Right edge
        let rightHandle = makeHandle()
        rightHandle.cursor = .resizeRight
        let rightHandleTopConstraint = rightHandle.topAnchor.constraint(equalTo: topRightHandle.bottomAnchor)
        rightHandleTopConstraint.priority = .defaultLow
        let rightHandleBottomConstraint = rightHandle.bottomAnchor.constraint(equalTo: bottomRightHandle.topAnchor)
        rightHandleBottomConstraint.priority = .defaultLow
        addConstraints([
            rightHandle.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            rightHandleTopConstraint,
            rightHandleBottomConstraint,
            rightHandle.widthAnchor.constraint(equalToConstant: handleSize),
        ])

        // Bottom edge
        let bottomHandle = makeHandle()
        bottomHandle.cursor = .resizeDown
        let bottomHandleLeftConstraint = bottomHandle.leftAnchor.constraint(equalTo: bottomLeftHandle.rightAnchor)
        bottomHandleLeftConstraint.priority = .defaultLow
        let bottomHandleRightConstraint = bottomHandle.rightAnchor.constraint(equalTo: bottomRightHandle.leftAnchor)
        bottomHandleRightConstraint.priority = .defaultLow
        addConstraints([
            bottomHandleLeftConstraint,
            bottomHandleRightConstraint,
            bottomHandle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            bottomHandle.heightAnchor.constraint(equalToConstant: handleSize),
        ])

        // Left edge
        let leftHandle = makeHandle()
        leftHandle.cursor = .resizeLeft
        let leftHandleTopConstraint = leftHandle.topAnchor.constraint(equalTo: topLeftHandle.bottomAnchor)
        leftHandleTopConstraint.priority = .defaultLow
        let leftHandleBottomConstraint = leftHandle.bottomAnchor.constraint(equalTo: bottomLeftHandle.topAnchor)
        leftHandleBottomConstraint.priority = .defaultLow
        addConstraints([
            leftHandle.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            leftHandleTopConstraint,
            leftHandleBottomConstraint,
            leftHandle.widthAnchor.constraint(equalToConstant: handleSize),
        ])
    }

    override func draw(_ dirtyRect: NSRect) {
        // Draw border
        let inset = max(handleRadius + handleBorderWidth, borderWidth / 2)
        let borderRect = dirtyRect.insetBy(dx: inset, dy: inset)
        if borderWidth > 0 {
            let border = NSBezierPath(rect: borderRect)
            borderColor.setStroke()
            border.lineWidth = borderWidth
            border.stroke()
        }

        // Update tracking areas
        trackingAreas.forEach { removeTrackingArea($0) }
        guard isResizable else {
            return
        }
        addTrackingArea(.init(rect: bounds, options: [.activeInActiveApp, .mouseMoved], owner: self, userInfo: nil))

        // Update cursor rects
        let moveCursorRect = bounds.insetBy(dx: borderInset, dy: borderInset)
        addCursorRect(moveCursorRect, cursor: .move)
        resizingHandles.forEach { handle in
            guard let cursor = handle.cursor else {
                return
            }
            addCursorRect(handle.frame, cursor: cursor)
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        delegate?.resizableView(self, contentFrameDidChange: contentFrame)
    }

    override func cursorUpdate(with event: NSEvent) {
        guard NSEvent.pressedMouseButtons == 0 else {
            return
        }
        // Update the cursor only when no mouse button is pressed
        super.cursorUpdate(with: event)
    }

    // MARK: - Mouse events

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)

        guard let location = window?.contentView?.convert(event.locationInWindow, to: self),
              let cursor = resizingHandles.first(where: { $0.frame.contains(location) })?.cursor
        else {
            resizingState = .move
            return
        }

        switch cursor {
        case .resizeUpLeft:
            resizingState = .upLeft
        case .resizeUpRight:
            resizingState = .upRight
        case .resizeDownRight:
            resizingState = .downRight
        case .resizeDownLeft:
            resizingState = .downLeft
        case .resizeUp:
            resizingState = .up
        case .resizeRight:
            resizingState = .right
        case .resizeDown:
            resizingState = .down
        case .resizeLeft:
            resizingState = .left
        default:
            resizingState = .none
        }
    }

    @objc private func onPanGesture(gestureRecognizer: NSPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            resizingFrame = contentFrame
            delegate?.resizableView(self, contentFrameWillBeginChanging: contentFrame)
        case .changed:
            var translation = gestureRecognizer.translation(in: self)
            let isHoldingShift = NSEvent.modifierFlags == .shift
            switch resizingState {
            case .none:
                return
            case .upLeft:
                contentFrame = .init(x: resizingFrame.origin.x + translation.x, y: resizingFrame.origin.y, width: resizingFrame.width - translation.x, height: resizingFrame.height + translation.y)
                if isHoldingShift {
                    contentFrame.size.height = contentFrame.width
                }
            case .upRight:
                contentFrame = .init(x: resizingFrame.origin.x, y: resizingFrame.origin.y, width: resizingFrame.width + translation.x, height: resizingFrame.height + translation.y)
                if isHoldingShift {
                    contentFrame.size.height = contentFrame.width
                }
            case .downRight:
                contentFrame = .init(x: resizingFrame.origin.x, y: resizingFrame.origin.y + translation.y, width: resizingFrame.width + translation.x, height: resizingFrame.height - translation.y)
                if isHoldingShift {
                    contentFrame.size.width = contentFrame.height
                }
            case .downLeft:
                contentFrame = .init(x: resizingFrame.origin.x + translation.x, y: resizingFrame.origin.y + translation.y, width: resizingFrame.width - translation.x, height: resizingFrame.height - translation.y)
                if isHoldingShift {
                    contentFrame.size.width = contentFrame.height
                }
            case .up:
                contentFrame = .init(x: resizingFrame.origin.x, y: resizingFrame.origin.y, width: resizingFrame.width, height: resizingFrame.height + translation.y)
                if isHoldingShift {
                    contentFrame.size.width = contentFrame.height
                }
            case .right:
                contentFrame = .init(x: resizingFrame.origin.x, y: resizingFrame.origin.y, width: resizingFrame.width + translation.x, height: resizingFrame.height)
                if isHoldingShift {
                    contentFrame.size.height = contentFrame.width
                }
            case .down:
                contentFrame = .init(x: resizingFrame.origin.x, y: resizingFrame.origin.y + translation.y, width: resizingFrame.width, height: resizingFrame.height - translation.y)
                if isHoldingShift {
                    contentFrame.size.width = contentFrame.height
                }
            case .left:
                contentFrame = .init(x: resizingFrame.origin.x + translation.x, y: resizingFrame.origin.y, width: resizingFrame.width - translation.x, height: resizingFrame.height)
                if isHoldingShift {
                    contentFrame.size.height = contentFrame.width
                }
            case .move:
                if isHoldingShift {
                    if abs(translation.x) < abs(translation.y) {
                        translation.x = 0
                    } else {
                        translation.y = 0
                    }
                }
                contentFrame = resizingFrame.offsetBy(dx: translation.x, dy: translation.y, bounds: superview?.bounds)
                // Update tracking areas
                needsDisplay = true
            }
        case .ended:
            resizingState = .none
            delegate?.resizableView(self, contentFrameDidEndChanging: contentFrame)
        default:
            return
        }
    }

    // MARK: - Keyboard events

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            // Left arrow
            contentFrame.origin.x -= 1
        case 124:
            // Right arrow
            contentFrame.origin.x += 1
        case 125:
            // Down arrow
            contentFrame.origin.y -= 1
        case 126:
            // Up arrow
            contentFrame.origin.y += 1
        default:
            super.keyDown(with: event)
        }
    }
}

private extension ResizableView {
    enum ResizingState {
        case none
        case upLeft
        case upRight
        case downRight
        case downLeft
        case up
        case right
        case down
        case left
        case move
    }
}
