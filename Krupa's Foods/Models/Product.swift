//
//  Product.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 16/07/24.
//

import Foundation
import SwiftData

@Model
class Product {
    var id: UUID = UUID()
    var name: String = ""
    var icon: String = ""
    var measurementUnit: Unit = Unit.piece
    @Relationship(inverse: \Order.product) var orders: [Order]? = []
    @Relationship(inverse: \Stock.product) var stock: [Stock]? = []
    @Relationship(inverse: \PendingStock.product) var pendingStock: [PendingStock]? = []
    var isMadeToDelivery: Bool = false
    var stepAmount: Double = 1.0
    
    var wrappedOrders: [Order] {
        orders ?? []
    }
    
    var wrappedStock: [Stock] {
        stock ?? []
    }
    /// A computed property that returns the total available stock by summing the quantity left in each stock entry.
    var availableStock: Double {
        return wrappedStock.reduce(0.0) { totalStock, item in
            totalStock + item.quantityLeft
        }
    }
    
    /// Enum representing the unit of measurement for the product.
    enum Unit: String, CaseIterable, Codable {
        case kg, g, dozen, box, piece
        
        /// A computed property that returns a display-friendly title for the unit.
        var title: String {
            switch(self) {
            case .kg, .g:
                return self.rawValue
            default:
                return self.rawValue.capitalized
            }
        }
    }

    /// Initializes a new `Product` instance.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the product. Defaults to a new UUID if not provided.
    ///   - name: The name of the product.
    ///   - icon: The icon or image representation of the product.
    ///   - measurementUnit: The unit of measurement used for this product (e.g., kg, dozen, piece).
    ///   - stepAmount: The step amount to adjust product quantities, with a default of 1.0.
    ///   - orders: The list of `Order` objects related to this product. Defaults to an empty array.
    ///   - stock: The list of `Stock` entries for this product. Defaults to an empty array.
    ///   - isMadeToDelivery: A Boolean flag indicating if the product is made specifically for delivery.
    init(id: UUID = UUID(), name: String, icon: String, measurementUnit: Unit,
         stepAmount: Double = 1.0, orders: [Order] = [], stock: [Stock] = [],
         isMadeToDelivery: Bool) {
        self.id = id
        self.name = name
        self.icon = icon
        self.measurementUnit = measurementUnit
        self.stepAmount = stepAmount
        self.orders = orders
        self.stock = stock
        self.isMadeToDelivery = isMadeToDelivery
    }
}
