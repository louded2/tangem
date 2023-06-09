//
//  ExchangeManagerUtil.swift
//  TangemExchange
//
//  Created by Sergey Balashov on 05.12.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public struct ExchangeManagerUtil {
    public init() {}

    public func isNetworkAvailableForExchange(networkId: String) -> Bool {
        ExchangeBlockchain(networkId: networkId) != nil
    }
}
