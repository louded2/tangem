//
//  WalletConnectHandlersFactory.swift
//  Tangem
//
//  Created by Andrew Son on 18/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import WalletConnectSwiftV2

struct WalletConnectHandlersFactory {
    private let messageComposer: WalletConnectV2MessageComposable
    private let uiDelegate: WalletConnectUIDelegate
    private let ethTransactionBuilder: WalletConnectEthTransactionBuildable

    init(
        messageComposer: WalletConnectV2MessageComposable,
        uiDelegate: WalletConnectUIDelegate,
        ethTransactionBuilder: WalletConnectEthTransactionBuildable
    ) {
        self.messageComposer = messageComposer
        self.uiDelegate = uiDelegate
        self.ethTransactionBuilder = ethTransactionBuilder
    }

    func createHandler(for action: WalletConnectAction, with params: AnyCodable, using signer: TangemSigner, and walletModel: WalletModel) throws -> WalletConnectMessageHandler {
        let wcSigner = WalletConnectSigner(walletModel: walletModel, signer: signer)
        switch action {
        case .personalSign:
            return try WalletConnectV2PersonalSignHandler(
                request: params,
                using: wcSigner
            )
        case .signTransaction:
            return try WalletConnectV2SignTransactionHandler(
                requestParams: params,
                walletModel: walletModel,
                transactionBuilder: ethTransactionBuilder,
                messageComposer: messageComposer,
                signer: signer
            )
        case .sendTransaction:
            return try WalletConnectV2SendTransactionHandler(
                requestParams: params,
                walletModel: walletModel,
                transactionBuilder: ethTransactionBuilder,
                messageComposer: messageComposer,
                signer: signer,
                uiDelegate: uiDelegate
            )
        case .bnbSign, .bnbTxConfirmation:
            // TODO: https://tangem.atlassian.net/browse/IOS-2896
            // Initially this methods was found occasionally and supported without any request
            // Need to find documentation and find place where it can be tested on 2.0
            // This page https://www.bnbchain.org/en/staking has WalletConnect in status 'Coming Soon'
            throw WalletConnectV2Error.unsupportedWCMethod("BNB methods")
        case .signTypedData, .signTypedDataV4:
            return try WalletConnectV2SignTypedDataHandler(
                requestParams: params,
                signer: wcSigner
            )
        case .switchChain:
            throw WalletConnectV2Error.unsupportedWCMethod("Switch chain for WC 2.0")
        }
    }
}
