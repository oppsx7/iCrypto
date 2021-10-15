//
//  CoinData.swift
//  CryptoTracker
//
//  Created by Todor Dimitrov on 20.09.21.
//

import Foundation
import Alamofire
import UIKit

class CoinData {
    static let shared = CoinData()
    var coins = [Coin]()
    weak var delegate: CoinDataDelegate?
    private init() {
        let symbols = ["BTC", "ETH", "LTC"]
        
        for symbol in symbols {
            let coin = Coin(symbol: symbol)
            coins.append(coin)
        }
    }
    
    func html() -> String {
        var html = "<h1>My Crypto Report</h1>"
        html += "<h2>Net Worth: \(netWorthAsString())</h2>"
        html += "<ul>"
        coins.forEach { coin in
            if coin.amount != 0 {
                html += "<li>\(coin.symbol) - I own: \(coin.amount) - Valued at: \(coin.amount * coin.price)</li>"
            }
        }
        html += "</ul>"
        
        return html
    }
    
    func netWorthAsString() -> String {
        var netWorth: Double = 0
        coins.forEach { coin in
            netWorth += coin.amount * coin.price
        }
        
        return doubleToMoneyString(double: netWorth)
    }
    
    func getPrices() {
        var listOfSymbols = ""
        coins.forEach { coin in
            listOfSymbols.append(coin.symbol)
            if coin.symbol != coins.last?.symbol {
                listOfSymbols.append(",")
            }
        }
        
        Alamofire.request("https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(listOfSymbols)&tsyms=EUR").responseJSON { (response) in
            
            if let json = response.result.value as? [String: Any] {
                for coin in self.coins {
                    if let coinJSON = json[coin.symbol] as? [String: Double],
                       let price = coinJSON["EUR"] {
                        coin.price = price
                        UserDefaults.standard.set(price, forKey: coin.symbol)
                        
                    }
                }
                self.delegate?.newPrices?()
            }
        }
    }
    
    func doubleToMoneyString(double: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "el_GR")
        formatter.numberStyle = .currency
        if let fancyPrice = formatter.string(from: NSNumber(floatLiteral: double)) {
            return fancyPrice
        } else {
            return "ERROR"
        }
    }
    
}

@objc protocol CoinDataDelegate: AnyObject {
    @objc optional func newPrices()
    @objc optional func newHistory()
}

class Coin {
    var symbol = ""
    var image = UIImage()
    var price = 0.0
    var amount = 0.0
    var historicalData = [Double]()
    
    init(symbol: String) {
        self.symbol = symbol
        if let image = UIImage(named: symbol) {
            self.image = image
        }
        self.price = UserDefaults.standard.double(forKey: symbol)
        self.amount = UserDefaults.standard.double(forKey: symbol + "amount")
        if let history = UserDefaults.standard.array(forKey: symbol + "history") as? [Double] {
            self.historicalData = history
        }
    }
    
    func getHistoricalData() {
        Alamofire.request("https://min-api.cryptocompare.com/data/v2/histoday?fsym=\(symbol)&tsym=EUR&limit=30").responseJSON { response in
            if let json = response.result.value as? [String: Any],
               let pricesJSON = json["Data"] as? [String: Any],
               let pricesJSON2 = pricesJSON["Data"] as? [[String: Any]] {
                self.historicalData = []
                pricesJSON2.forEach { priceJSON in
                    if let closePrice = priceJSON["close"] as? Double {
                        self.historicalData.append(closePrice)
                    }
                }
                CoinData.shared.delegate?.newHistory?()
                UserDefaults.standard.set(self.historicalData, forKey: self.symbol + "history")
            }
        }
    }
    
    func priceAsString() -> String {
        if price == 0.0 {
            return "Loading..."
        }
        
       return CoinData.shared.doubleToMoneyString(double: price)
    }
    
    func amountAsString() -> String {
        return CoinData.shared.doubleToMoneyString(double: amount * price)
    }
    
}
