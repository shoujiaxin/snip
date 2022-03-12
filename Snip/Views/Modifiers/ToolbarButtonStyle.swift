//
//  ToolbarButtonStyle.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/3.
//

import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
            .font(.body.bold())
            .offset(configuration.isPressed ? .init(width: 1, height: 1) : .zero)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}
