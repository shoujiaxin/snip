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

    private var imageWindowControllers: Set<NSWindowController> = []

    @objc func startCapture() {
        guard maskWindowController == nil else {
            return
        }

        maskWindowController = NSScreen.current.map { SnipMaskWindowController(screen: $0) }
        maskWindowController?.showWindow(self)

        // TODO: Not deactivate other apps
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func finishCapture() {
        maskWindowController?.close()
        maskWindowController = nil
    }

    func pinScreenshot(_ image: NSImage, at location: NSPoint) {
        let controller = SnipImageWindowController(image: image, location: location)
        controller.showWindow(self)

        imageWindowControllers.insert(controller)

        finishCapture()

        // TODO: Not deactivate other apps
        NSApp.activate(ignoringOtherApps: true)
    }

    func removeScreenshot(_ sender: Any?) {
        guard let controller = sender as? NSWindowController else {
            return
        }

        controller.close()
        imageWindowControllers.remove(controller)
    }
}
