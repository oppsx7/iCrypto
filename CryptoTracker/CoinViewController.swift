//
//  CoinViewController.swift
//  CryptoTracker
//
//  Created by Todor Dimitrov on 14.10.21.
//

import UIKit
import SwiftChart

private let chartHeight: CGFloat = 300
private let imageSize: CGFloat = 100
private let priceLabelHeight: CGFloat = 25

class CoinViewController: UIViewController, CoinDataDelegate {
    
    var chart = Chart()
    var coin: Coin?
    var priceLabel = UILabel()
    var youOwnLabel = UILabel()
    var worthLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coin = coin {
            CoinData.shared.delegate = self
            edgesForExtendedLayout = []
            view.backgroundColor = .white
            title = coin.symbol
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
            chart.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: chartHeight)
            chart.yLabelsFormatter = { CoinData.shared.doubleToMoneyString(double: $1)}
            chart.xLabels = [0, 5, 10, 15, 20, 25, 30]
            chart.xLabelsFormatter = { "\(Int(30 - $1))d" }
            view.addSubview(chart)
            
            let imageView = UIImageView(frame: CGRect(x: view.center.x - imageSize / 2, y: chartHeight, width: imageSize, height: imageSize))
            imageView.image = coin.image
            view.addSubview(imageView)
            
            priceLabel.frame = CGRect(x: 0, y: chartHeight + imageSize, width: view.frame.width, height: priceLabelHeight)
            priceLabel.textAlignment = .center
            view.addSubview(priceLabel)
            
            youOwnLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelHeight * 2, width: view.frame.width, height: priceLabelHeight)
            youOwnLabel.textAlignment = .center
            youOwnLabel.font = UIFont.boldSystemFont(ofSize: 20)
            view.addSubview(youOwnLabel)
            
            worthLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelHeight * 3, width: view.frame.width, height: priceLabelHeight)
            worthLabel.textAlignment = .center
            worthLabel.font = UIFont.boldSystemFont(ofSize: 20)
            view.addSubview(worthLabel)
            
            coin.getHistoricalData()
            newPrices()
        }
        
    }
    
    @objc func editTapped() {
        if let coin = coin {
            let alert = UIAlertController(title: "How much \(coin.symbol) do you own?", message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "0.5"
                textField.keyboardType = .decimalPad
                if self.coin?.amount != 0.0 {
                    textField.text = String(coin.amount)
                }
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                if let text = alert.textFields?[0].text,
                    let amount = Double(text) {
                    self.coin?.amount = amount
                    UserDefaults.standard.set(amount, forKey: coin.symbol + "amount")
                    self.newPrices()
                }
            }))
            
            self.present(alert, animated: true)
        }
    }
    
    func newHistory() {
        if let coin = coin {
            let series = ChartSeries(coin.historicalData)
            series.area = true
            chart.add(series)
        }
    }
    
    func newPrices() {
        if let coin = coin {
            priceLabel.text = coin.priceAsString()
            worthLabel.text = coin.amountAsString()
            youOwnLabel.text = "You own: \(coin.amount) \(coin.symbol)"
        }
    }
    
    
}
