//
//  CardEmailDataFactory.swift
//  Tangem
//
//  Created by Alexander Osokin on 15.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

struct CardEmailDataFactory {
    func makeEmailData(for card: CardDTO, walletData: WalletData?) -> [EmailCollectedData] {
        var data: [EmailCollectedData] = [
            .init(type: .card(.cardId), data: card.cardId),
            .init(type: .card(.firmwareVersion), data: card.firmwareVersion.stringValue),
        ]

        if let walletData = walletData {
            data.append(.init(type: .card(.cardBlockchain), data: walletData.blockchain))
        }

        for wallet in card.wallets {
            if let totalSignedHahes = wallet.totalSignedHashes {
                let hashesData = "\(wallet.curve.rawValue) - \(totalSignedHahes)"
                data.append(.init(type: .wallet(.signedHashes), data: hashesData))
            }
        }

        return data
    }
}
