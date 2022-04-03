//
//  MarkupShapeView.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/4/3.
//

import SwiftUI

struct MarkupShapeView: View {
    var body: some View {
        Rectangle()
            .stroke(lineWidth: 2)
            .foregroundColor(.red)
    }
}

struct MarkupShapeView_Previews: PreviewProvider {
    static var previews: some View {
        MarkupShapeView()
    }
}
