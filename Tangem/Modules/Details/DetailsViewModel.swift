//
//  DetailsViewModel.swift
//  Tangem
//
//  Created by Alexander Osokin on 31.08.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import TangemSdk
import BlockchainSdk

class DetailsViewModel: ObservableObject {
    // MARK: - View State

    @Published var walletConnectRowViewModel: WalletConnectRowViewModel?
    @Published var supportSectionModels: [DefaultRowViewModel] = []
    @Published var settingsSectionViewModels: [DefaultRowViewModel] = []
    @Published var legalSectionViewModel: DefaultRowViewModel?
    @Published var environmentSetupViewModel: DefaultRowViewModel?

    @Published var cardModel: CardViewModel
    @Published var error: AlertBinder?

    var canCreateBackup: Bool {
        cardModel.canCreateBackup
    }

    var applicationInfoFooter: String? {
        guard
            let appName: String = InfoDictionaryUtils.appName.value(),
            let version: String = InfoDictionaryUtils.version.value(),
            let bundleVersion: String = InfoDictionaryUtils.bundleVersion.value()
        else {
            return nil
        }

        return String(
            format: "%@ %@ (%@)",
            arguments: [appName, version, bundleVersion]
        )
    }

    deinit {
        AppLog.shared.debug("DetailsViewModel deinit")
    }

    // MARK: - Private

    private var bag = Set<AnyCancellable>()
    private unowned let coordinator: DetailsRoutable

    /// Change to @AppStorage and move to model with IOS 14.5 minimum deployment target
    @AppStorageCompat(StorageType.selectedCurrencyCode)
    private var selectedCurrencyCode: String = "USD"

    init(cardModel: CardViewModel, coordinator: DetailsRoutable) {
        self.cardModel = cardModel
        self.coordinator = coordinator

        bind()
        setupView()
    }

    func prepareBackup() {
        Analytics.log(.buttonCreateBackup)
        if let input = cardModel.backupInput {
            self.openOnboarding(with: input)
        }
    }

    func didFinishOnboarding() {
        setupView()
    }
}

// MARK: - Navigation

extension DetailsViewModel {
    func openOnboarding(with input: OnboardingInput) {
        Analytics.log(.backupScreenOpened)
        coordinator.openOnboardingModal(with: input)
    }

    func openMail() {
        Analytics.log(.buttonSendFeedback)

        guard let emailConfig = cardModel.emailConfig else { return }

        let dataCollector = DetailsFeedbackDataCollector(cardModel: cardModel,
                                                         userWalletEmailData: cardModel.emailData)

        coordinator.openMail(with: dataCollector,
                             recipient: emailConfig.recipient,
                             emailType: .appFeedback(subject: emailConfig.subject))
    }

    func openWalletConnect() {
        coordinator.openWalletConnect(with: cardModel)
    }

    func openCardSettings() {
        guard let userWalletId = cardModel.userWalletId else {
            // This shouldn't be the case, because currently user can't reach this screen
            // with card that doesn't have a wallet.
            return
        }

        Analytics.log(.buttonCardSettings)
        coordinator.openScanCardSettings(with: userWalletId)
    }

    func openAppSettings() {
        guard let userWallet = cardModel.userWallet else { return }

        Analytics.log(.buttonAppSettings)
        coordinator.openAppSettings(userWallet: userWallet)
    }

    func openSupportChat() {
        Analytics.log(.buttonChat)
        let dataCollector = DetailsFeedbackDataCollector(cardModel: cardModel,
                                                         userWalletEmailData: cardModel.emailData)

        coordinator.openSupportChat(cardId: cardModel.cardId,
                                    dataCollector: dataCollector)
    }

    func openDisclaimer() {
        coordinator.openDisclaimer(at: cardModel.cardTouURL)
    }

    func openSocialNetwork(network: SocialNetwork) {
        guard let url = network.url else {
            return
        }

        Analytics.log(.buttonSocialNetwork)
        coordinator.openInSafari(url: url)
    }

    func openEnvironmentSetup() {
        coordinator.openEnvironmentSetup()
    }

    func openReferral() {
        guard let userWalletId = cardModel.userWalletId else {
            // This shouldn't be the case, because currently user can't reach this screen
            // with card that doesn't have a wallet.
            return
        }

        coordinator.openReferral(with: cardModel, userWalletId: userWalletId)
    }
}

// MARK: - Private

extension DetailsViewModel {
    func setupView() {
        setupWalletConnectRowViewModel()
        setupSupportSectionModels()
        setupSettingsSectionViewModels()
        setupLegalSectionViewModels()
        setupEnvironmentSetupSection()
    }

    func bind() {
        cardModel.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &bag)

        $selectedCurrencyCode
            .dropFirst()
            .sink { [weak self] _ in
                self?.setupSettingsSectionViewModels()
            }
            .store(in: &bag)
    }

    func setupWalletConnectRowViewModel() {
        guard cardModel.shouldShowWC else {
            walletConnectRowViewModel = nil
            return
        }

        walletConnectRowViewModel = WalletConnectRowViewModel(
            title: Localization.walletConnectTitle,
            subtitle: Localization.walletConnectSubtitle,
            action: openWalletConnect
        )
    }

    func setupSupportSectionModels() {
        supportSectionModels = [
            DefaultRowViewModel(title: Localization.detailsChat, action: openSupportChat),
            DefaultRowViewModel(title: Localization.detailsRowTitleSendFeedback, action: openMail),
        ]

        if cardModel.canParticipateInReferralProgram && FeatureProvider.isAvailable(.referralProgram) {
            supportSectionModels.append(DefaultRowViewModel(title: Localization.detailsReferralTitle, action: openReferral))
        }
    }

    func setupSettingsSectionViewModels() {
        var viewModels: [DefaultRowViewModel] = []

        if !cardModel.isMultiWallet {
            viewModels.append(DefaultRowViewModel(
                title: Localization.detailsRowTitleCurrency,
                detailsType: .text(selectedCurrencyCode),
                action: coordinator.openCurrencySelection
            ))
        }

        viewModels.append(DefaultRowViewModel(
            title: Localization.cardSettingsTitle,
            action: openCardSettings
        ))

        // TODO: Saving card implementation

        viewModels.append(DefaultRowViewModel(
            title: Localization.appSettingsTitle,
            action: openAppSettings
        ))

        if canCreateBackup {
            viewModels.append(DefaultRowViewModel(
                title: Localization.detailsRowTitleCreateBackup,
                action: prepareBackup
            ))
        }

        settingsSectionViewModels = viewModels
    }

    func setupLegalSectionViewModels() {
        legalSectionViewModel = DefaultRowViewModel(
            title: Localization.disclaimerTitle,
            action: openDisclaimer
        )
    }

    func setupEnvironmentSetupSection() {
        if !AppEnvironment.current.isProduction {
            environmentSetupViewModel = DefaultRowViewModel(title: "Environment setup", action: openEnvironmentSetup)
        }
    }
}
