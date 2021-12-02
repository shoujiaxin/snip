//
//  SnipManager.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/28.
//

import Cocoa

class SnipManager {
    static let shared = SnipManager()

    private var windowControllers: [NSScreen: SnipWindowController] = [:]

    func start() {
        guard let screen = NSScreen.current else {
            return
        }

        if !windowControllers.keys.contains(screen) {
            let controller = SnipWindowController(screen: screen)
            controller.showWindow(self)
            windowControllers[screen] = controller
        }

        NSApp.activate(ignoringOtherApps: true)
    }
}
