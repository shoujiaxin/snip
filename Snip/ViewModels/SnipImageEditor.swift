//
//  SnipImageEditor.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/9.
//

import SwiftUI

class SnipImageEditor: ObservableObject {
    let image: NSImage

    @Published var isFocused: Bool = true

    /// The scale factor of the image.
    @Published private(set) var scale: Double = 1.0

    init(_ image: NSImage) {
        self.image = image
    }

    func imageScaled(_ frame: NSRect) {
        scale = frame.width / image.size.width
    }
}
