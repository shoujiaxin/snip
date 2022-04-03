//
//  SnipToolbar.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/12.
//

import SwiftUI

struct SnipToolbar: View {
    @ObservedObject var controller: SnipToolbarController

    @State private var hoveringItem: SnipToolbarItem? = nil

    var body: some View {
        HStack(spacing: 0) {
            ForEach(controller.items, content: makeItem(_:))
        }
        .background {
            Color.black
                .cornerRadius(4)
                .opacity(0.6)
        }
    }

    @ViewBuilder
    private func makeItem(_ item: SnipToolbarItem) -> some View {
        switch item {
        case .divider:
            Divider()
                .frame(height: 20)
        case let .button(name, iconName, action):
            Button(action: action) {
                Image(systemName: iconName)
            }
            .buttonStyle(ToolbarButtonStyle())
            .background {
                if hoveringItem == item {
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
        case let .tabItem(name, iconName, _, _):
            Button {
                if controller.selectedItem == item {
                    controller.selectedItem = nil
                } else {
                    controller.selectedItem = item
                }
            } label: {
                Image(systemName: iconName)
            }
            .buttonStyle(ToolbarButtonStyle())
            .background {
                if hoveringItem == item {
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
            .foregroundColor(controller.selectedItem == item ? .accentColor : .white)
        }
    }
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        let controller1 = SnipToolbarController(items: [
            .button(name: "Cancel", iconName: "xmark") {},
            .button(name: "Pin", iconName: "pin") {},
            .button(name: "Save", iconName: "square.and.arrow.down") {},
            .button(name: "Copy", iconName: "doc.on.doc") {},
        ])
        SnipToolbar(controller: controller1)

        let controller2 = SnipToolbarController(items: [
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
        SnipToolbar(controller: controller2)
    }
}
