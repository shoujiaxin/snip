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
    // MARK: - Views

    private let imageView: NSHostingView<Image>

    private let markupView = ResizableView(frame: .zero)

    // MARK: - States

    var markupState: MarkupState = .none {
        willSet {
            switch newValue {
            case .none:
                panGestureRecognizer.isEnabled = false
                commit()
            default:
                panGestureRecognizer.isEnabled = true
            }
        }
    }

    private var panGestureRecognizer: NSPanGestureRecognizer!

    // MARK: - Lifecycle

    init(image: NSImage) {
        imageView = .init(rootView: Image(nsImage: image).resizable())

        super.init(nibName: nil, bundle: nil)

        view = .init(frame: .init(origin: .zero, size: image.size))

        setupImageView()
        setupMarkupView()
        setupGestureRecognizers()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {
        imageView.frame = view.bounds
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        let top = imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        let right = imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0)
        let bottom = imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        let left = imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        view.addConstraints([top, right, bottom, left])
    }

    private func setupMarkupView() {
        markupView.borderWidth = 0
        view.addSubview(markupView)
    }

    private func setupGestureRecognizers() {
        panGestureRecognizer = .init(target: self, action: #selector(onPanGesture(gestureRecognizer:)))
        panGestureRecognizer.isEnabled = false
        view.addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func onPanGesture(gestureRecognizer: NSPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            commit()
            markupView.content = NSHostingView(rootView: MarkupShapeView())
            markupView.contentFrame = .zero
        case .ended:
            markupView.isResizable = true
            view.window?.makeFirstResponder(markupView)
        default:
            break
        }

        let location = gestureRecognizer.location(in: view)
        let translation = gestureRecognizer.translation(in: view)
        let startPoint = NSPoint(x: location.x - translation.x, y: location.y - translation.y)
        switch markupState {
        case .rectangle:
            let rect = NSRect(origin: startPoint, size: .init(width: translation.x, height: translation.y))
            markupView.contentFrame = NSEvent.modifierFlags == .shift ? rect.square() : rect
        default:
            return
        }
    }

    func copy() {}

    func save() {}

    func commit() {
        guard markupView.content != nil else {
            return
        }
        markupView.isResizable = false

        let image = NSImage(size: view.bounds.size)
        image.lockFocus()
        NSGraphicsContext.current.map { view.layer?.render(in: $0.cgContext) }
        image.unlockFocus()

        imageView.rootView = Image(nsImage: image).resizable()

        markupView.content = nil
    }
}
