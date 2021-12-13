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

    private var imageWindowController: Set<NSWindowController> = []

    func startCapture() {
        guard maskWindowController == nil else {
            return
        }

        maskWindowController = NSScreen.current.map { SnipMaskWindowController(screen: $0) }
        maskWindowController?.showWindow(self)

        // TODO: Not deactivate other apps
        NSApp.activate(ignoringOtherApps: true)
    }

    func finishCapture() {
        maskWindowController?.close()
        maskWindowController = nil
    }

    func pinScreenshot(_ image: NSImage, at location: NSPoint) {
        let controller = SnipImageWindowController(image: image, location: location)
        controller.showWindow(self)

        imageWindowController.insert(controller)

        finishCapture()

        // TODO: Not deactivate other apps
        NSApp.activate(ignoringOtherApps: true)
    }

    func removeScreenshot(_ sender: Any?) {
        guard let sender = sender as? NSWindow, let controller = sender.windowController else {
            return
        }

        controller.close()
        imageWindowController.remove(controller)
    }
}
