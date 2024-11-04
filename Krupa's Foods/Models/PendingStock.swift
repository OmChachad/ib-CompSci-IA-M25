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
    
    var wrappedProduct: Product {
        product ?? Product(name: "Unknown Product", icon: "❓", measurementUnit: .piece, isMadeToDelivery: false)
    }
    
    init(id: UUID = UUID(), quantityToBePurchased: Double, date: Date = Date.now, product: Product? = nil, order: Order? = nil) {
        self.id = id
        self.quantityToBePurchased = quantityToBePurchased
        self.date = date
        self.product = product
        self.order = order
    }
}
