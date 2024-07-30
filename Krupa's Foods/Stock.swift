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
    var id: UUID
    var amountPaid: Double
    var quantityPurchased: Int
    var quantityLeft: Int
    var date: Date
    var product: Product
    
    init(id: UUID = UUID(), amountPaid: Double, quantityPurchased: Int, date: Date = Date.now, for product: Product) {
        self.id = id
        self.amountPaid = amountPaid
        self.quantityPurchased = quantityPurchased
        self.quantityLeft = quantityPurchased
        self.date = date
        self.product = product
    }
}
