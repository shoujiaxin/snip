//
//  ImageCanvasViewController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/27.
//

import Cocoa
import SwiftUI

enum MarkupState {
    case none
    case rectangle
    case ellipse
}

class ImageCanvasViewController: NSViewController {
    var markupState: MarkupState = .none {
        willSet {
            switch newValue {
            case .none:
                view.removeGestureRecognizer(panGestureRecognizer)
                commit()
            default:
                if markupState == .none {
                    view.addGestureRecognizer(panGestureRecognizer)
                }
            }
        }
    }

    private var panGestureRecognizer: NSPanGestureRecognizer!

    init(image: NSImage) {
        super.init(nibName: nil, bundle: nil)

        view = NSHostingView(rootView: Image(nsImage: image).resizable())
        view.frame = .init(origin: .zero, size: image.size)
        view.wantsLayer = true

        panGestureRecognizer = .init(target: self, action: #selector(onPanGesture(gestureRecognizer:)))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: temporary solution
    private var markupLayer: CAShapeLayer?

    @objc private func onPanGesture(gestureRecognizer: NSPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            markupLayer = CAShapeLayer()
            view.layer?.addSublayer(markupLayer!)
            // TODO: Configured by user
            markupLayer?.fillColor = .clear
            markupLayer?.lineWidth = 2
            markupLayer?.strokeColor = NSColor.red.cgColor
        case .changed:
            let location = gestureRecognizer.location(in: view)
            let translation = gestureRecognizer.translation(in: view)
            let startPoint = NSPoint(x: location.x - translation.x, y: location.y - translation.y)
            switch markupState {
            case .rectangle:
                let path = CGMutablePath()
                path.addRect(.init(origin: startPoint, size: .init(width: translation.x, height: translation.y)))
                markupLayer?.path = path
            default:
                return
            }
        case .ended:
            return
        default:
            return
        }
    }

    func copy() {}

    func save() {}

    func commit() {
        print("markup commit")
        let image = NSImage(size: view.bounds.size)
        image.lockFocusFlipped(true)
        NSGraphicsContext.current.map { view.layer?.render(in: $0.cgContext) }
        image.unlockFocus()

        (view as? NSHostingView<Image>)?.rootView = Image(nsImage: image).resizable()
        markupLayer?.removeFromSuperlayer()
    }
}
