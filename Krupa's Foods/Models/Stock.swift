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
    
    /// Initializes a new `Stock` instance with specified values for all properties.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the stock. Defaults to a new UUID if not provided.
    ///   - amountPaid: The total amount paid for the purchased stock.
    ///   - quantityPurchased: The total quantity of the product that was purchased.
    ///   - quantityLeft: The remaining quantity of the product in stock after sales or usage.
    ///   - date: The date the stock was purchased or recorded. Defaults to the current date if not provided.
    ///   - product: The `Product` this stock entry is associated with.
    ///
    /// This initializer allows you to specify all properties, including `quantityLeft` which may be different from `quantityPurchased` if some stock has already been used or sold.
    init(id: UUID = UUID(), amountPaid: Double, quantityPurchased: Double, quantityLeft: Double, date: Date = Date.now, for product: Product) {
        self.id = id
        self.amountPaid = amountPaid
        self.quantityPurchased = quantityPurchased
        self.quantityLeft = quantityLeft
        self.date = date
        self.product = product
        self.orders = []
    }
    
    /// Initializes a new `Stock` instance with `quantityLeft` automatically set to the value of `quantityPurchased`.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the stock. Defaults to a new UUID if not provided.
    ///   - amountPaid: The total amount paid for the purchased stock.
    ///   - quantityPurchased: The total quantity of the product that was purchased.
    ///   - date: The date the stock was purchased or recorded. Defaults to the current date if not provided.
    ///   - product: The `Product` this stock entry is associated with.
    ///
    /// This initializer automatically sets `quantityLeft` to the same value as `quantityPurchased`, assuming no stock has been used or sold at the time of initialization.
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

