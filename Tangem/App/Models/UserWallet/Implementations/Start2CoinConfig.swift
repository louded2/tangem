//
//  Start2CoinConfig.swift
//  Tangem
//
//  Created by Alexander Osokin on 01.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BlockchainSdk

struct Start2CoinConfig {
    private let card: CardDTO
    private let walletData: WalletData

    private let baseTouUrl = "https://app.tangem.com/tou/"

    private var defaultBlockchain: Blockchain {
        Blockchain.from(blockchainName: walletData.blockchain, curve: card.supportedCurves[0])!
    }

    private func makeTouURL() -> URL? {
        let regionCode = regionCode(for: card.cardId) ?? "fr"
        let languageCode = Locale.current.languageCode ?? "fr"
        let filename = filename(languageCode: languageCode, regionCode: regionCode)
        let url = URL(string: baseTouUrl + filename)
        return url
    }

    private func makeTouID() -> String {
        let regionCode = regionCode(for: card.cardId) ?? "fr"
        let filename = filename(languageCode: "", regionCode: regionCode)
        return baseTouUrl + filename
    }

    private func filename(languageCode: String, regionCode: String) -> String {
        switch (languageCode, regionCode) {
        case ("fr", "ch"):
            return "Start2Coin-fr-ch-tangem.pdf"
        case ("de", "ch"):
            return "Start2Coin-de-ch-tangem.pdf"
        case ("en", "ch"):
            return "Start2Coin-en-ch-tangem.pdf"
        case ("it", "ch"):
            return "Start2Coin-it-ch-tangem.pdf"
        case ("fr", "fr"):
            return "Start2Coin-fr-fr-atangem.pdf"
        case ("de", "at"):
            return "Start2Coin-de-at-tangem.pdf"
        case (_, "fr"):
            return "Start2Coin-fr-fr-atangem.pdf"
        case (_, "ch"):
            return "Start2Coin-en-ch-tangem.pdf"
        case (_, "at"):
            return "Start2Coin-de-at-tangem.pdf"
        default:
            return "Start2Coin-fr-fr-atangem.pdf"
        }
    }

    private func regionCode(for cid: String) -> String? {
        let cidPrefix = cid[cid.index(cid.startIndex, offsetBy: 1)]
        switch cidPrefix {
        case "0":
            return "fr"
        case "1":
            return "ch"
        case "2":
            return "at"
        default:
            return nil
        }
    }

    init(card: CardDTO, walletData: WalletData) {
        self.card = card
        self.walletData = walletData
    }
}

extension Start2CoinConfig: UserWalletConfig {
    var emailConfig: EmailConfig? {
        .init(recipient: "cardsupport@start2coin.com",
              subject: Localization.feedbackSubjectSupport)
    }

    var tou: TOU {
        let id = makeTouID()
        let url = makeTouURL()

        guard let url else {
            return DummyConfig().tou
        }

        return TOU(id: id, url: url)
    }

    var cardsCount: Int {
        1
    }

    var cardSetLabel: String? {
        nil
    }

    var cardName: String {
        "Start2Coin"
    }

    var defaultCurve: EllipticCurve? {
        defaultBlockchain.curve
    }

    var onboardingSteps: OnboardingSteps {
        if card.wallets.isEmpty {
            return .singleWallet([.createWallet] + userWalletSavingSteps + [.success])
        }

        return .singleWallet(userWalletSavingSteps)
    }

    var backupSteps: OnboardingSteps? {
        return nil
    }

    var userWalletSavingSteps: [SingleCardOnboardingStep] {
        guard needUserWalletSavingSteps else { return [] }
        return [.saveUserWallet]
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
        return defaultBlockchains
    }

    var embeddedBlockchain: StorageEntry? {
        return defaultBlockchains.first
    }

    var warningEvents: [WarningEvent] {
        WarningEventsFactory().makeWarningEvents(for: card)
    }

    var tangemSigner: TangemSigner { .init(with: card.cardId) }

    var emailData: [EmailCollectedData] {
        CardEmailDataFactory().makeEmailData(for: card, walletData: walletData)
    }

    var userWalletIdSeed: Data? {
        card.wallets.first?.publicKey
    }

    func getFeatureAvailability(_ feature: UserWalletFeature) -> UserWalletFeature.Availability {
        switch feature {
        case .send:
            return .available
        case .signedHashesCounter:
            if card.firmwareVersion.type == .release {
                return .available
            }

            return .hidden
        case .accessCode:
            return .hidden
        case .passcode:
            return .hidden
        case .longTap:
            return card.settings.isResettingUserCodesAllowed ? .available : .hidden
        case .longHashes:
            return .hidden
        case .backup:
            return .hidden
        case .twinning:
            return .hidden
        case .exchange:
            return .hidden
        case .walletConnect:
            return .hidden
        case .multiCurrency:
            return .hidden
        case .tokensSearch:
            return .hidden
        case .resetToFactory:
            return .hidden
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
        case .tokenSynchronization:
            return .hidden
        case .referralProgram:
            return .hidden
        case .swapping:
            return .hidden
        }
    }

    func makeWalletModel(for token: StorageEntry) throws -> WalletModel {
        guard let walletPublicKey = card.wallets.first(where: { $0.curve == defaultBlockchain.curve })?.publicKey else {
            throw CommonError.noData
        }

        let factory = WalletModelFactory()
        return try factory.makeSingleWallet(walletPublicKey: walletPublicKey,
                                            blockchain: defaultBlockchain,
                                            token: nil,
                                            derivationStyle: card.derivationStyle)
    }
}
