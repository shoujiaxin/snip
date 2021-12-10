//
//  WindowInfo.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/10.
//

import Cocoa

struct WindowInfo: Decodable {
    /// The window’s alpha fade level. This number is in the range 0.0 to 1.0, where 0.0 is fully transparent and 1.0 is fully opaque.
    let alpha: Double

    /// The coordinates of the rectangle are specified in screen space, where the origin is in the upper-left corner of the main display.
    let bounds: NSRect

    /// Whether the window is currently onscreen.
    let isOnscreen: Bool

    /// The window layer number.
    let layer: Int

    /// Estimate of the amount of memory (measured in bytes) used by the window and its supporting data structures.
    let memoryUsage: Int

    /// The name of the window, as configured in Quartz.
    let name: String

    /// The unique window ID within the current user session.
    let number: Int

    /// The name of the application that owns the window.
    let ownerName: String

    /// The process ID of the application that owns the window.
    let ownerPID: Int

    /// Specifies whether and how windows are shared between applications.
    let sharingState: CGWindowSharingType

    /// Specifies how the window device buffers drawing commands.
    let storeType: CGWindowBackingType

    private enum CodingKeys: String, CodingKey {
        case alpha = "kCGWindowAlpha"
        case bounds = "kCGWindowBounds"
        case isOnscreen = "kCGWindowIsOnscreen"
        case layer = "kCGWindowLayer"
        case memoryUsage = "kCGWindowMemoryUsage"
        case name = "kCGWindowName"
        case number = "kCGWindowNumber"
        case ownerName = "kCGWindowOwnerName"
        case ownerPID = "kCGWindowOwnerPID"
        case sharingState = "kCGWindowSharingState"
        case storeType = "kCGWindowStoreType"
    }

    private enum BoundsCodingKeys: String, CodingKey {
        case height = "Height"
        case width = "Width"
        case x = "X"
        case y = "Y"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        alpha = try values.decode(Double.self, forKey: .alpha)
        let boundsValue = try values.nestedContainer(keyedBy: BoundsCodingKeys.self, forKey: .bounds)
        bounds = NSRect(x: try boundsValue.decode(Double.self, forKey: .x),
                        y: try boundsValue.decode(Double.self, forKey: .y),
                        width: try boundsValue.decode(Double.self, forKey: .width),
                        height: try boundsValue.decode(Double.self, forKey: .height))
        isOnscreen = try values.decode(Bool.self, forKey: .isOnscreen)
        layer = try values.decode(Int.self, forKey: .layer)
        memoryUsage = try values.decode(Int.self, forKey: .memoryUsage)
        name = try values.decode(String.self, forKey: .name)
        number = try values.decode(Int.self, forKey: .number)
        ownerName = try values.decode(String.self, forKey: .ownerName)
        ownerPID = try values.decode(Int.self, forKey: .ownerPID)
        sharingState = .init(rawValue: try values.decode(UInt32.self, forKey: .sharingState)) ?? .none
        storeType = .init(rawValue: try values.decode(UInt32.self, forKey: .storeType)) ?? .backingStoreRetained
    }
}

extension WindowInfo {
    /// The window’s frame rectangle in screen coordinates.
    var frame: NSRect {
        guard let screen = NSScreen.screens.first(where: { $0.displayID == CGMainDisplayID() }) else {
            return .zero
        }
        return NSRect(x: bounds.minX, y: screen.frame.maxY - bounds.maxY, width: bounds.width, height: bounds.height)
    }
}
