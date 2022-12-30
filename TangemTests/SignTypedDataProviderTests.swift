//
//  SignTypedDataProviderTests.swift
//  TangemTests
//
//  Created by Sergey Balashov on 28.12.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import XCTest
import BlockchainSdk
import Combine
import TangemExchange

@testable import Tangem

struct SignTypedDataProviderMock: SignTypedDataProviding {
    func buildPermitSignature(domain: EIP712Domain, message: EIP2612PermitMessage) async throws -> UnmarshalledSignedData {
        UnmarshalledSignedData(
            v: Data(hex: "1c"),
            r: Data(hex: "3b448216a78f91e84db06cf54eb1e3758425bd97ffb9d6941ce437ec7a9c2c17"),
            s: Data(hex: "4c94f1fa492007dea3a3c305353bf3430b1ca506dd630ce1fd3da09bd387b2f3")
        )
    }
}

struct EthereumTransactionProcessorMock: EthereumTransactionProcessor {
    var initialNonce: Int { 0 }
    func buildForSign(_ transaction: Transaction) -> AnyPublisher<CompiledEthereumTransaction, Error> { .emptyFail }
    func buildForSend(_ transaction: SignedEthereumTransaction) -> AnyPublisher<String, Error> { .emptyFail }
    func getFee(to: String, data: String?, amount: Amount?) -> AnyPublisher<[Amount], Error> { .emptyFail }
    func send(_ transaction: SignedEthereumTransaction) -> AnyPublisher<String, Error> { .emptyFail }
    func getAllowance(from: String, to: String, contractAddress: String) -> AnyPublisher<String, Error> { .emptyFail }
}

class PermitTypedDataProviderTests: XCTestCase {
    let chainId = 56
    let walletAddress = "0x2c9b2dbdba8a9c969ac24153f5c1c23cb0e63914"

    let spenderAddress = "0x11111112542d85b3ef69ae05771c2dccff4faa26"
    let contractAddress = "0x111111111117dc0aa78b770fa6a738034120c302"
//    let daiLikeTokenAddress = "0x4bd17003473389a42daf6a0a729f6fdb328bbbd7"
    let tokenName = "1INCH Token"
    let daiLikeTokenName = "VAI Stablecoin"

    // 11111112542d85b3ef69ae05771c2dccff4faa26
    // 0x111111111117dc0aa78b770fa6a738034120c302
    // 0x111111111117dc0aa78b770fa6a738034120c302


    private var signTypedDataProvider: SignTypedDataProviding!
    private var permitTypedDataProvider: PermitTypedDataProviding!

    override func setUp() {
        super.setUp()
        signTypedDataProvider = SignTypedDataProviderMock()
        permitTypedDataProvider = PermitTypedDataProvider(
            ethereumTransactionProcessor: EthereumTransactionProcessorMock(),
            signTypedDataProvider: signTypedDataProvider,
            decimalNumberConverter: DecimalNumberConverter()
        )
    }

    func testPermitData() async throws {
        let currency = Currency(
            id: "1inch",
            blockchain: .bsc,
            name: tokenName,
            symbol: "1INCH",
            decimalCount: 8,
            currencyType: .token(contractAddress: contractAddress)
        )

        let parameters = PermitParameters(
            walletAddress: walletAddress,
            spenderAddress: spenderAddress,
            amount: 1,
            deadline: Date(timeIntervalSince1970: 192689033)
        )


        let callData = try await permitTypedDataProvider.buildPermitCallData(for: currency, parameters: parameters)

        let except = [
            "0x",
            "0000000000000000000000002c9b2dbdba8a9c969ac24153f5c1c23cb0e63914",
            "00000000000000000000000011111112542d85b3ef69ae05771c2dccff4faa26",
            "000000000000000000000000000000000000000000000000000000003b9aca00",
            "000000000000000000000000000000000000000000000000000000000b7c3389",
            "000000000000000000000000000000000000000000000000000000000000001c",
            "3b448216a78f91e84db06cf54eb1e3758425bd97ffb9d6941ce437ec7a9c2c17",
            "4c94f1fa492007dea3a3c305353bf3430b1ca506dd630ce1fd3da09bd387b2f3",
        ].joined()

        XCTAssertEqual(callData, except)
    }
}