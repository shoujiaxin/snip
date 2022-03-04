//
//  Constants.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/2/21.
//

import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let snip = Self("snip")
}

extension NSCursor {
    private static let iconStyle = NSImage.SymbolConfiguration(pointSize: 15, weight: .heavy)

    static let move: NSCursor = {
        let icon = NSImage(systemSymbolName: "arrow.up.and.down.and.arrow.left.and.right", accessibilityDescription: nil)!.withSymbolConfiguration(iconStyle)!
        return .init(image: icon, hotSpot: .init(x: icon.size.width / 2, y: icon.size.height / 2))
    }()

    static let resizeUpLeft: NSCursor = {
        let icon = NSImage(systemSymbolName: "arrow.up.left", accessibilityDescription: nil)!.withSymbolConfiguration(iconStyle)!
        return .init(image: icon, hotSpot: .init(x: icon.size.width / 2, y: icon.size.height / 2))
    }()

    static let resizeUpRight: NSCursor = {
        let icon = NSImage(systemSymbolName: "arrow.up.right", accessibilityDescription: nil)!.withSymbolConfiguration(iconStyle)!
        return .init(image: icon, hotSpot: .init(x: icon.size.width / 2, y: icon.size.height / 2))
    }()

    static let resizeDownRight: NSCursor = {
        let icon = NSImage(systemSymbolName: "arrow.down.right", accessibilityDescription: nil)!.withSymbolConfiguration(iconStyle)!
        return .init(image: icon, hotSpot: .init(x: icon.size.width / 2, y: icon.size.height / 2))
    }()

    static let resizeDownLeft: NSCursor = {
        let icon = NSImage(systemSymbolName: "arrow.down.left", accessibilityDescription: nil)!.withSymbolConfiguration(iconStyle)!
        return .init(image: icon, hotSpot: .init(x: icon.size.width / 2, y: icon.size.height / 2))
    }()

    static let resizeUp: NSCursor = {
        let icon = NSImage(systemSymbolName: "arrow.up", accessibilityDescription: nil)!.withSymbolConfiguration(iconStyle)!
        return .init(image: icon, hotSpot: .init(x: icon.size.width / 2, y: icon.size.height / 2))
    }()

    static let resizeRight: NSCursor = {
        let icon = NSImage(systemSymbolName: "arrow.right", accessibilityDescription: nil)!.withSymbolConfiguration(iconStyle)!
        return .init(image: icon, hotSpot: .init(x: icon.size.width / 2, y: icon.size.height / 2))
    }()

    static let resizeDown: NSCursor = {
        let icon = NSImage(systemSymbolName: "arrow.down", accessibilityDescription: nil)!.withSymbolConfiguration(iconStyle)!
        return .init(image: icon, hotSpot: .init(x: icon.size.width / 2, y: icon.size.height / 2))
    }()

    static let resizeLeft: NSCursor = {
        let icon = NSImage(systemSymbolName: "arrow.left", accessibilityDescription: nil)!.withSymbolConfiguration(iconStyle)!
        return .init(image: icon, hotSpot: .init(x: icon.size.width / 2, y: icon.size.height / 2))
    }()
}
