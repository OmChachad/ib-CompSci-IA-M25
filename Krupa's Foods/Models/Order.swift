//
//  Order.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 22/07/24.
//

import SwiftData
import Foundation

@Model
class Order {
    var id: UUID
    var product: Product
    @Relationship(inverse: \Customer.orderHistory) var customer: Customer?
    var paymentMethod: PaymentMethod
    var quantity: Double
    var amountPaid: Double
    var date: Date
    var paymentStatus: Status
    var deliveryStatus: Status
    var stock: [Stock]
    
    var isPending: Bool {
        self.deliveryStatus == .pending || self.paymentStatus == .pending
    }
    
    var isCompleted: Bool {
        self.deliveryStatus == .completed && self.deliveryStatus == .completed
    }
    
    enum Status: String, CaseIterable, Codable {
        case pending = "Pending"
        case completed = "Completed"
    }
    
    enum PaymentMethod: String, CaseIterable, Codable {
        case cash = "Cash"
        case UPI = "UPI"
        case other = "Other"
    }
    
    init(id: UUID = UUID(), for product: Product, customer: Customer, paymentMethod: PaymentMethod, quantity: Double, stock: [Stock], amountPaid: Double, date: Date = .now, paymentStatus: Status, deliveryStatus: Status) {
        self.id = id
        self.product = product
        self.customer = customer
        self.paymentMethod = paymentMethod
        self.quantity = quantity
        self.amountPaid = amountPaid
        self.date = date
        self.paymentStatus = paymentStatus
        self.deliveryStatus = deliveryStatus
        self.stock = stock
    }
}
