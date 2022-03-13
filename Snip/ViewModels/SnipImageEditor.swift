//
//  SnipImageEditor.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/9.
//

import SwiftUI

class SnipImageEditor: ObservableObject {
    private(set) var image: NSImage

    init(_ image: NSImage) {
        self.image = image
    }
}
