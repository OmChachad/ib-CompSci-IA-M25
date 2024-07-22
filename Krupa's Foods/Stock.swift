//
//  Stock.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 22/07/24.
//

import Foundation
import SwiftData

@Model
class Stock {
    var amountPaid: Double
    var quantityPurchased: Int
    var quantityLeft: Int
    var date: Date
    
    init(amountPaid: Double, quantityPurchased: Int, date: Date = Date.now) {
        self.amountPaid = amountPaid
        self.quantityPurchased = quantityPurchased
        self.quantityLeft = quantityPurchased
        self.date = date
    }
}
