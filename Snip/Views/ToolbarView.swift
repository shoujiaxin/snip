//
//  ToolbarView.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/12.
//

import SwiftUI

struct ToolbarView: View {
    let items: [ToolbarItem]

    @State private var hoveringItem: ToolbarItem? = nil

    @State private var selectedItem: ToolbarItem? = nil

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                switch item {
                case .divider:
                    Divider()
                        .frame(height: 20)
                case let .button(name, iconName, action),
                     let .tabItem(name, iconName, action):
                    Button {
                        if case .tabItem = item {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedItem = selectedItem == item ? nil : item
                            }
                        }
                        action()
                    } label: {
                        Image(systemName: iconName)
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .foregroundColor(hoveringItem == item ? .accentColor : .white)
                    .background {
                        if selectedItem == item {
                            Color.secondary
                                .cornerRadius(4)
                                .opacity(0.5)
                        }
                    }
                    .help(name)
                    .onHover { isHovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.hoveringItem = isHovering ? item : nil
                        }
                    }
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
            .tabItem(name: "Shape", iconName: "rectangle") {},
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
            .button(name: "Done", iconName: "checkmark") {},
        ])
    }
}
