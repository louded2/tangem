//
//  OnboardingViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 15.09.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import SwiftUI
import Combine
import TangemSdk

class OnboardingViewModel<Step: OnboardingStep, Coordinator: OnboardingRoutable> {
    @Injected(\.userWalletRepository) private var userWalletRepository: UserWalletRepository
    @Injected(\.tangemSdkProvider) private var tangemSdkProvider: TangemSdkProviding

    let navbarSize: CGSize = .init(width: UIScreen.main.bounds.width, height: 44)
    let resetAnimDuration: Double = 0.3

    @Published var steps: [Step] = []
    @Published var currentStepIndex: Int = 0
    @Published var isMainButtonBusy: Bool = false
    @Published var isSupplementButtonBusy: Bool = false
    @Published var shouldFireConfetti: Bool = false
    @Published var isInitialAnimPlayed = false
    @Published var mainCardSettings: AnimatedViewSettings = .zero
    @Published var supplementCardSettings: AnimatedViewSettings = .zero
    @Published var isNavBarVisible: Bool = false
    @Published var alert: AlertBinder?
    @Published var cardImage: Image?
    @Published var secondImage: Image?

    private var confettiFired: Bool = false
    var bag: Set<AnyCancellable> = []

    var currentStep: Step {
        if currentStepIndex >= steps.count {
            return Step.initialStep
        }

        return steps[currentStepIndex]
    }

    var currentProgress: CGFloat {
        CGFloat(currentStepIndex + 1) / CGFloat(input.steps.stepsCount)
    }

    var navbarTitle: String {
        Localization.onboardingGettingStarted
    }

    var title: String? {
        if !isInitialAnimPlayed, let welcomeStep = input.welcomeStep {
            return welcomeStep.title
        }

        return currentStep.title
    }

    var subtitle: String? {
        if !isInitialAnimPlayed, let welcomteStep = input.welcomeStep {
            return welcomteStep.subtitle
        }

        return currentStep.subtitle
    }

    var mainButtonSettings: MainButton.Settings? {
        MainButton.Settings(
            title: mainButtonTitle,
            style: .primary,
            isLoading: isMainButtonBusy,
            action: mainButtonAction
        )
    }

    var isOnboardingFinished: Bool {
        currentStep == steps.last
    }

    var mainButtonTitle: String {
        if !isInitialAnimPlayed, let welcomeStep = input.welcomeStep {
            return welcomeStep.mainButtonTitle
        }

        return currentStep.mainButtonTitle
    }

    var supplementButtonSettings: TangemButtonSettings? {
        .init(
            title: supplementButtonTitle,
            size: .wide,
            action: supplementButtonAction,
            isBusy: isSupplementButtonBusy,
            isEnabled: true,
            isVisible: isSupplementButtonVisible,
            color: .transparentWhite
        )
    }

    var supplementButtonTitle: String {
        if !isInitialAnimPlayed, let welcomteStep = input.welcomeStep {
            return welcomteStep.supplementButtonTitle
        }

        return currentStep.supplementButtonTitle
    }

    var isBackButtonVisible: Bool {
        if !isInitialAnimPlayed || isFromMain {
            return false
        }

        if isOnboardingFinished {
            return false
        }

        return true
    }

    var isBackButtonEnabled: Bool {
        true
    }

    var isSupplementButtonVisible: Bool { currentStep.isSupplementButtonVisible }

    lazy var userWalletStorageAgreementViewModel = UserWalletStorageAgreementViewModel(coordinator: self)

    let input: OnboardingInput

    var isFromMain: Bool = false
    private(set) var containerSize: CGSize = .zero
    unowned let coordinator: Coordinator

    init(input: OnboardingInput, coordinator: Coordinator) {
        self.input = input
        self.coordinator = coordinator
        isFromMain = input.isStandalone
        isNavBarVisible = input.isStandalone

        loadImage(
            supportsOnlineImage: input.cardInput.cardModel?.supportsOnlineImage ?? false,
            cardId: input.cardInput.cardModel?.cardId,
            cardPublicKey: input.cardInput.cardModel?.cardPublicKey
        )

        bindAnalytics()
    }

    func loadImage(supportsOnlineImage: Bool, cardId: String?, cardPublicKey: Data?) {
        guard let cardId = cardId, let cardPublicKey = cardPublicKey else {
            return
        }

        CardImageProvider(supportsOnlineImage: supportsOnlineImage)
            .loadImage(cardId: cardId, cardPublicKey: cardPublicKey)
            .map { $0.image }
            .sink { [weak self] image in
                withAnimation {
                    self?.cardImage = image
                }
            }
            .store(in: &bag)
    }

