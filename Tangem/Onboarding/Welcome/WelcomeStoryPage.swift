//
//  WelcomeStoryPage.swift
//  Tangem
//
//  Created by Andrey Chukavin on 18.02.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

enum WelcomeStoryPage: Int, Identifiable, CaseIterable {
    var id: Int {
        self.rawValue
    }
    
    case meetTangem
    case awe
    case backup
    case currencies
    case web3
    case finish
    
    var colorScheme: ColorScheme {
        switch self {
        case .meetTangem, .awe, .finish:
            return .dark
        default:
            return .light
        }
    }
    
    var duration: Double {
        return 8
    }
    
    var fps: Double {
        switch self {
        case .meetTangem:
            return 60
        default:
            return 12
        }
    }
}