//
//  ExchangeManagerMock.swift
//  Tangem
//
//  Created by Sergey Balashov on 06.12.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemExchange

struct ExchangeManagerMock: ExchangeManager {
    func setDelegate(_ delegate: TangemExchange.ExchangeManagerDelegate) {}

    func getExchangeItems() -> TangemExchange.ExchangeItems {
        ExchangeItems(source: .mock, destination: .mock)
    }

    func getAvailabilityState() -> ExchangeAvailabilityState { .idle }

    func update(exchangeItems: ExchangeItems) {}

    func update(amount: Decimal?) {}

    func isEnoughAllowance() -> Bool { true }

    func refresh() {}
}
