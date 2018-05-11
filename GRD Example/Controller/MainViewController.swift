//
//  MainViewController.swift
//  GRD Example
//
//  Created by Kien Vuong on 5/11/18.
//  Copyright © 2018 GameReward. All rights reserved.
//

import UIKit
import GameReward_SDK

class MainViewController: UIViewController {
    
    @IBOutlet weak var imvQrCode: UIImageView!
    @IBOutlet weak var txtAddress: UILabel!
    @IBOutlet weak var txtBalance: UILabel!
    
    @IBOutlet weak var inputBetAmount: UITextField!
    
    @IBOutlet weak var cardView: UIImageView!
    @IBOutlet weak var hiddenCard: UIImageView!
    @IBOutlet weak var txtMessage: UILabel!
    
    private var randomCard : Card = Card()
    private var resultCard : Card = Card()
    private var cards : [String:URL] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtAddress.text = GameReward.User.address
        txtBalance.text = GameReward.User.balance.description
        loadQrCode()
        loadGame()
        randomNextCard()
    }

    private func loadQrCode(){
        imvQrCode.image = GameReward.GetAddressQrCode(address: GameReward.User.address)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OnChangeCard(_ sender: UIButton) {
        randomNextCard()
    }
    
    @IBAction func PlayLow(_ sender: UIButton) {
        Bet(isLow: true)
    }
    
    @IBAction func PlayHigh(_ sender: Any) {
        Bet(isLow: false)
    }
    
    private func Bet(isLow: Bool) -> Void{
        txtMessage.text = " "
        hideCard(imageView: hiddenCard)
        let option = isLow ? 1 : 0
        let cardSymbol : Int = randomCard.symbol
        let bet = Double(inputBetAmount.text!)!
        var pars : [String:Any] = [:]
        pars["low"] = option
        pars["cardSymbol"] = cardSymbol
        pars["bet"] = bet
        GameReward.CallServerScript(scriptName: "testscript", functionName: "lowhighgame", parameters: pars){ (error,message,results) in
            DispatchQueue.main.async{
                if error == 0
                {
                    let result : Int = results[0] as! Int
                    if result == 0
                    {
                            var card : [String:Any] = results[1] as! [String:Any]
                            self.resultCard.symbol = card["symbol"] as! Int
                            self.resultCard.suit = card["suit"] as! Int
                            self.showCard(imageView: self.hiddenCard, card: self.resultCard)
                            let money : Double = Double((results[2] as? String)!)!
                            let user : GrdUser  = GameReward.User
                            user.balance = user.balance + Decimal(money)
                            self.txtBalance.text = user.balance.description
                            if money > 0 {
                                self.txtMessage.text = "CONGRATULATIONS! YOU WIN:" + String(money)
                            }else if money < 0 {
                                self.txtMessage.text = "NOT LUCKY YET! LOSE:" + String(money)
                            }else{
                                self.txtMessage.text = "DRAW"
                            }
                    }else{
                        self.txtMessage.text = results[1] as? String
                    }
                }else{
                    self.txtMessage.text = "Error:"+String(error)+",message:"+message
                }
            }
        }
    }
    
    private func randomNextCard() -> Void{
        randomCard.suit = Int(arc4random_uniform(4))
        randomCard.symbol = Int(arc4random_uniform(12)+2);
        showCard(imageView: cardView, card: randomCard)
        hideCard(imageView: hiddenCard)
        
    }
    
    let suits : [String] = ["hearts", "diamonds", "spades", "clubs"]
    
    private func showCard(imageView: UIImageView , card: Card ){
        do{
            imageView.image = UIImage(data: try Data(contentsOf: cards[String(card.symbol) + "_of_" + suits[card.suit]]!))
        }catch{
            print("Show card error")
        }
    }
    
    private func hideCard(imageView: UIImageView ){
        do{
            imageView.image = UIImage(data: try Data(contentsOf: cards["cardback"]!))
        }catch{
            print("Hide card error")
        }
    }
    
    private func loadGame(){
        
        if let path = Bundle.main.resourcePath {
            let imagePath = path + "/cards"
            let url = NSURL(fileURLWithPath: imagePath)
            let fileManager = FileManager.default
            
            do {
                let imageURLs = try fileManager.contentsOfDirectory(at: url as URL, includingPropertiesForKeys: nil, options:FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                for image in imageURLs {
                    let name = image.deletingPathExtension().lastPathComponent
                    cards[name] = image
                }
                
            } catch let error1 as NSError {
                print(error1.description)
            }
        }
        
       
    }
}

public class Card {
    public var suit : Int = 0
    public var symbol: Int = 0
}
