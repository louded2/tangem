//
//  WalletConnectV2Error.swift
//  Tangem
//
//  Created by Andrew Son on 13/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import BlockchainSdk

enum WalletConnectV2Error: LocalizedError {
    case unsupportedBlockchains([String])
    case sessionForTopicNotFound
    case missingBlockchains([String])
    case unsupportedWCMethod(String)
    case spaghettiError(String)
    case dataInWrongFormat(String)
    case notEnoughDataInRequest(String)
    case missingGasLoader
    case missingEthTransactionSigner
    case missingTransaction
    case transactionSentButNotFoundInManager

    case unknown(String)

    var code: Int {
        switch self {
        case .unsupportedBlockchains: return 8001
        case .sessionForTopicNotFound: return 8002
        case .missingBlockchains: return 8003
        case .unsupportedWCMethod: return 8004
        case .spaghettiError: return 8005
        case .dataInWrongFormat: return 8006
        case .notEnoughDataInRequest: return 8007
        case .missingGasLoader: return 8008
        case .missingEthTransactionSigner: return 8009
        case .missingTransaction: return 8010
        case .transactionSentButNotFoundInManager: return 8011

        case .unknown: return 8999
        }
    }

    init?(from string: String) {
        switch string {
        case "sessionForTopicNotFound": self = .sessionForTopicNotFound
        default: return nil
        }
    }
}

struct WalletConnectV2ErrorMappingUtils {
    func mapWCv2Error(_ error: Error) -> WalletConnectV2Error {
        let string = "\(error)"
        guard let mappedError = WalletConnectV2Error(from: string) else {
            return .unknown(string)
        }

        return mappedError
    }
}
