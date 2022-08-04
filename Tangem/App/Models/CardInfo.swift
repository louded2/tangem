//
//  CardInfo.swift
//  Tangem
//
//  Created by Alexander Osokin on 25.03.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

#if !CLIP
import BlockchainSdk
#endif

struct CardInfo {
    var card: Card
    var walletData: DefaultWalletData
    var artwork: CardArtwork = .notLoaded
    var derivedKeys: [Data: [DerivationPath: ExtendedPublicKey]] = [:]
    var primaryCard: PrimaryCard? = nil

    var imageLoadDTO: ImageLoadDTO {
        ImageLoadDTO(cardId: card.cardId,
                     cardPublicKey: card.cardPublicKey,
                     artwotkInfo: artworkInfo)
    }

    #if !CLIP
//    var isTestnet: Bool {
//        return card.isTestnet || (defaultBlockchain?.isTestnet ?? false)
//    }


    #endif

    var artworkInfo: ArtworkInfo? {
        switch artwork {
        case .notLoaded, .noArtwork: return nil
        case .artwork(let artwork): return artwork
        }
    }
}

enum CardArtwork: Equatable {
    case notLoaded
    case noArtwork
    case artwork(ArtworkInfo)
}

struct ImageLoadDTO: Equatable {
    let cardId: String
    let cardPublicKey: Data
    let artwotkInfo: ArtworkInfo?
}
