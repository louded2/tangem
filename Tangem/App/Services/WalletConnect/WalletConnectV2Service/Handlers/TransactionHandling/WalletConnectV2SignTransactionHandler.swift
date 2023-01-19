//
//  WalletConnectV2SignTransactionHandler.swift
//  Tangem
//
//  Created by Andrew Son on 18/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import BlockchainSdk
import WalletConnectSwiftV2

class WalletConnectV2SignTransactionHandler {
    private let ethTransaction: WalletConnectEthTransaction
    private let walletModel: WalletModel
    private let transactionBuilder: WalletConnectEthTransactionBuildable
    private let messageComposer: WalletConnectV2MessageComposable
    private let signer: TangemSigner
    private var transaction: Transaction?

    init(
        requestParams: AnyCodable,
        walletModel: WalletModel,
        transactionBuilder: WalletConnectEthTransactionBuildable,
        messageComposer: WalletConnectV2MessageComposable,
        signer: TangemSigner
    ) throws {
        do {
            let params = try requestParams.get([WalletConnectEthTransaction].self)
            guard let ethTransaction = params.first else {
                throw WalletConnectV2Error.missingTransaction
            }

            self.ethTransaction = ethTransaction
        } catch {
            AppLog.shared.error(error)
            throw error
        }

        self.walletModel = walletModel
        self.transactionBuilder = transactionBuilder
        self.messageComposer = messageComposer
        self.signer = signer
    }
}

extension WalletConnectV2SignTransactionHandler: WalletConnectMessageHandler {
    func messageForUser(from dApp: WalletConnectSavedSession.DAppInfo) async throws -> String {
        let transaction = try await transactionBuilder.buildTx(from: ethTransaction, for: walletModel)
        self.transaction = transaction

        let message = messageComposer.makeMessage(for: transaction, walletModel: walletModel, dApp: dApp)
        return message
    }

    func handle() async throws -> RPCResult {
        guard let ethSigner = walletModel.walletManager as? EthereumTransactionSigner else {
            throw WalletConnectV2Error.missingEthTransactionSigner
        }

        guard let transaction = transaction else {
            throw WalletConnectV2Error.missingTransaction
        }

        async let signedHash = ethSigner.sign(transaction, signer: signer).async()

        return try await .response(AnyCodable(signedHash))
    }
}
