//
//  TokenDetailsCoordinatorView.swift
//  Tangem
//
//  Created by Alexander Osokin on 21.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

struct TokenDetailsCoordinatorView: CoordinatorView {
    @ObservedObject var coordinator: TokenDetailsCoordinator

    var body: some View {
        ZStack {
            if let model = coordinator.tokenDetailsViewModel {
                TokenDetailsView(viewModel: model)
                    .navigationLinks(links)
            }

            if let coordinator = coordinator.buyingCoordinator {
                BuyingCoordinatorView(coordinator: coordinator, rootView: { self })
            }

            sheets
        }
    }

    @ViewBuilder
    private var links: some View {
        NavHolder()
            .navigation(item: $coordinator.pushedWebViewModel) {
                WebViewContainer(viewModel: $0)
            }
            .navigation(item: $coordinator.swappingCoordinator) {
                SwappingCoordinatorView(coordinator: $0)
            }
//            .navigation(item: $coordinator.cryptoShopCoordinator) {
//                CryptoShopCoordinatorView(coordinator: $0)
//            }
    }

    @ViewBuilder
    private var sheets: some View {
        NavHolder()
            .sheet(item: $coordinator.sendCoordinator) {
                SendCoordinatorView(coordinator: $0)
            }

        NavHolder()
            .sheet(item: $coordinator.pushTxCoordinator) {
                PushTxCoordinatorView(coordinator: $0)
            }

        NavHolder()
            .sheet(item: $coordinator.modalWebViewModel) {
                WebViewContainer(viewModel: $0)
            }

        NavHolder()
            .bottomSheet(
                item: $coordinator.warningRussiaBankCardCoordinator,
                viewModelSettings: .warning
            ) {
                WarningRussiaBankCardCoordinatorView(coordinator: $0)
            }

//        NavHolder()
//            .bottomSheet(
//                item: $coordinator.cryptoShopCoordinator,
//                viewModelSettings: .warning
//            ) {
//
//            }
    }
}
