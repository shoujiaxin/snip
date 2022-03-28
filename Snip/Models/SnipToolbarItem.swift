//
//  SnipToolbarItem.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/12.
//

import Foundation
import SwiftUI

enum SnipToolbarItem {
    case divider

    case button(name: String, iconName: String, action: () -> Void)

    case tabItem(name: String, iconName: String, onSelect: () -> Void, onDeselect: () -> Void = {})
}

extension SnipToolbarItem: Identifiable {
    var id: String {
        switch self {
        case .divider:
            return UUID().uuidString
        case let .button(name, iconName, _),
             let .tabItem(name, iconName, _, _):
            return "\(name).\(iconName)"
        }
    }
}

extension SnipToolbarItem: Equatable {
    static func == (lhs: SnipToolbarItem, rhs: SnipToolbarItem) -> Bool {
        return lhs.id == rhs.id
    }
}
