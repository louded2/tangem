//
//  WalletConnectV2MessageHandler.swift
//  Tangem
//
//  Created by Andrew Son on 16/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import WalletConnectSwiftV2
import TangemSdk
import BlockchainSdk

protocol WalletConnectV2HandlersServicing {
    func handle(
        _ request: Request,
        from dApp: WalletConnectSavedSession.DAppInfo,
        using signer: TangemSigner,
        with walletModel: WalletModel
    ) async throws -> RPCResult
}

protocol WalletConnectMessageHandler {
    func messageForUser(from dApp: WalletConnectSavedSession.DAppInfo) async throws -> String
    func handle() async throws -> RPCResult
}

struct WalletConnectV2HandlersService {
    private let uiDelegate: WalletConnectAlertUIDelegate
    private let messageComposer: WalletConnectV2MessageComposable
    private let handlerFactory: WalletConnectHandlersFactory

    private static let userRejectedResult = RPCResult.error(.init(code: 0, message: "User rejected sign"))

    init(
        uiDelegate: WalletConnectAlertUIDelegate,
        messageComposer: WalletConnectV2MessageComposable,
        handlerFactory: WalletConnectHandlersFactory
    ) {
        self.uiDelegate = uiDelegate
        self.messageComposer = messageComposer
        self.handlerFactory = handlerFactory
    }

    private func getHandler(for request: Request, using signer: TangemSigner, walletModel: WalletModel) throws -> WalletConnectMessageHandler {
        let method = request.method
        guard let wcAction = WalletConnectAction(rawValue: method) else {
            throw WalletConnectV2Error.unsupportedWCMethod(method)
        }

        return try handlerFactory.createHandler(for: wcAction, with: request.params, using: signer, and: walletModel)
    }
}

extension WalletConnectV2HandlersService: WalletConnectV2HandlersServicing {
    func handle(_ request: Request, from dApp: WalletConnectSavedSession.DAppInfo, using signer: TangemSigner, with walletModel: WalletModel) async throws -> RPCResult {
        let handler = try getHandler(for: request, using: signer, walletModel: walletModel)

        let rejectAction = {
            AppLog.shared.debug("[WC 2.0] User rejected sign request: \(request)")
            return Self.userRejectedResult
        }

        let selectedAction = await uiDelegate.getResponseFromUser(with: WalletConnectGenericUIRequest(
            event: .sign,
            message: try await handler.messageForUser(from: dApp),
            approveAction: {
                AppLog.shared.debug("[WC 2.0] User approved sign request: \(request)")
                return try await handler.handle()
            },
            rejectAction: rejectAction
        ))

        return try await selectedAction()
    }
}
