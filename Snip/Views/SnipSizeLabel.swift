//
//  SnipSizeLabel.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/30.
//

import SwiftUI

struct SnipSizeLabel: View {
    private let rect: NSRect

    init(of rect: NSRect) {
        self.rect = rect
    }

    var body: some View {
        HStack(spacing: 0) {
            Text("\(Int(rect.width)) x \(Int(rect.height))")
                .padding(textPadding)

            Divider()
                .frame(height: 16)

            Text("pt")
                .padding(textPadding)
        }
        .font(.callout.monospaced())
        .background {
            Color.black
                .cornerRadius(4)
                .opacity(0.4)
        }
    }

    // MARK: - Constants

    private let textPadding: CGFloat = 3
}

struct SnipSizeLabel_Previews: PreviewProvider {
    static var previews: some View {
        SnipSizeLabel(of: .zero)
    }
}
