//
//  ToolbarView.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/12.
//

import SwiftUI

struct ToolbarView: View {
    let items: [ToolbarItem]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                switch item {
                case .divider:
                    Divider()
                        .frame(height: 20)
                case let .button(name: name, iconName: iconName, action: action):
                    Button(action: action) {
                        Image(systemName: iconName)
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .help(name)
                }
            }
        }
        .background {
            Color.black
                .cornerRadius(4)
                .opacity(0.6)
        }
    }
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarView(items: [
            .button(name: "Cancel", iconName: "xmark") {},
            .button(name: "Pin", iconName: "pin") {},
            .button(name: "Save", iconName: "square.and.arrow.down") {},
            .button(name: "Copy", iconName: "doc.on.doc") {},
        ])

        ToolbarView(items: [
            .button(name: "Shape", iconName: "rectangle") {},
            .button(name: "Arrow", iconName: "arrow.up.right") {},
            .button(name: "Draw", iconName: "scribble") {},
            .button(name: "Highlight", iconName: "highlighter") {},
            .button(name: "Mosaic", iconName: "mosaic") {},
            .button(name: "Text", iconName: "character") {},
            .divider,
            .button(name: "Undo", iconName: "arrow.uturn.backward") {},
            .button(name: "Redo", iconName: "arrow.uturn.forward") {},
            .divider,
            .button(name: "Save", iconName: "square.and.arrow.down") {},
            .button(name: "Copy", iconName: "doc.on.doc") {},
            .button(name: "Done", iconName: "checkmark") {},
        ])
    }
}
