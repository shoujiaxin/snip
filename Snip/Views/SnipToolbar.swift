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

    @objc optional func onSave()

    @objc optional func onCopy()
}

struct SnipToolbar: View {
    weak var delegate: SnipToolbarDelegate?

    var body: some View {
        HStack(spacing: 0) {
            Button {
                delegate?.onCancel?()
            } label: {
                Image(systemName: "xmark")
            }

            Button {
                delegate?.onPin?()
            } label: {
                Image(systemName: "pin")
            }

            Button {
                delegate?.onSave?()
            } label: {
                Image(systemName: "square.and.arrow.down")
            }

            Button {
                delegate?.onCopy?()
            } label: {
                Image(systemName: "doc.on.doc")
            }
        }
        .buttonStyle(ToolbarButtonStyle())
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
