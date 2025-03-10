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
    var id: UUID = UUID()
    var amountPaid: Double = 0.0
    var quantityPurchased: Double = 0.0
    var manuallyConsumedQuantity: Double = 0.0
    var date: Date = Date.now
    var product: Product?
    @Relationship(inverse: \Order.stock) var usedBy: [Order]? = []
    @Relationship(deleteRule: .nullify,inverse: \PendingStock.fulfilledBy) var fulfillingStock: [PendingStock]? = []
    
    /// Computed property that returns the product associated with the stock, or a default product if not found
    var wrappedProduct: Product {
        product ?? Product(name: "Unknown Product", icon: "❓", measurementUnit: .piece, isMadeToDelivery: false)
    }
    
    /// Computed property that returns the orders that have used this stock, or an empty array if not
    var wrappedUsedBy: [Order] {
        usedBy ?? []
    }
    
    /// Computed property that returns the average cost of the stock based on the total amount paid and quantity purchased.
    var averageCost: Double {
        if quantityPurchased == 0 {
            return 0
        } else {
            return amountPaid / quantityPurchased
        }
    }
    
    /// Computed property that returns the remaining quantity of the stock after accounting for sales or usage.
    var quantityLeft: Double {
        let subtractedQuantity = quantityPurchased
            - self.manuallyConsumedQuantity
            - self.wrappedUsedBy.reduce(0.0) { total, order in
                total + order.quantity
            }
            - (self.fulfillingStock?.filter { pendingStock in
                !self.wrappedUsedBy.contains { $0.persistentModelID == pendingStock.order?.persistentModelID }
            } ?? []).reduce(0.0) { total, pendingStock in
                total + pendingStock.quantityToBePurchased
            }

        
        if subtractedQuantity < 0 {
            return 0
        } else {
            return subtractedQuantity
        }
    }
    
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
        self.manuallyConsumedQuantity = quantityPurchased - quantityLeft
        self.date = date
        self.product = product
        self.usedBy = []
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
        self.manuallyConsumedQuantity = 0
        self.date = date
        self.product = product
        self.usedBy = []
    }
}

