//
//  ReceiveCurrencyViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 17.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

struct ReceiveCurrencyViewModel: Identifiable {
    var id: Int { hashValue }

    private(set) var state: State

    let tokenIcon: SwappingTokenIconViewModel

    var value: String {
        state.value?.groupedFormatted() ?? "0"
    }

    var fiatValue: String {
        state.fiatValue?.currencyFormatted(code: AppSettings.shared.selectedCurrencyCode) ?? "0"
    }

    init(
        state: State,
        tokenIcon: SwappingTokenIconViewModel
    ) {
        self.state = state
        self.tokenIcon = tokenIcon
    }

    mutating func updateState(_ state: State) {
        self.state = state
    }
}

extension ReceiveCurrencyViewModel {
    enum State: Hashable {
        case loading
        case loaded(_ value: Decimal, fiatValue: Decimal)

        var value: Decimal? {
            switch self {
            case .loaded(let value, _):
                return value
            default:
                return nil
            }
        }

        var fiatValue: Decimal? {
            switch self {
            case .loaded(_, let fiatValue):
                return fiatValue
            default:
                return nil
            }
        }
    }
}

extension ReceiveCurrencyViewModel: Hashable {
    static func == (lhs: ReceiveCurrencyViewModel, rhs: ReceiveCurrencyViewModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(state)
        hasher.combine(tokenIcon)
    }
}

