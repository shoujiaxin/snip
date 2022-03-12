//
//  SnipImageView.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/9.
//

import SwiftUI

struct SnipImageView: View {
    @EnvironmentObject private var editor: SnipImageEditor

    @State private var borderWidth: CGFloat = 2

    @State private var scaleLabelAlpha: CGFloat = 0

    var body: some View {
        ZStack {
            Image(nsImage: editor.image)
                .resizable()
                .shadow(color: editor.isFocused ? .accentColor : .gray, radius: 6, x: 0, y: 0)
                .border(Color.accentColor.opacity(0.6), width: borderWidth)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.2).repeatCount(2)) {
                        borderWidth = 0
                    }
                }

            scaleLabel
        }
        .padding(20)
    }

    private var scaleLabel: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Text("\(Int(editor.scale * 100))%")
                    .font(.callout.monospaced())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background {
                        Color.black
                            .opacity(0.6)
                    }
                    .opacity(scaleLabelAlpha)
                    .onReceive(editor.$scale) { _ in
                        scaleLabelAlpha = 0.8
                        withAnimation(.easeInOut(duration: 0.4).delay(1.0)) {
                            scaleLabelAlpha = 0
                        }
                    }

                Spacer()
            }

            Spacer()
        }
    }
}

struct SnipImageView_Previews: PreviewProvider {
    static var previews: some View {
        SnipImageView()
            .environmentObject(SnipImageEditor(NSImage(named: "SnipImage")!))
    }
}
