//
//  SnipWindowController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/28.
//

import Cocoa

class SnipWindowController: NSWindowController {
    convenience init() {
        self.init(window: SnipMaskWindow(screen: .main!))
        showWindow(self)
    }
}
