//
//  TokenIconView.swift
//  Tangem
//
//  Created by Andrew Son on 22/04/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Kingfisher

struct TokenIconView: View {
    var token: TokenItem
    var size: CGSize
    
    private var processor: DownsamplingImageProcessor { .init(size: size) }
    
    var body: some View {
        if let path = token.imagePath, let url = URL(string: path) {
            KFImage(url)
                .placeholder { token.imageView }
                .setProcessor(processor)
                .cacheOriginalImage()
                .scaleFactor(UIScreen.main.scale)
                .resizable()
                .scaledToFit()
        } else {
            token.imageView
        }
    }
    
}