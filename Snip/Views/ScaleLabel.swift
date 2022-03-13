//
//  ScaleLabel.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/14.
//

import SwiftUI

struct ScaleLabel: View {
    var scale: Double

    @State private var opacity: Double = 0

    var body: some View {
        Text("\(Int(scale * 100))%")
            .font(.callout.monospaced())
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background {
                Color.black
                    .opacity(0.6)
            }
            .opacity(opacity)
            .onChange(of: scale) { _ in
                opacity = 0.8
                fadeOut()
            }
    }

    private func fadeOut() {
        withAnimation(.easeInOut(duration: 0.4).delay(1.0)) {
            opacity = 0
        }
    }
}

struct ScaleLabel_Previews: PreviewProvider {
    static var previews: some View {
        ScaleLabel(scale: 1.0)
    }
}
