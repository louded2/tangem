//
//  ViewController.swift
//  TangemSDKExample
//
//  Created by Alexander Osokin on 10/10/2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import UIKit
import TangemSdk

class ViewController: UIViewController {
    @IBOutlet weak var logView: UITextView!
    
    var cardManager: CardManager = CardManager()
    
    var card: Card?
    
    @IBAction func scanCardTapped(_ sender: Any) {
        cardManager.scanCard {[unowned self] taskEvent in
            switch taskEvent {
            case .event(let scanEvent):
                switch scanEvent {
                case .onRead(let card):
                    self.card = card
                    self.logView.text = ""
                    self.log("read result: \(card)")
                case .onVerify(let isGenuine):
                    self.log("verify result: \(isGenuine)")
                }
            case .completion(let error):
                if let error = error {
                    if case .userCancelled = error {
                        //silence user cancelled
                    } else {
                        self.log("completed with error: \(error.localizedDescription)")
                    }
                }
                //handle completion. Unlock UI, etc.
            }
        }
    }
    
    @IBAction func signHashesTapped(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let hash1 = Data(repeating: 1, count: 32) //dummy hashes
            let hash2 = Data(repeating: 2, count: 32)
            let hashes = [hash1, hash2]
            guard let cardId = card?.cardId else {
                self.log("Please, scan card before")
                return
            }
            
            cardManager.sign(hashes: hashes, cardId: cardId) { taskEvent  in
                switch taskEvent {
                case .event(let signResponse):
                    self.log(signResponse)
                case .completion(let error):
                    if let error = error {
                        if case .userCancelled = error {
                            //silence user cancelled
                        } else {
                            self.log("completed with error: \(error.localizedDescription)")
                        }
                    }
                    //handle completion. Unlock UI, etc.
                }
            }
        } else {
            // Fallback on earlier versions
            self.log("Only iOS 13+")
        }
    }
    @IBAction func getIssuerDataTapped(_ sender: Any) {
        guard let cardId = card?.cardId else {
            self.log("Please, scan card before")
            return
        }
        
        if #available(iOS 13.0, *) {
            let getIssuerDataCommand = GetIssuerDataCommand(cardId: cardId)
            cardManager.runCommand(getIssuerDataCommand) { taskEvent in
                switch taskEvent {
                case .event(let issuerDataResponse):
                    self.log(issuerDataResponse)
                case .completion(let error):
                    if let error = error {
                        if case .userCancelled = error {
                            //silence user cancelled
                        } else {
                            self.log("completed with error: \(error.localizedDescription)")
                        }
                    }
                    //handle completion. Unlock UI, etc.
                }
            }
        } else {
            // Fallback on earlier versions
            self.log("Only iOS 13+")
        }
    }
    
    @IBAction func writeIssuerDataTapped(_ sender: Any) {
        
    }
    
    private func log(_ object: Any) {
        self.logView.text = self.logView.text.appending("\(object)\n")
        print(object)
    }
}
