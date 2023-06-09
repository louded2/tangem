//
//  QuoteParameters.swift
//
//
//  Created by Pavel Grechikhin on 01.11.2022.
//

import Foundation

public struct QuoteParameters: Encodable {
    public var fromTokenAddress: String
    public var toTokenAddress: String
    public var amount: String
    public var protocols: String?
    public var fee: String?
    public var gasLimit: String?
    public var complexityLevel: String?
    public var mainRouteParts: String?
    public var parts: String?
    public var gasPrice: String?

    public init(
        fromTokenAddress: String,
        toTokenAddress: String,
        amount: String,
        protocols: String? = nil,
        fee: String? = nil,
        gasLimit: String? = nil,
        complexityLevel: String? = nil,
        mainRouteParts: String? = nil,
        parts: String? = nil,
        gasPrice: String? = nil
    ) {
        self.fromTokenAddress = fromTokenAddress
        self.toTokenAddress = toTokenAddress
        self.amount = amount
        self.protocols = protocols
        self.fee = fee
        self.gasLimit = gasLimit
        self.complexityLevel = complexityLevel
        self.mainRouteParts = mainRouteParts
        self.parts = parts
        self.gasPrice = gasPrice
    }
}
