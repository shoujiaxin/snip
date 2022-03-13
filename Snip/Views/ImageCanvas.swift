//
//  ImageCanvas.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/14.
//

import SwiftUI

struct ImageCanvas: View {
    @ObservedObject var editor: SnipImageEditor

    var body: some View {
        ZStack {
            Image(nsImage: editor.image)
                .resizable()
        }
    }
}

struct ImageCanvas_Previews: PreviewProvider {
    static var previews: some View {
        let image = NSImage(named: "SnipImage")!
        ImageCanvas(editor: .init(image))
    }
}
