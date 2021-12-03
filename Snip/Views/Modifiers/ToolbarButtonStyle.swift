//
//  ToolbarButtonStyle.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/3.
//

import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {
    @State private var isHovering = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
            .font(.body.bold())
            .foregroundColor(isHovering ? .accentColor : .white)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .onHover { isHovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.isHovering = isHovering
                }
            }
            .scaleEffect((!configuration.isPressed && isHovering) ? 1.2 : 1.0)
    }
}
