//
//  Decimal_.swift
//  Tangem
//
//  Created by Alexander Osokin on 02.09.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation

extension Decimal {
    func currencyFormatted(code: String) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.currencyCode = code
        if code == "RUB" {
            formatter.currencySymbol = "₽"
        }
        // formatter.roundingMode = .down
        return formatter.string(from: self as NSDecimalNumber) ?? "\(self) \(code)"
    }

    func groupedFormatted(
        minimumFractionDigits: Int = 0,
        maximumFractionDigits: Int = 8
    ) -> String {
        let formatter = NumberFormatter.grouped
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits

        return formatter.string(from: self as NSDecimalNumber) ?? "\(self)"
    }

    func decimalSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter.decimalSeparator
    }
}
