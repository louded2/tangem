//
//  ErrorDTO+Extension.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 31.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Exchanger

extension ErrorDTO {
    enum Error {
        case insufficientLiquidity
        case cannotEstimate
        case notHaveEnoughBalanceForGas
        case addressesAreEqual
        case cannotEstimateNotEnoughFee
        case notEnoughBalance
        case notEnoughAllowance
    }
    
    func parseError() -> ErrorDTO.Error? {
        let descriptionError = self.description.lowercased()
        
        switch descriptionError {
        case let description where description.contains("insufficient liquidity"):
            return .insufficientLiquidity
        case let description where description.contains("cannot estimate"):
            return .cannotEstimate
        case let description where description.contains("you may not have enough balance for gas fee"):
            return .notHaveEnoughBalanceForGas
        case let description where description.contains("fromtokenaddress cannot be equals to totokenaddress"):
            return .addressesAreEqual
        case let description where description.contains("cannot estimate. don't forget about miner fee"):
            return .cannotEstimateNotEnoughFee
        case let description where description.contains("not enough balance"):
            return .notEnoughBalance
        case let description where description.contains("not enough allowance"):
            return .notEnoughAllowance
        default:
            return nil
        }
    }
}
