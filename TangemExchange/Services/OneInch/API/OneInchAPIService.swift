//
//  OneInchAPIService.swift
//  TangemExchange
//
//  Created by Sergey Balashov on 23.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Moya

struct OneInchAPIService: OneInchAPIServicing {
    private let provider = MoyaProvider<OneInchBaseTarget>()
    init() {}

    func healthCheck(blockchain: ExchangeBlockchain) async -> Result<HealthCheck, ExchangeInchError> {
        await request(
            target: OneInchBaseTarget(target: HealthCheckTarget.healthCheck, blockchain: blockchain)
        )
    }

    func tokens(blockchain: ExchangeBlockchain) async -> Result<TokensList, ExchangeInchError> {
        await request(
            target: OneInchBaseTarget(target: InfoTarget.tokens, blockchain: blockchain)
        )
    }

    func presets(blockchain: ExchangeBlockchain) async -> Result<PresetsConfiguration, ExchangeInchError> {
        await request(
            target: OneInchBaseTarget(target: InfoTarget.presets, blockchain: blockchain)
        )
    }

    func liquiditySources(blockchain: ExchangeBlockchain) async -> Result<LiquiditySourcesList, ExchangeInchError> {
        await request(
            target: OneInchBaseTarget(target: InfoTarget.liquiditySources, blockchain: blockchain)
        )
    }

    func quote(blockchain: ExchangeBlockchain, parameters: QuoteParameters) async -> Result<QuoteData, ExchangeInchError> {
        await request(
            target: OneInchBaseTarget(target: ExchangeTarget.quote(parameters), blockchain: blockchain)
        )
    }

    func swap(blockchain: ExchangeBlockchain, parameters: ExchangeParameters) async -> Result<ExchangeData, ExchangeInchError> {
        await request(
            target: OneInchBaseTarget(target: ExchangeTarget.swap(parameters), blockchain: blockchain)
        )
    }

    func spender(blockchain: ExchangeBlockchain) async -> Result<ApproveSpender, ExchangeInchError> {
        await request(
            target: OneInchBaseTarget(target: ApproveTarget.spender, blockchain: blockchain)
        )
    }

    func approveTransaction(blockchain: ExchangeBlockchain, approveTransactionParameters: ApproveTransactionParameters) async -> Result<ApprovedTransactionData, ExchangeInchError> {
        await request(
            target: OneInchBaseTarget(target: ApproveTarget.transaction(approveTransactionParameters), blockchain: blockchain)
        )
    }

    func allowance(blockchain: ExchangeBlockchain, allowanceParameters: ApproveAllowanceParameters) async -> Result<ApprovedAllowance, ExchangeInchError> {
        await request(
            target: OneInchBaseTarget(target: ApproveTarget.allowance(allowanceParameters), blockchain: blockchain)
        )
    }
}

private extension OneInchAPIService {
    func request<T: Decodable>(target: OneInchBaseTarget) async -> Result<T, ExchangeInchError> {
        var response: Response

        do {
            response = try await provider.asyncRequest(target)
            response = try response.filterSuccessfulStatusAndRedirectCodes()
        } catch {
            return .failure(.serverError(withError: error))
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return .success(try decoder.decode(T.self, from: response.data))
        } catch {
            return .failure(.decodeError(error: error))
        }
    }
}