//
//  MarkupToolbarWindowController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/4/11.
//

import Cocoa
import SwiftUI

class MarkupToolbarWindowController: NSWindowController {
    var isVisible: Bool {
        window?.isVisible ?? false
    }

    init(controller: SnipToolbarController) {
        super.init(window: NSPanel(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: false))

        let toolbar = NSHostingView(rootView: SnipToolbar(controller: controller))

        window?.animationBehavior = .utilityWindow
        window?.backgroundColor = .clear
        window?.contentView = toolbar
        window?.isOpaque = false
        window?.setFrame(.init(origin: .zero, size: toolbar.intrinsicContentSize), display: true)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
