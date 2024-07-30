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
    var id: UUID
    var name: String
    var icon: String
    var measurementUnit: Unit
    @Relationship(inverse: \Order.product) var orders: [Order]
    @Relationship(inverse: \Stock.product) var stock: [Stock]
    var isMadeToDelivery: Bool
    
    enum Unit: String, CaseIterable, Codable {
        case kg, g, dozen, box, piece
    }

    init(id: UUID = UUID(), name: String, icon: String, measurementUnit: Unit, orders: [Order], stock: [Stock], isMadeToDelivery: Bool) {
        self.id = id
        self.name = name
        self.icon = icon
        self.measurementUnit = measurementUnit
        self.orders = orders
        self.stock = stock
        self.isMadeToDelivery = isMadeToDelivery
    }
}
