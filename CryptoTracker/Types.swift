//
//  Types.swift
//  CryptoTracker
//
//  Created by Todor Dimitrov on 14.10.21.
//

import Foundation

class HistoryResponse: Codable {
    let time: Double?
    let high: Double?
    let low: Double?
    let open: Double?
    let volumefrom: Double?
    let volumeto: Double?
    let close: Double?
    let conversionType: String?
    let conversionSymbol: String?
}
