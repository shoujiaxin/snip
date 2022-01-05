//
//  EditToolbar.swift
//  Snip
//
//  Created by Jiaxin Shou on 2021/12/13.
//

import SwiftUI

protocol EditToolbarDelegate: AnyObject {
    func onSave()

    func onCopy()

    func onDone()
}

struct EditToolbar: View {
    weak var delegate: EditToolbarDelegate?

    var body: some View {
        HStack(spacing: 0) {
            Group {
                Button {} label: {
                    Image(systemName: "rectangle")
                }
                .help("Shape")

                Button {} label: {
                    Image(systemName: "arrow.up.right")
                }
                .help("Arrow")

                Button {} label: {
                    Image(systemName: "scribble")
                }
                .help("Draw")

                Button {} label: {
                    Image(systemName: "highlighter")
                }
                .help("Highlight")

                Button {} label: {
                    Image(systemName: "mosaic")
                }
                .help("Mosaic")

                Button {} label: {
                    Image(systemName: "character")
                }
                .help("Text")
            }

            Divider()
                .frame(height: 20)

            Group {
                Button {} label: {
                    Image(systemName: "arrow.uturn.backward")
                }
                .help("Undo")

                Button {} label: {
                    Image(systemName: "arrow.uturn.forward")
                }
                .help("Redo")
            }

            Divider()
                .frame(height: 20)

            Group {
                Button {
                    delegate?.onSave()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .help("Save")

                Button {
                    delegate?.onCopy()
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .help("Copy")

                Button {
                    delegate?.onDone()
                } label: {
                    Image(systemName: "checkmark")
                }
                .help("Done")
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

struct EditToolbar_Previews: PreviewProvider {
    static var previews: some View {
        EditToolbar()
    }
}
