//
//  SnipSizeLabel.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/11/30.
//

import SwiftUI

struct SnipSizeLabel: View {
    let size: NSSize

    var body: some View {
        HStack(spacing: 0) {
            Text("\(Int(size.width)) ✕ \(Int(size.height))")
                .padding(textPadding)

            Divider()
                .frame(height: 16)

            Text("pt")
                .padding(textPadding)
        }
        .font(.callout.monospaced())
        .foregroundColor(.white)
        .padding(.horizontal, 2)
        .background {
            Color.black
                .cornerRadius(4)
                .opacity(0.6)
        }
    }

    // MARK: - Constants

    private let textPadding: CGFloat = 3
}

struct SnipSizeLabel_Previews: PreviewProvider {
    static var previews: some View {
        SnipSizeLabel(size: .init(width: 100, height: 200))
    }
}
