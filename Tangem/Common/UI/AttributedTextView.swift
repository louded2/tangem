//
//  AttributedTextView.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 30.05.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct AttributedTextView: UIViewRepresentable {
    let attributedString: NSAttributedString

    init(_ attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()

        label.lineBreakMode = .byClipping
        label.numberOfLines = 0

        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedString
    }
}
