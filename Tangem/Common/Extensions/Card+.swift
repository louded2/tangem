//
//  Card+.swift
//  Tangem
//
//  Created by Andrew Son on 27/12/20.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import TangemSdk
import BlockchainSdk
import CryptoKit

extension CardDTO {
    var walletSignedHashes: Int {
        wallets.compactMap { $0.totalSignedHashes }.reduce(0, +)
    }

    var walletCurves: [EllipticCurve] {
        wallets.compactMap { $0.curve }
    }

    var hasWallets: Bool {
        !wallets.isEmpty
    }

    var derivationStyle: DerivationStyle? {
        CardDTO.getDerivationStyle(for: batchId, isHdWalletAllowed: settings.isHDWalletAllowed)
    }

    var tangemApiAuthData: TangemApiTarget.AuthData {
        .init(cardId: cardId, cardPublicKey: cardPublicKey)
    }

    var analyticsParameters: [Analytics.ParameterKey: String] {
        var params = [Analytics.ParameterKey: String]()
        params[.firmware] = firmwareVersion.stringValue
        params[.currency] = walletCurves.reduce("", { $0 + $1.rawValue })
        params[.batchId] = batchId

        return params
    }

    static func getDerivationStyle(for batchId: String, isHdWalletAllowed: Bool) -> DerivationStyle? {
        guard isHdWalletAllowed else {
            return nil
        }

        let batchId = batchId.uppercased()

        if BatchId.isDetached(batchId) {
            return .legacy
        }

        return .new
    }
}
