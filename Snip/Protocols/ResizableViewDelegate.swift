//
//  ResizableViewDelegate.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/4/27.
//

import Foundation

protocol ResizableViewDelegate: AnyObject {
    /// Informs the delegate that the content's frame begins to move or resize.
    func resizableView(_ view: ResizableView, contentFrameWillBeginChanging rect: NSRect)

    /// Informs the delegate that the content's frame is moved or resized.
    func resizableView(_ view: ResizableView, contentFrameDidChange rect: NSRect)

    /// Informs the delegate that the content's frame has finished moving or resizing.
    func resizableView(_ view: ResizableView, contentFrameDidEndChanging rect: NSRect)
}

// MARK: - Default implementation

extension ResizableViewDelegate {
    func resizableView(_: ResizableView, contentFrameWillBeginChanging _: NSRect) {}

    func resizableView(_: ResizableView, contentFrameDidChange _: NSRect) {}

    func resizableView(_: ResizableView, contentFrameDidEndChanging _: NSRect) {}
}
