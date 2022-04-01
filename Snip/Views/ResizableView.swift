//
//  ResizableView.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/2/21.
//

import Cocoa

protocol ResizableViewDelegate: AnyObject {
    /// Informs the delegate that the content's frame begins to move or resize.
    func resizableView(_ view: ResizableView, contentFrameWillBeginChanging rect: NSRect)

    /// Informs the delegate that the content's frame is moved or resized.
    func resizableView(_ view: ResizableView, contentFrameDidChange rect: NSRect)

    /// Informs the delegate that the content's frame has finished moving or resizing.
    func resizableView(_ view: ResizableView, contentFrameDidEndChanging rect: NSRect)
}

extension ResizableViewDelegate {
    func resizableView(_: ResizableView, contentFrameWillBeginChanging _: NSRect) {}

    func resizableView(_: ResizableView, contentFrameDidChange _: NSRect) {}

    func resizableView(_: ResizableView, contentFrameDidEndChanging _: NSRect) {}
}

class ResizableView: NSView {
    /// Whether the view is resizable.
    var isResizable: Bool = true

    /// The color of the resizable view's border.
    var borderColor: NSColor = .controlAccentColor

    /// The width of the resizable view's border.
    var borderWidth: CGFloat = 2

    /// The color of the resizing handle.
    var handleColor: NSColor = .controlAccentColor

    /// The radius of the resizing handle.
    var handleRadius: CGFloat = 5

    /// The color of the resizing handle's border.
    var handleBorderColor: NSColor = .white

    /// The width of the resizing handle's border.
    var handleBorderWidth: CGFloat = NSBezierPath.defaultLineWidth

    /// The content of the resizable view.
    var content: NSView? {
        get {
            subviews.first
        }
        set {
            guard let view = newValue else {
                return
            }
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            let top = view.topAnchor.constraint(equalTo: topAnchor, constant: borderInset)
            let right = view.rightAnchor.constraint(equalTo: rightAnchor, constant: -borderInset)
            let bottom = view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -borderInset)
            let left = view.leftAnchor.constraint(equalTo: leftAnchor, constant: borderInset)
            addConstraints([top, right, bottom, left])
        }
    }

    /// Frame of the content in the parent view's coordinate system.
    var contentFrame: NSRect {
        get {
            frame.insetBy(dx: borderInset, dy: borderInset)
        }
        set {
            var rect = superview?.bounds.intersection(newValue) ?? newValue
            rect.size.width = max(rect.width, 1.0)
            rect.size.height = max(rect.height, 1.0)
            frame = rect.integral.insetBy(dx: -borderInset, dy: -borderInset)
        }
    }

    /// The delegate of the resizable view.
    weak var delegate: ResizableViewDelegate?

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

        addGestureRecognizer(NSPanGestureRecognizer(target: self, action: #selector(onPanGesture(gestureRecognizer:))))
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(_ dirtyRect: NSRect) {
        let inset = max(handleRadius + handleBorderWidth, borderWidth / 2)
        let rect = dirtyRect.insetBy(dx: inset, dy: inset)

        // Draw border
        if borderWidth > 0 {
            let border = NSBezierPath(rect: rect)
            borderColor.setStroke()
            border.lineWidth = borderWidth
            border.stroke()
        }

        // Update tracking areas
        trackingAreas.forEach { removeTrackingArea($0) }
        gestureRecognizers.first?.isEnabled = isResizable
        guard isResizable else {
            return
        }
        addTrackingArea(.init(rect: bounds, options: [.activeInActiveApp, .mouseMoved], owner: self, userInfo: nil))
        Area.allCases.forEach { addCursorRect($0.frame(in: bounds, contentPadding: 2 * borderInset), cursor: $0.cursor) }

        // Draw resizing handles
        // FIXME: Performance
        let minShowHandleSize = 10 * (handleRadius + handleBorderWidth)
        guard dirtyRect.width > minShowHandleSize, dirtyRect.height > minShowHandleSize else {
            return
        }
        let handles = NSBezierPath()
        Area.allCases
            .compactMap { $0.resizingHandleFrame(in: rect, size: 2 * handleRadius) }
            .forEach { handles.appendOval(in: $0) }
        handleColor.setFill()
        handles.fill()
        handleBorderColor.setStroke()
        handles.lineWidth = handleBorderWidth
        handles.stroke()
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
              let area = Area.allCases.first(where: { $0.frame(in: bounds, contentPadding: 2 * borderInset).contains(location) })
        else {
            return
        }

        switch area {
        case .topLeftCorner:
            resizingState = .upLeft
        case .topRightCorner:
            resizingState = .upRight
        case .bottomRightCorner:
            resizingState = .downRight
        case .bottomLeftCorner:
            resizingState = .downLeft
        case .topEdge:
            resizingState = .up
        case .rightEdge:
            resizingState = .right
        case .bottomEdge:
            resizingState = .down
        case .leftEdge:
            resizingState = .left
        case .content:
            resizingState = .move
        }
    }

    @objc private func onPanGesture(gestureRecognizer: NSPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            resizingFrame = contentFrame
            delegate?.resizableView(self, contentFrameWillBeginChanging: contentFrame)
        case .changed:
            let translation = gestureRecognizer.translation(in: self)
            switch resizingState {
            case .none:
                return
            case .upLeft:
                contentFrame = .init(x: resizingFrame.origin.x + translation.x, y: resizingFrame.origin.y, width: resizingFrame.width - translation.x, height: resizingFrame.height + translation.y)
            case .upRight:
                contentFrame = .init(x: resizingFrame.origin.x, y: resizingFrame.origin.y, width: resizingFrame.width + translation.x, height: resizingFrame.height + translation.y)
            case .downRight:
                contentFrame = .init(x: resizingFrame.origin.x, y: resizingFrame.origin.y + translation.y, width: resizingFrame.width + translation.x, height: resizingFrame.height - translation.y)
            case .downLeft:
                contentFrame = .init(x: resizingFrame.origin.x + translation.x, y: resizingFrame.origin.y + translation.y, width: resizingFrame.width - translation.x, height: resizingFrame.height - translation.y)
            case .up:
                contentFrame = .init(x: resizingFrame.origin.x, y: resizingFrame.origin.y, width: resizingFrame.width, height: resizingFrame.height + translation.y)
            case .right:
                contentFrame = .init(x: resizingFrame.origin.x, y: resizingFrame.origin.y, width: resizingFrame.width + translation.x, height: resizingFrame.height)
            case .down:
                contentFrame = .init(x: resizingFrame.origin.x, y: resizingFrame.origin.y + translation.y, width: resizingFrame.width, height: resizingFrame.height - translation.y)
            case .left:
                contentFrame = .init(x: resizingFrame.origin.x + translation.x, y: resizingFrame.origin.y, width: resizingFrame.width - translation.x, height: resizingFrame.height)
            case .move:
                contentFrame = resizingFrame.offsetBy(dx: translation.x, dy: translation.y, bounds: superview?.bounds)
                needsDisplay = true
            }
        case .ended:
            delegate?.resizableView(self, contentFrameDidEndChanging: contentFrame)
        default:
            return
        }
    }
}