    func setupContainer(with size: CGSize) {
        let isInitialSetup = containerSize == .zero
        containerSize = size
        if (isFromMain && isInitialAnimPlayed) || isInitialSetup {
            setupCardsSettings(animated: !isInitialSetup, isContainerSetup: true)
        }
    }

    func playInitialAnim(includeInInitialAnim: (() -> Void)? = nil) {
        let animated = !isFromMain
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(animated ? .default : nil) {
                self.isInitialAnimPlayed = true
                self.isNavBarVisible = true
                self.setupCardsSettings(animated: animated, isContainerSetup: false)
                includeInInitialAnim?()
            }
        }
    }

    func onOnboardingFinished(for cardId: String) {
        AppSettings.shared.cardsStartedActivation.remove(cardId)
    }

    func backButtonAction() {}

    func fireConfetti() {
        if !confettiFired {
            shouldFireConfetti = true
            confettiFired = true
            Analytics.log(.walletCreatedSuccessfully)
        }
    }

    func goToStep(with index: Int) {
        withAnimation {
            currentStepIndex = index
            setupCardsSettings(animated: true, isContainerSetup: false)
        }
    }

    func goToNextStep() {
        if isOnboardingFinished {
            do {
                try handleUserWalletOnFinish()
            } catch {
                AppLog.shared.error(error)
                return
            }

            DispatchQueue.main.async {
                self.onboardingDidFinish()
            }

            self.onOnboardingFinished(for: self.input.cardInput.cardId)

            return
        }

        var newIndex = currentStepIndex + 1
        if newIndex >= steps.count {
            newIndex = steps.count - 1
        }

        goToStep(with: newIndex)
    }

    func goToStep(_ step: Step) {
        guard let newIndex = steps.firstIndex(of: step) else {
            AppLog.shared.debug("Failed to find step \(step)")
            return
        }

        goToStep(with: newIndex)
    }

    func mainButtonAction() {
        fatalError("Not implemented")
    }

    func supplementButtonAction() {
        fatalError("Not implemented")
    }

    func setupCardsSettings(animated: Bool, isContainerSetup: Bool) {
        fatalError("Not implemented")
    }

    func didAskToSaveUserWallets(agreed: Bool) {
        AppSettings.shared.askedToSaveUserWallets = true

        AppSettings.shared.saveUserWallets = agreed
        AppSettings.shared.saveAccessCodes = agreed

        Analytics.log(.onboardingEnableBiometric, params: [.state: Analytics.ParameterValue.state(for: agreed).rawValue])
    }

    func handleUserWalletOnFinish() throws {
        guard
            AppSettings.shared.saveUserWallets,
            let userWallet = input.cardInput.cardModel?.userWallet
        else {
            return
        }

        userWalletRepository.save(userWallet)
        userWalletRepository.setSelectedUserWalletId(userWallet.userWalletId, reason: .inserted)
    }

    private func bindAnalytics() {
        $currentStepIndex
            .dropFirst()
            .removeDuplicates()
            .receiveValue { [weak self] index in
                guard let self else { return }

                let currentStep = self.currentStep

                if let walletStep = currentStep as? WalletOnboardingStep {
                    switch walletStep {
                    case .kycProgress:
                        Analytics.log(.kycProgressScreenOpened)
                    case .kycRetry:
                        Analytics.log(.kycRetryScreenOpened)
                    case .kycWaiting:
                        Analytics.log(.kycWaitingScreenOpened)
                    case .claim:
                        Analytics.log(.claimScreenOpened)
                    default:
                        break
                    }
                }
            }
            .store(in: &bag)
    }
}

// MARK: - Navigation
extension OnboardingViewModel {
    func onboardingDidFinish() {
        coordinator.onboardingDidFinish()
    }

    func closeOnboarding() {
        coordinator.closeOnboarding()
    }

    func openSupportChat() {
        guard let cardModel = input.cardInput.cardModel else { return }

        let dataCollector = DetailsFeedbackDataCollector(cardModel: cardModel,
                                                         userWalletEmailData: cardModel.emailData)

        coordinator.openSupportChat(cardId: cardModel.cardId,
                                    dataCollector: dataCollector)
    }
}

extension OnboardingViewModel: UserWalletStorageAgreementRoutable {
    func didAgreeToSaveUserWallets() {
        userWalletRepository.unlock(with: .biometry) { [weak self] result in
            switch result {
            case .error(let error):
                if let tangemSdkError = error as? TangemSdkError,
                   case .userCancelled = tangemSdkError
                {
                    return
                }
                AppLog.shared.error(error)

                self?.didAskToSaveUserWallets(agreed: false)
            default:
                self?.didAskToSaveUserWallets(agreed: true)
            }

            self?.goToNextStep()
        }
    }

    func didDeclineToSaveUserWallets() {
        didAskToSaveUserWallets(agreed: false)
        goToNextStep()
    }
}
