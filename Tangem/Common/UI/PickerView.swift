//
//  PickerView.swift
//  Tangem
//
//  Created by Alexander Osokin on 16.12.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

struct PickerView: View {
    let contents: [String]
    @Binding var selection: Int

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(0 ..< contents.count, id: \.self) {
                Text(contents[$0]).tag($0)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}
