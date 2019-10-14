//
//  CardEnvironment.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 02/10/2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation

//All encryption modes
public enum EncryptionMode: Byte {
    case none = 0x0
    case fast = 0x1
    case strong = 0x2
}

public struct KeyPair: Equatable {
    let privateKey: Data
    let publicKey: Data
}

public struct CardEnvironment: Equatable {
    static let defaultPin1 = "000000"
    static let defaultPin2 = "000"
    
    var pin1: String = CardEnvironment.defaultPin1
    var pin2: String = CardEnvironment.defaultPin2
    var terminalKeys: KeyPair? = nil
    var encryptionKey: Data? = nil
}

public protocol DataStorage {
    func object(forKey: String) -> Any?
    func set(_ value: Any, forKey: String)
}

enum DataStorageKey: String {
    case terminalPrivateKey
    case terminalPublicKey
    case pin1
    case pin2
}

public final class DefaultDataStorage: DataStorage {
    public func object(forKey: String) -> Any? {
        //TODO: implement
        return nil
    }
    
    public func set(_ value: Any, forKey: String) {
        //TODO: implement
    }
    
    public init() {
    }
}

final class CardEnvironmentRepository {
    var cardEnvironment: CardEnvironment {
        didSet {
            if cardEnvironment != oldValue {
                save(cardEnvironment)
            }
        }
    }
    
    private let dataStorage: DataStorage?
    
    init(dataStorage: DataStorage?) {
        self.dataStorage = dataStorage
        
        var environment = CardEnvironment()
        if let storage = dataStorage {
            if let pin1 = storage.object(forKey: DataStorageKey.pin1.rawValue) as? String {
                environment.pin1 = pin1
            }
            
            if let pin2 = storage.object(forKey: DataStorageKey.pin2.rawValue) as? String {
                environment.pin2 = pin2
            }
            
            if let terminalPrivateKey = storage.object(forKey: DataStorageKey.terminalPrivateKey.rawValue) as? Data,
                let terminalPublicKey = storage.object(forKey: DataStorageKey.terminalPublicKey.rawValue) as? Data {
                let keyPair = KeyPair(privateKey: terminalPrivateKey, publicKey: terminalPublicKey)
                environment.terminalKeys = keyPair
            }
        }
        
        self.cardEnvironment = environment
    }
    
    private func save(_ cardEnvironment: CardEnvironment) {
        //TODO: save cardEnvironment
    }
}
