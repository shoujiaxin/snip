//
//  SnipImageWindow.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/2.
//

import Cocoa

class SnipImageWindow: NSWindow {
    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }

    override func cancelOperation(_ sender: Any?) {
        super.cancelOperation(sender)

        SnipManager.shared.removeScreenshot(self)
    }
}
