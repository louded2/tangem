//
//  NoteDemoConfig.swift
//  Tangem
//
//  Created by Alexander Osokin on 01.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BlockchainSdk

struct NoteDemoConfig {
    private let card: Card
    private let noteData: WalletData

    init(card: Card, noteData: WalletData) {
        self.card = card
        self.noteData = noteData
    }

    private var defaultBlockchain: Blockchain {
        let blockchainName = noteData.blockchain.lowercased() == "binance" ? "bsc" : noteData.blockchain
        let defaultBlockchain = Blockchain.from(blockchainName: blockchainName, curve: .secp256k1)!
        return defaultBlockchain
    }

    private var isTestnet: Bool {
        defaultBlockchain.isTestnet
    }
}

extension NoteDemoConfig: UserWalletConfig {
    var emailConfig: EmailConfig {
        .default
    }

    var touURL: URL? {
        nil
    }

    var cardSetLabel: String? {
        nil
    }

    var cardsCount: Int {
        1
    }

    var defaultCurve: EllipticCurve? {
        defaultBlockchain.curve
    }

    var onboardingSteps: OnboardingSteps {
        if card.wallets.isEmpty {
            return .singleWallet([.createWallet, .topup, .successTopup])
        } else {
            if !AppSettings.shared.cardsStartedActivation.contains(card.cardId) {
                return .singleWallet([])
            }

            return .singleWallet([.topup, .successTopup])
        }
    }

    var backupSteps: OnboardingSteps? {
        nil
    }

    var supportedBlockchains: Set<Blockchain> {
        [defaultBlockchain]
    }

    var defaultBlockchains: [StorageEntry] {
        let network = BlockchainNetwork(defaultBlockchain, derivationPath: nil)
        let entry = StorageEntry(blockchainNetwork: network, tokens: [])
        return [entry]
    }

    var persistentBlockchains: [StorageEntry]? {
        return nil
    }

    var embeddedBlockchain: StorageEntry? {
        return defaultBlockchains.first
    }

    var warningEvents: [WarningEvent] {
        var warnings = WarningEventsFactory().makeWarningEvents(for: card)

        if isTestnet {
            warnings.append(.testnetCard)
        } else {
            warnings.append(.demoCard)
        }

        return warnings
    }

    var tangemSigner: TangemSigner { .init(with: card.cardId) }

    var emailData: [EmailCollectedData] {
        CardEmailDataFactory().makeEmailData(for: card, walletData: noteData)
    }

    func getFeatureAvailability(_ feature: UserWalletFeature) -> UserWalletFeature.Availability {
        switch feature {
        case .accessCode:
            return .hidden
        case .passcode:
            return .hidden
        case .longTap:
            return .hidden
        case .send:
            return .available
        case .longHashes:
            return .hidden
        case .signedHashesCounter:
            return .hidden
        case .backup:
            return .hidden
        case .twinning:
            return .hidden
        case .exchange:
            return .disabled(localizedReason: "alert_demo_feature_disabled".localized)
        case .walletConnect:
            return .disabled(localizedReason: "alert_demo_feature_disabled".localized)
        case .multiCurrency:
            return .hidden
        case .tokensSearch:
            return .hidden
        case .resetToFactory:
            return .disabled(localizedReason: "alert_demo_feature_disabled".localized)
        case .receive:
            return .available
        case .withdrawal:
            return .available
        case .hdWallets:
            return .hidden
        case .onlineImage:
            return card.firmwareVersion.type == .release ? .available : .hidden
        case .staking:
            return .available
        case .topup:
            return .available
        }
    }

    func makeWalletModel(for token: StorageEntry) throws -> WalletModel {
        let blockchain = token.blockchainNetwork.blockchain

        guard let walletPublicKey = card.wallets.first(where: { $0.curve == blockchain.curve })?.publicKey else {
            throw CommonError.noData
        }

        let factory = WalletModelFactory()
        let model = try factory.makeSingleWallet(walletPublicKey: walletPublicKey,
                                                 blockchain: blockchain,
                                                 token: token.tokens.first,
                                                 derivationStyle: card.derivationStyle)
        model.demoBalance = DemoUtil().getDemoBalance(for: defaultBlockchain)
        return model
    }
}
