//
//  TangemProvider.swift
//  Tangem
//
//  Created by Sergey Balashov on 03.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Moya

class TangemProvider<Target: TargetType>: MoyaProvider<Target> {
    init(configuration: URLSessionConfiguration = .defaultConfiguration) {
        let session = Session(configuration: configuration)

        super.init(session: session)
    }
}

extension URLSessionConfiguration {
    static let defaultConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 30
        return configuration
    }()
}