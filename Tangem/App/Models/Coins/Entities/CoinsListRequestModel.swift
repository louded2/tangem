//
//  CoinsRequestModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 24.05.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

struct CoinsListRequestModel: Encodable {
    let contractAddress: String?
    let networkIds: String?
    let searchText: String?
    let limit: Int?
    let offset: Int?
    let active: Bool?
    let exchange: Bool?

    init(
        contractAddress: String? = nil,
        networkIds: [String],
        searchText: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil,
        active: Bool? = nil,
        exchange: Bool? = nil
    ) {
        self.contractAddress = contractAddress
        self.networkIds = networkIds.isEmpty ? nil : networkIds.joined(separator: ",")
        self.searchText = searchText == "" ? nil : searchText
        self.limit = limit
        self.offset = offset
        self.active = active
        self.exchange = exchange
    }
}
