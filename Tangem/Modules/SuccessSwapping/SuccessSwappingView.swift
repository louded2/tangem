//
//  SuccessSwappingView.swift
//  Tangem
//
//  Created by Sergey Balashov on 18.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct SuccessSwappingView: View {
    @ObservedObject private var viewModel: SuccessSwappingViewModel

    init(viewModel: SuccessSwappingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Color.clear.frame(height: geometry.size.height * 0.1)

                    VStack(spacing: geometry.size.height * 0.2) {
                        Assets.successBigIcon

                        infoView
                    }
                }

                buttonView
            }
            .navigationBarTitle(Text(Localization.swappingSwap), displayMode: .inline)
        }
    }

    private var infoView: some View {
        VStack(spacing: 14) {
            Text(Localization.commonSuccess)
                .style(Fonts.Bold.title1, color: Colors.Text.primary1)

            VStack(spacing: 0) {
                Text(Localization.swappingSwapOfTo(viewModel.sourceFormatted))
                    .style(Fonts.Regular.callout, color: Colors.Text.secondary)

                Text(viewModel.resultFormatted)
                    .style(Fonts.Bold.callout, color: Colors.Text.accent)
            }
        }
    }

    private var buttonView: some View {
        VStack(spacing: 0) {
            Spacer()

            MainButton(
                title: Localization.commonDone,
                action: viewModel.doneDidTapped
            )
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

struct SuccessSwappingView_Preview: PreviewProvider {
    static let viewModel = SuccessSwappingViewModel(
        sourceCurrencyAmount: .init(value: 1000, currency: .mock),
        resultCurrencyAmount: .init(value: 200, currency: .mock),
        coordinator: SwappingCoordinator()
    )

    static var previews: some View {
        NavHolder()
            .sheet(item: .constant(viewModel)) {
                SuccessSwappingView(viewModel: $0)
            }
    }
}
