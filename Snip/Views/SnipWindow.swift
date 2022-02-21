//
//  SnipWindow.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/1.
//

import Cocoa

class SnipWindow: NSWindow {
    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }

    override func cancelOperation(_ sender: Any?) {
        windowController?.cancelOperation(sender)
    }
}
