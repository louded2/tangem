//
//  DisclaimerView.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 09.10.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

struct DisclaimerView: View {
    enum DisclaimerViewState {
        case accept
        case read
    }
    
    @State private(set) var openDetails: Bool = false
    var state: DisclaimerViewState = .accept
    var sdkService: TangemSdkService? = nil
    
    @Storage("tangem_tap_terms_of_service_accepted", defaultValue: false)
    static var isTermsOfServiceAccepted: Bool
    
    var body: some View {
        VStack(alignment: .trailing) {
            ScrollView {
                Text("disclaimer_text")
                    .font(Font.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.tangemTapGrayDark2)
                    .padding()
            }
            
            if state == .accept {
                TangemButton(isLoading: false,
                             title: "common_accept",
                             image: "arrow.right") {
                                DisclaimerView.isTermsOfServiceAccepted = true
                                self.openDetails = true
                }.buttonStyle(TangemButtonStyle(size: .big, colorStyle: .green))
                    .padding([.bottom, .trailing])
            }
            
            if sdkService != nil {
                NavigationLink(destination:
                    MainView(viewModel: MainViewModel(cid: sdkService!.cards.first!.key,
                                                      sdkService: sdkService!)),
                               isActive: $openDetails) {
                                EmptyView()
                }
            }
        }
        .foregroundColor(.tangemTapGrayDark6)
        .navigationBarTitle("disclaimer_title")
        .navigationBarBackButtonHidden(state == .accept)
    }
}

struct DisclaimerView_Previews: PreviewProvider {
    static var previews: some View {
        DisclaimerView(sdkService: TangemSdkService())
    }
}
