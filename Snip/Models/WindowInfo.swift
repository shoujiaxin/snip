//
//  WindowInfo.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/10.
//

import Cocoa

struct WindowInfo: Codable {
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

    private struct CodingKeys: CodingKey {
        var intValue: Int?

        var stringValue: String

        init?(intValue: Int) {
            self.intValue = intValue
            stringValue = ""
        }

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        static let alpha = Self(stringValue: kCGWindowAlpha as String)!
        static let bounds = Self(stringValue: kCGWindowBounds as String)!
        static let isOnscreen = Self(stringValue: kCGWindowIsOnscreen as String)!
        static let layer = Self(stringValue: kCGWindowLayer as String)!
        static let memoryUsage = Self(stringValue: kCGWindowMemoryUsage as String)!
        static let name = Self(stringValue: kCGWindowName as String)!
        static let number = Self(stringValue: kCGWindowNumber as String)!
        static let ownerName = Self(stringValue: kCGWindowOwnerName as String)!
        static let ownerPID = Self(stringValue: kCGWindowOwnerPID as String)!
        static let sharingState = Self(stringValue: kCGWindowSharingState as String)!
        static let storeType = Self(stringValue: kCGWindowStoreType as String)!
    }

    private enum BoundsCodingKeys: String, CodingKey {
        case height = "Height"
        case width = "Width"
        case x = "X"
        case y = "Y"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let boundsContainer = try container.nestedContainer(keyedBy: BoundsCodingKeys.self, forKey: .bounds)

        alpha = try container.decode(Double.self, forKey: .alpha)
        bounds = NSRect(x: try boundsContainer.decode(Double.self, forKey: .x),
                        y: try boundsContainer.decode(Double.self, forKey: .y),
                        width: try boundsContainer.decode(Double.self, forKey: .width),
                        height: try boundsContainer.decode(Double.self, forKey: .height))
        isOnscreen = try container.decode(Bool.self, forKey: .isOnscreen)
        layer = try container.decode(Int.self, forKey: .layer)
        memoryUsage = try container.decode(Int.self, forKey: .memoryUsage)
        name = try container.decode(String.self, forKey: .name)
        number = try container.decode(Int.self, forKey: .number)
        ownerName = try container.decode(String.self, forKey: .ownerName)
        ownerPID = try container.decode(Int.self, forKey: .ownerPID)
        sharingState = .init(rawValue: try container.decode(UInt32.self, forKey: .sharingState)) ?? .none
        storeType = .init(rawValue: try container.decode(UInt32.self, forKey: .storeType)) ?? .backingStoreRetained
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var boundsContainer = container.nestedContainer(keyedBy: BoundsCodingKeys.self, forKey: .bounds)

        try container.encode(alpha, forKey: .alpha)
        try boundsContainer.encode(bounds.minX, forKey: .x)
        try boundsContainer.encode(bounds.minY, forKey: .y)
        try boundsContainer.encode(abs(bounds.width), forKey: .width)
        try boundsContainer.encode(abs(bounds.height), forKey: .height)
        try container.encode(isOnscreen, forKey: .isOnscreen)
        try container.encode(layer, forKey: .layer)
        try container.encode(memoryUsage, forKey: .memoryUsage)
        try container.encode(name, forKey: .name)
        try container.encode(number, forKey: .number)
        try container.encode(ownerName, forKey: .ownerName)
        try container.encode(ownerPID, forKey: .ownerPID)
        try container.encode(sharingState.rawValue, forKey: .sharingState)
        try container.encode(storeType.rawValue, forKey: .storeType)
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
