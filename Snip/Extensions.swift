//
//  Extensions.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/1.
//

import Cocoa

extension NSScreen {
    /// Returns the screen object where the current mouse is located.
    static var current: NSScreen? {
        screens.first { screen in
            screen.frame.contains(NSEvent.mouseLocation)
        }
    }

    /// Returns the `CGMainDisplayID` value associated with the screen.
    var displayID: CGDirectDisplayID {
        deviceDescription[.init("NSScreenNumber")] as? CGDirectDisplayID ?? .zero
    }
}

extension NSRect {
    /// Returns a rectangle with an origin that is offset from that of the source rectangle but restricted to the bounds.
    /// - Parameters:
    ///   - dx: The offset value for the x-coordinate.
    ///   - dy: The offset value for the y-coordinate.
    ///   - bounds: Boundary limits.
    /// - Returns: A rectangle that is the same size as the source, but with its origin offset by dx units along the x-axis and dy units along the y-axis with respect to the source.
    func offsetBy(dx: CGFloat, dy: CGFloat, bounds: NSRect?) -> Self {
        var newRect = offsetBy(dx: dx, dy: dy).standardized
        guard let standardizedBounds = bounds?.standardized else {
            return newRect
        }

        if newRect.minX < standardizedBounds.minX {
            newRect.origin.x = standardizedBounds.minX
        }
        if newRect.minY < standardizedBounds.minY {
            newRect.origin.y = standardizedBounds.minY
        }
        if newRect.maxX > standardizedBounds.maxX {
            newRect.origin.x = standardizedBounds.maxX - newRect.width
        }
        if newRect.maxY > standardizedBounds.maxY {
            newRect.origin.y = standardizedBounds.maxY - newRect.height
        }

        return newRect
    }

    /// Returns the largest square contained in the rectangle.
    /// - Returns: The largest square contained in the rectangle.
    func square() -> Self {
        // Property `width` and `height` always return standardized value
        let minLength = min(width, height)
        // Property `size.width` and `size.height` may be negative
        let w = size.width < 0 ? -minLength : minLength
        let h = size.height < 0 ? -minLength : minLength
        return .init(x: origin.x, y: origin.y, width: w, height: h)
    }
}

extension NSImage {
    func cropped(to rect: NSRect) -> NSImage {
        let croppedImage = NSImage(size: rect.size)
        croppedImage.lockFocus()
        draw(in: NSRect(origin: .zero, size: rect.size), from: rect, operation: .sourceOver, fraction: 1.0)
        croppedImage.unlockFocus()
        return croppedImage
    }
}

extension Date {
    var string: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
        return formatter.string(from: self)
    }
}
