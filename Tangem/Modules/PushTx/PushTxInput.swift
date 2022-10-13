//
//  PushTxInput.swift
//  Tangem
//
//  Created by Sergey Balashov on 11.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import struct BlockchainSdk.Amount
import struct BlockchainSdk.Transaction

struct PushTxInput {
    let transaction: Transaction
    let walletModel: WalletModel
    let config: UserWalletConfig
    let sdkErrorLogger: SDKErrorLogger
}
