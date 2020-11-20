//
//  Assembly.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 03.11.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BlockchainSdk

class Assembly {
    lazy var config = Config()
    
    lazy var tangemSdk: TangemSdk = {
        let sdk = TangemSdk()
        return sdk
    }()
    
    lazy var navigationCoordinator = NavigationCoordinator()
    lazy var ratesService = CoinMarketCapService(apiKey: config.coinMarketCapApiKey)
    lazy var userPrefsService = UserPrefsService()
    lazy var networkService = NetworkService()
    lazy var walletManagerFactory = WalletManagerFactory()
    lazy var workaroundsService = WorkaroundsService()
    lazy var imageLoaderService: ImageLoaderService = {
        return ImageLoaderService(networkService: networkService)
    }()
    lazy var topupService: TopupService = {
        let s = TopupService()
        s.config = config
        return s
    }()
    
    lazy var cardsRepository: CardsRepository = {
		let crepo = CardsRepository(twinCardFileDecoder: TwinCardTlvFileDecoder())
        crepo.tangemSdk = tangemSdk
        crepo.assembly = self
        return crepo
    }()
    
    private var modelsStorage = [String : Any]()
    
    func makeReadViewModel() -> ReadViewModel {
        let vm: ReadViewModel = get() ?? ReadViewModel()
        initialize(vm)
        vm.userPrefsService = userPrefsService
        vm.cardsRepository = cardsRepository
        return vm
    }
    
    func makeMainViewModel() -> MainViewModel {
        let vm: MainViewModel = get() ?? MainViewModel()
        initialize(vm)
        vm.config = config
        vm.cardsRepository = cardsRepository
        vm.imageLoaderService = imageLoaderService
        vm.topupService = topupService
        vm.state = cardsRepository.lastScanResult
		vm.userPrefsService = userPrefsService
        return vm
    }
    
    func makeWalletModel(from card: Card) -> WalletModel? {
        if let walletManager = walletManagerFactory.makeWalletManager(from: card) {
            let wm = WalletModel(walletManager: walletManager)
            wm.ratesService = ratesService
            return wm
        } else {
            return nil
        }
    }
    
    func makeCardModel(from info: CardInfo) -> CardViewModel? {
        guard let blockchainName = info.card.cardData?.blockchainName,
              let curve = info.card.curve,
              let blockchain = Blockchain.from(blockchainName: blockchainName, curve: curve) else {
            return nil
        }
        
        let vm = CardViewModel(cardInfo: info)
        vm.workaroundsService = workaroundsService
        vm.config = config
        vm.assembly = self
        vm.tangemSdk = tangemSdk
        if config.isEnablePayID, let payIdService = PayIDService.make(from: blockchain) {
            payIdService.workaroundsService = workaroundsService
            vm.payIDService = payIdService
        }
        
        vm.updateState()
        vm.update()
        return vm
    }
    
	func makeDisclaimerViewModel(with state: DisclaimerViewModel.State = .read) -> DisclaimerViewModel {
		let vm: DisclaimerViewModel = get() ?? DisclaimerViewModel(cardViewModel: cardsRepository.lastScanResult.cardModel)
        vm.state = state
        vm.userPrefsService = userPrefsService
        initialize(vm)
        return vm
    }
    
    func makeDetailsViewModel(with card: CardViewModel) -> DetailsViewModel {
        let vm: DetailsViewModel = get() ?? DetailsViewModel(cardModel: card)
        initialize(vm)
        vm.cardsRepository = cardsRepository
        vm.ratesService = ratesService
        return vm
    }
    
    func makeSecurityManagementViewModel(with card: CardViewModel) -> SecurityManagementViewModel {
        let vm: SecurityManagementViewModel = get() ?? SecurityManagementViewModel()
        initialize(vm)
        vm.cardViewModel = card
        return vm
    }
    
    func makeCurrencySelectViewModel() -> CurrencySelectViewModel {
        let vm: CurrencySelectViewModel = get() ?? CurrencySelectViewModel()
        initialize(vm)
        vm.ratesService = ratesService
        return vm
    }
    
    func makeSendViewModel(with amount: Amount, card: CardViewModel) -> SendViewModel {
        let vm: SendViewModel = get() ?? SendViewModel(amountToSend: amount, cardViewModel: card, signer: tangemSdk.signer)
        initialize(vm)
        vm.ratesService = ratesService
        return vm
    }
	
	func makeTwinCardOnboardingViewModel() -> TwinCardOnboardingViewModel {
		let scanResult = cardsRepository.lastScanResult
		let twinPairCid = scanResult.cardModel?.cardInfo.twinCardInfo?.pairCid
		return makeTwinCardOnboardingViewModel(state: .onboarding(withPairCid: twinPairCid ?? ""))
	}
	
	func makeTwinCardWarningViewModel() -> TwinCardOnboardingViewModel {
		makeTwinCardOnboardingViewModel(state: .warning)
	}
	
	func makeTwinCardOnboardingViewModel(state: TwinCardOnboardingViewModel.State) -> TwinCardOnboardingViewModel {
		let vm: TwinCardOnboardingViewModel = get() ?? TwinCardOnboardingViewModel(state: state)
		initialize(vm)
		vm.imageLoader = imageLoaderService
		return vm
	}
	
	func makeTwinsWalletCreationViewModel(isRecreating: Bool) -> TwinsWalletCreationViewModel {
		let vm: TwinsWalletCreationViewModel = get() ?? TwinsWalletCreationViewModel(isRecreatingWallet: isRecreating)
		initialize(vm)
		return vm
	}
    
    private func initialize<V: ViewModel>(_ vm: V) {
        vm.navigation = navigationCoordinator
        vm.assembly = self
        store(vm)
    }
    
    public func reset() {
        let mainKey = String(describing: type(of: MainViewModel.self))
        let readKey = String(describing: type(of: ReadViewModel.self))
        
        let indicesToRemove = modelsStorage.keys.filter { $0 != mainKey && $0 != readKey }
        indicesToRemove.forEach { modelsStorage.removeValue(forKey: $0) }
    }
    
    private func store<T>(_ object: T ) {
        let key = String(describing: type(of: T.self))
        print(key)
        modelsStorage[key] = object
    }
    
    private func get<T>() -> T? {
        let key = String(describing: type(of: T.self))
        return (modelsStorage[key] as? T)
    }
}

extension Assembly {
    static var previewAssembly: Assembly {
        let assembly = Assembly()
        let ci = CardInfo(card: Card.testCard,
                          verificationState: nil,
						  artworkInfo: nil,
						  twinCardInfo: nil)
        let vm = assembly.makeCardModel(from: ci)!
        let scanResult = ScanResult.card(model: vm)
        assembly.cardsRepository.cards[Card.testCard.cardId!] = scanResult
        return assembly
    }
}
