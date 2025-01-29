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
    var id: UUID = UUID()
    var orderNumber: Int?
    var product: Product?
    var customer: Customer?
    var paymentMethod: PaymentMethod = PaymentMethod.UPI
    var quantity: Double = 0.0
    var amountPaid: Double = 0.0
    var date: Date = Date.now
    var paymentStatus: Status = Status.pending
    var deliveryStatus: Status = Status.pending
    var notes: String?
    var stock: [Stock]? = []
    @Relationship(deleteRule: .cascade, inverse: \PendingStock.order) var pendingStock: PendingStock?
    
    var wrappedStock: [Stock] {
        stock ?? []
    }
    
    var wrappedProduct: Product {
        product ?? Product(name: "Unknown Product", icon: "❓", measurementUnit: .piece, isMadeToDelivery: false)
    }
    
    var wrappedCustomer: Customer {
        customer ?? Customer(name: "Unknown Customer", phoneNumber: "Unknown Phone Number", address: Address())
    }
    
    /// A computed property that returns `true` if either the delivery or payment status is pending.
    var isPending: Bool {
        self.deliveryStatus == .pending || self.paymentStatus == .pending
    }
    
    /// A computed property that returns `true` if both the delivery and payment statuses are completed.
    var isCompleted: Bool {
        self.deliveryStatus == .completed && self.paymentStatus == .completed
    }

    var totalCost: Double {
        if let stock {
            return stock.reduce(0.0) { $0 + ($1.averageCost*($1.wrappedUsedBy.first{ $0 == self }?.quantity ?? 0))}
        } else {
            return 0
        }
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
    init(id: UUID = UUID(), orderNumber: Int, for product: Product, customer: Customer,
        paymentMethod: PaymentMethod, quantity: Double, stock: [Stock],
        amountPaid: Double, date: Date = .now,
         paymentStatus: Status, deliveryStatus: Status, notes: String?) {
        self.orderNumber = orderNumber
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
        self.notes = notes
    }
}

