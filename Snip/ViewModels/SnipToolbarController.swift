//
//  SnipToolbarController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/28.
//

import SwiftUI

class SnipToolbarController: ObservableObject {
    let items: [SnipToolbarItem]

    @Published var selectedItem: SnipToolbarItem? = nil {
        willSet {
            if case let .tabItem(_, _, _, onDeselect) = selectedItem {
                onDeselect()
            }
            if case let .tabItem(_, _, onSelect, _) = newValue {
                onSelect()
            }
        }
    }

    init(items: [SnipToolbarItem]) {
        self.items = items
    }
}
