//
//  PendingStock.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 11/4/24.
//

import Foundation
import SwiftData


@Model
class PendingStock: Identifiable {
    var id: UUID = UUID()
    var quantityToBePurchased: Double = 0.0
    var date: Date = Date.now
    var product: Product?
    var order: Order?
    var fulfilledBy: Stock?
    
    /// Computed property that returns the product associated with the pending stock, or a default product if not
    var wrappedProduct: Product {
        product ?? Product(name: "Unknown Product", icon: "❓", measurementUnit: .piece, isMadeToDelivery: false)
    }
    
    /// 
    /// - Parameters:
    ///   - id: A unique identifier for the backorder. Defaults to a new UUID if not provided.
    ///   - quantityToBePurchased: The quantity of the product that needs to be purchased.
    ///   - date: The date when the backorder was created. Defaults to the current date and time.
    ///   - product: The product for which the backorder is placed.
    ///   - order: The order for which the backorder is placed.
    init(id: UUID = UUID(), quantityToBePurchased: Double, date: Date = Date.now, product: Product? = nil, order: Order? = nil) {
        self.id = id
        self.quantityToBePurchased = quantityToBePurchased
        self.date = date
        self.product = product
        self.order = order
    }
}
