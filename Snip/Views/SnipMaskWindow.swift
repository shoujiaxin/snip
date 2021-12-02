//
//  SnipMaskWindow.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/1.
//

import Cocoa

class SnipMaskWindow: NSWindow {
    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }

    override func cancelOperation(_: Any?) {
        SnipManager.shared.finishCapture()
    }

    // TODO: Disable menu bar in full screen mode
}