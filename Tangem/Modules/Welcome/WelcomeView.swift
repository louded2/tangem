//
//  WelcomeView.swift
//  Tangem
//
//  Created by Andrew Son on 30.08.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: WelcomeViewModel

    var body: some View {
        ZStack {
            StoriesView(viewModel: viewModel.storiesModel) { // TODO: refactor
                viewModel.storiesModel.currentStoryPage(
                    isScanning: viewModel.isScanningCard,
                    scanCard: viewModel.scanCard,
                    orderCard: viewModel.orderCard,
                    searchTokens: viewModel.openTokensList
                )
            }
            .statusBar(hidden: true)
            .environment(\.colorScheme, viewModel.storiesModel.currentPage.colorScheme)
            .actionSheet(item: $viewModel.discardAlert, content: { $0.sheet })

            ScanTroubleshootingView(isPresented: $viewModel.showTroubleshootingView,
                                    tryAgainAction: viewModel.tryAgain,
                                    requestSupportAction: viewModel.requestSupport)
        }
        .alert(item: $viewModel.error, content: { $0.alert })
        .onAppear(perform: viewModel.onAppear)
    }
}

struct WelcomeOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(viewModel: WelcomeViewModel(coordinator: WelcomeCoordinator()))
    }
}
