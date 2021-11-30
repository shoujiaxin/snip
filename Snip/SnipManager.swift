//
//  SnipManager.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/28.
//

import Cocoa

class SnipManager {
    static let shared = SnipManager()

    private var windowControllers: [NSWindowController] = []

    func start() {
        windowControllers.append(SnipWindowController(screen: .main!))
    }
}