private extension ResizableView {
    enum Area: CaseIterable {
        // Corners
        case topLeftCorner
        case topRightCorner
        case bottomRightCorner
        case bottomLeftCorner

        // Edges
        case topEdge
        case rightEdge
        case bottomEdge
        case leftEdge

        // Inside
        case content
    }

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

private extension ResizableView.Area {
    var cursor: NSCursor {
        switch self {
        case .topLeftCorner:
            return .resizeUpLeft
        case .topRightCorner:
            return .resizeUpRight
        case .bottomRightCorner:
            return .resizeDownRight
        case .bottomLeftCorner:
            return .resizeDownLeft
        case .topEdge:
            return .resizeUp
        case .rightEdge:
            return .resizeRight
        case .bottomEdge:
            return .resizeDown
        case .leftEdge:
            return .resizeLeft
        case .content:
            return .move
        }
    }

    func frame(in rect: NSRect, contentPadding: CGFloat) -> NSRect {
        let x: CGFloat
        let y: CGFloat
        let width: CGFloat
        let height: CGFloat

        switch self {
        case .topLeftCorner:
            x = rect.minX
            y = rect.maxY - contentPadding
            width = contentPadding
            height = contentPadding
        case .topRightCorner:
            x = rect.maxX - contentPadding
            y = rect.maxY - contentPadding
            width = contentPadding
            height = contentPadding
        case .bottomRightCorner:
            x = rect.maxX - contentPadding
            y = rect.minY
            width = contentPadding
            height = contentPadding
        case .bottomLeftCorner:
            x = rect.minX
            y = rect.minY
            width = contentPadding
            height = contentPadding
        case .topEdge:
            x = rect.minX + contentPadding
            y = rect.maxY - contentPadding
            width = rect.width - 2 * contentPadding
            height = contentPadding
        case .rightEdge:
            x = rect.maxX - contentPadding
            y = rect.minY + contentPadding
            width = contentPadding
            height = rect.height - 2 * contentPadding
        case .bottomEdge:
            x = rect.minX + contentPadding
            y = rect.minY
            width = rect.width - 2 * contentPadding
            height = contentPadding
        case .leftEdge:
            x = rect.minX
            y = rect.minY + contentPadding
            width = contentPadding
            height = rect.height - 2 * contentPadding
        case .content:
            x = rect.minX + contentPadding
            y = rect.minY + contentPadding
            width = rect.width - 2 * contentPadding
            height = rect.height - 2 * contentPadding
        }

        return .init(x: x, y: y, width: width, height: height)
    }

    func resizingHandleFrame(in rect: NSRect, size: CGFloat) -> NSRect? {
        let x: CGFloat
        let y: CGFloat

        switch self {
        case .topLeftCorner:
            x = rect.minX
            y = rect.maxY
        case .topRightCorner:
            x = rect.maxX
            y = rect.maxY
        case .bottomRightCorner:
            x = rect.maxX
            y = rect.minY
        case .bottomLeftCorner:
            x = rect.minX
            y = rect.minY
        case .topEdge:
            x = rect.midX
            y = rect.maxY
        case .rightEdge:
            x = rect.maxX
            y = rect.midY
        case .bottomEdge:
            x = rect.midX
            y = rect.minY
        case .leftEdge:
            x = rect.minX
            y = rect.midY
        case .content:
            return nil
        }

        return .init(x: x - size / 2, y: y - size / 2, width: size, height: size)
    }
}
