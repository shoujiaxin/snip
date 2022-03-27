//
//  ImageCanvasViewController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/27.
//

import Cocoa
import SwiftUI

class ImageCanvasViewController: NSViewController {
    init(image: NSImage) {
        super.init(nibName: nil, bundle: nil)

        view = NSHostingView(rootView: Image(nsImage: image).resizable())
        view.frame = .init(origin: .zero, size: image.size)
        view.wantsLayer = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func copy() {}

    func save() {}
}
