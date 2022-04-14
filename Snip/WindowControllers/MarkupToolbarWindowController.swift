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

    var selectedItem: SnipToolbarItem? {
        get {
            toolbarController.selectedItem
        }
        set {
            toolbarController.selectedItem = newValue
        }
    }

    private var toolbarController: SnipToolbarController!

    private let imageCanvasViewController: ImageCanvasViewController

    init(imageCanvasViewController: ImageCanvasViewController) {
        self.imageCanvasViewController = imageCanvasViewController

        super.init(window: NSPanel(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: false))

        toolbarController = .init(items: [
            .tabItem(name: "Shape", iconName: "rectangle") { [weak self] in
                self?.imageCanvasViewController.markupState = .rectangle
            } onDeselect: { [weak self] in
                self?.imageCanvasViewController.markupState = .none
            },
            .tabItem(name: "Arrow", iconName: "arrow.up.right") {},
            .tabItem(name: "Draw", iconName: "scribble") {},
            .tabItem(name: "Highlight", iconName: "highlighter") {},
            .tabItem(name: "Mosaic", iconName: "mosaic") {},
            .tabItem(name: "Text", iconName: "character") {},
            .divider,
            .button(name: "Undo", iconName: "arrow.uturn.backward") {},
            .button(name: "Redo", iconName: "arrow.uturn.forward") {},
            .divider,
            .button(name: "Save", iconName: "square.and.arrow.down") {},
            .button(name: "Copy", iconName: "doc.on.doc") {},
            .button(name: "Done", iconName: "checkmark") { [weak self] in
                self?.close()
                self?.selectedItem = nil
            },
        ])
        let toolbar = NSHostingView(rootView: SnipToolbar(controller: toolbarController))

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
