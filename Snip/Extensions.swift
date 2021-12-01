//
//  Extensions.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/1.
//

import Cocoa

extension NSScreen {
    static var current: NSScreen? {
        screens.first { screen in
            screen.frame.contains(NSEvent.mouseLocation)
        }
    }

    var displayID: CGDirectDisplayID {
        deviceDescription[.init("NSScreenNumber")] as! CGDirectDisplayID
    }
}
