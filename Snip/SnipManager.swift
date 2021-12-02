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
        guard let screen = NSScreen.current, !windowControllers.keys.contains(screen) else {
            return
        }

        let controller = SnipWindowController(screen: screen)
        controller.showWindow(self)
        windowControllers[screen] = controller

        // TODO: Not deactivate other apps
        NSApp.activate(ignoringOtherApps: true)
    }

    func cancel() {
        guard let screen = NSScreen.current, let controller = windowControllers[screen] else {
            return
        }

        controller.close()
        windowControllers.removeValue(forKey: screen)
    }
}
