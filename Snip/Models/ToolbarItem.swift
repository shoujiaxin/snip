//
//  ToolbarItem.swift
//  Snip
//
//  Created by Jiaxin Shou on 2022/3/12.
//

import Foundation

enum ToolbarItem {
    case divider

    case button(name: String, iconName: String, action: () -> Void)
}

extension ToolbarItem: Identifiable {
    var id: String {
        switch self {
        case .divider:
            return UUID().uuidString
        case let .button(name, iconName, _):
            return "\(name).\(iconName)"
        }
    }
}
