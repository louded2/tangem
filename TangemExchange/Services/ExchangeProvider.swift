//
//  ExchangeProvider.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 08.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

protocol ExchangeProvider {
    func fetchExchangeAmountAllowance(for currency: Currency, walletAddress: String) async throws -> Decimal
    func fetchQuote(items: ExchangeItems, amount: String) async throws -> QuoteData
    func fetchTxDataForSwap(items: ExchangeItems, walletAddress: String, amount: String, slippage: Int) async throws -> ExchangeSwapDataModel

    func approveTxData(for currency: Currency) async throws -> ExchangeApprovedDataModel
    func getSpenderAddress(for currency: Currency) async throws -> String
}
