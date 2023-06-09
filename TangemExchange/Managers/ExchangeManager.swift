//
//  ExchangeManager.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 07.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public protocol ExchangeManager {
    /// Delegate for view updates
    func setDelegate(_ delegate: ExchangeManagerDelegate)

    /// Items which currently to swapping
    func getExchangeItems() -> ExchangeItems

    /// Current manager state
    func getAvailabilityState() -> ExchangeAvailabilityState

    /// Update swapping items and reload rates
    func update(exchangeItems: ExchangeItems)

    /// Update amount for swap
    func update(amount: Decimal?)

    /// Checking that decimal value available for exchange without approved
    /// Only for tokens
    func isEnoughAllowance() -> Bool

    /// Refresh main values
    func refresh()
}
