//
//  SnipManager.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/28.
//

import Cocoa

class SnipManager {
    static let shared = SnipManager()

    private var windowController: SnipWindowController?

    func start() {
        windowController = NSScreen.screens
            .first { $0.frame.contains(NSEvent.mouseLocation) }
            .map { SnipWindowController(screen: $0) }
        windowController?.showWindow(self)

        NSApp.activate(ignoringOtherApps: true)
    }
}
