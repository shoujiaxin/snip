//
//  SnipImageView.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/9.
//

import SwiftUI

struct SnipImageView: View {
    @EnvironmentObject private var editor: SnipImageEditor

    let image: NSImage

    @State private var borderWidth: CGFloat = 3

    @State private var scaleLabelAlpha: CGFloat = 0

    var body: some View {
        ZStack {
            Image(nsImage: image)
                .shadow(color: editor.isFocused ? .accentColor : .gray, radius: 5, x: 0, y: 0)
                .border(Color.accentColor, width: borderWidth)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.2).repeatCount(2)) {
                        borderWidth = 0
                    }
                }

            HStack {
                VStack {
                    Text("100%")
                        .font(.callout.monospaced())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background {
                            Color.black
                                .opacity(0.6)
                        }
                        .opacity(scaleLabelAlpha)

                    Spacer()
                }

                Spacer()
            }
        }
        .padding(10)
    }
}

struct SnipImageView_Previews: PreviewProvider {
    static var previews: some View {
        SnipImageView(image: NSImage(named: "SnipImage")!)
    }
}
