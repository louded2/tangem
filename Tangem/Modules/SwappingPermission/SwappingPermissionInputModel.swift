//
//  SwappingPermissionInputModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 10.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import TangemExchange

struct SwappingPermissionInputModel {
    let fiatFee: Decimal
    let transactionInfo: ExchangeTransactionDataModel
}
