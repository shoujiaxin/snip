//
//  SnipToolbar.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/2.
//

import SwiftUI

@objc protocol SnipToolbarDelegate: AnyObject {
    @objc optional func onCancel()

    @objc optional func onPin()
}

struct SnipToolbar: View {
    weak var delegate: SnipToolbarDelegate?

    var body: some View {
        HStack(spacing: 0) {
            Button {
                delegate?.onCancel?()
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)

            Button {
                delegate?.onPin?()
            } label: {
                Image(systemName: "pin")
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
        }
        .background {
            Color.black
                .cornerRadius(4)
                .opacity(0.6)
        }
    }
}

struct SnipToolbar_Previews: PreviewProvider {
    static var previews: some View {
        SnipToolbar()
    }
}
