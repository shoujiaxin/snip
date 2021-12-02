//
//  SnipManager.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/28.
//

import Cocoa

class SnipManager {
    static let shared = SnipManager()

    private var maskWindowController: SnipMaskWindowController?

    func startCapture() {
        guard maskWindowController == nil else {
            return
        }

        maskWindowController = NSScreen.current.map { SnipMaskWindowController(screen: $0) }
        maskWindowController?.showWindow(self)

        // TODO: Not deactivate other apps
        NSApp.activate(ignoringOtherApps: true)
    }

    func cancelCapture() {
        maskWindowController?.close()
        maskWindowController = nil
    }
}
