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
    
    /// A computed property that returns `true` if either the delivery or payment status is pending.
    var isPending: Bool {
        self.deliveryStatus == .pending || self.paymentStatus == .pending
    }
    
    /// A computed property that returns `true` if both the delivery and payment statuses are completed.
    var isCompleted: Bool {
        self.deliveryStatus == .completed && self.deliveryStatus == .completed
    }
    
    /// Represents the status of an order or payment, either pending or completed.
    enum Status: String, CaseIterable, Codable {
        case pending = "Pending"
        case completed = "Completed"
    }
    
    /// Enum to represent the various payment methods for an order.
    enum PaymentMethod: String, CaseIterable, Codable {
        case cash = "Cash"
        case UPI = "UPI"
        case other = "Other"
    }
    
    /// Initializes a new `Order` instance.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the order. Defaults to a new UUID if not provided.
    ///   - product: The `Product` associated with the order.
    ///   - customer: The `Customer` who placed the order. This is an optional value.
    ///   - paymentMethod: The method of payment used for the order (e.g., Cash, UPI).
    ///   - quantity: The quantity of the product ordered.
    ///   - stock: The list of `Stock` entries related to this order.
    ///   - amountPaid: The total amount paid for the order.
    ///   - date: The date the order was placed. Defaults to the current date if not provided.
    ///   - paymentStatus: The current status of the payment (either pending or completed).
    ///   - deliveryStatus: The current status of the delivery (either pending or completed).
    init(id: UUID = UUID(), for product: Product, customer: Customer,
        paymentMethod: PaymentMethod, quantity: Double, stock: [Stock],
        amountPaid: Double, date: Date = .now,
        paymentStatus: Status, deliveryStatus: Status) {
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

