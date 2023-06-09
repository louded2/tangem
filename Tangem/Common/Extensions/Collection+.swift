//
//  Collection+.swift
//  Tangem
//
//  Created by Sergey Balashov on 12.09.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

extension Swift.Collection {
    /// Simple extension for checking process in empty collection
    /// Use `allConforms` for check each element to satisfy a condition
    /// `allSatisfy` return `true`, if collection `isEmpty`
    func allConforms(_ predicate: (Element) -> Bool) -> Bool {
        !isEmpty && allSatisfy { predicate($0) }
    }
}
