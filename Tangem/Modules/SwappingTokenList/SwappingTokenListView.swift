//
//  SwappingTokenListView.swift
//  Tangem
//
//  Created by Sergey Balashov on 22.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct SwappingTokenListView: View {
    @ObservedObject private var viewModel: SwappingTokenListViewModel

    init(viewModel: SwappingTokenListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            PerfList {
                if #available(iOS 15.0, *) {} else {
                    let horizontalInset: CGFloat = UIDevice.isIOS13 ? 8 : 16
                    SearchBar(text: $viewModel.searchText.value, placeholder: Localization.commonSearch)
                        .padding(.horizontal, UIDevice.isIOS13 ? 0 : 8)
                        .listRowInsets(.init(top: 8, leading: horizontalInset, bottom: 8, trailing: horizontalInset))
                }

                GroupedSection(viewModel.userItems) {
                    SwappingTokenItemView(viewModel: $0)
                } header: {
                    Text(Localization.swappingTokenListYourTokens.uppercased())
                        .style(Fonts.Bold.footnote, color: Colors.Text.tertiary)
                }
                .separatorPadding(68)

                GroupedSection(viewModel.otherItems) {
                    SwappingTokenItemView(viewModel: $0)
                } header: {
                    Text(Localization.swappingTokenListOtherTokens.uppercased())
                        .style(Fonts.Bold.footnote, color: Colors.Text.tertiary)
                }
                .separatorPadding(68)

                if viewModel.hasNextPage {
                    ProgressViewCompat(color: Colors.Icon.informative)
                        .onAppear(perform: viewModel.fetch)
                        .frame(alignment: .center)
                }
            }
            .searchableCompat(text: $viewModel.searchText.value)
            .navigationBarTitle(Text(Localization.swappingTokenListYourTitle), displayMode: .inline)
            .onAppear(perform: viewModel.onAppear)
        }
    }
}
