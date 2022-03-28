//
//  SnipToolbarController.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/28.
//

import SwiftUI

class SnipToolbarController: ObservableObject {
    let items: [SnipToolbarItem]

    @Published var selectedItem: SnipToolbarItem? = nil

    init(items: [SnipToolbarItem]) {
        self.items = items
    }
}
