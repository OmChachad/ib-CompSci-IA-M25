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
    var name: String
    var icon: String
    var measurementUnit: Unit
    var orders: [Order]
    var stock: [Stock]
    var isMadeToDelivery: Bool
    
    enum Unit: String, CaseIterable, Codable {
        case kg, g, dozen, box, piece
    }
    
    init(name: String, icon: String, measurementUnit: Unit, orders: [Order], stock: [Stock], isMadeToDelivery: Bool) {
        self.name = name
        self.icon = icon
        self.measurementUnit = measurementUnit
        self.orders = orders
        self.stock = stock
        self.isMadeToDelivery = isMadeToDelivery
    }
}
