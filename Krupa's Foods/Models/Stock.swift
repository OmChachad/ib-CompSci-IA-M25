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
    var quantityPurchased: Double
    var quantityLeft: Double
    var date: Date
    var product: Product
    var orders: [Order]
    
    init(id: UUID = UUID(), amountPaid: Double, quantityPurchased: Double, quantityLeft: Double, date: Date = Date.now, for product: Product) {
        self.id = id
        self.amountPaid = amountPaid
        self.quantityPurchased = quantityPurchased
        self.quantityLeft = quantityLeft
        self.date = date
        self.product = product
        self.orders = []
    }
    
    init(id: UUID = UUID(), amountPaid: Double, quantityPurchased: Double, date: Date = Date.now, for product: Product) {
        self.id = id
        self.amountPaid = amountPaid
        self.quantityPurchased = quantityPurchased
        self.quantityLeft = quantityPurchased
        self.date = date
        self.product = product
        self.orders = []
    }
}
