//
//  Customer.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 22/07/24.
//

import Foundation
import SwiftData

@Model
class Customer: Hashable {
    var id: UUID
    var name: String
    var phoneNumber: String
    var address: Address
    var orderHistory: [Order]
    
    /// Initializes a new `Customer` instance.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the customer. Defaults to a new UUID if not provided.
    ///   - name: The name of the customer.
    ///   - phoneNumber: The customer's contact phone number.
    ///   - address: The `Address` where the customer resides or is located.
    ///   - orderHistory: A list of `Order` objects representing the customer's previous orders. Defaults to an empty array.
    init(id: UUID = UUID(), name: String, phoneNumber: String, address: Address, orderHistory: [Order] = []) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.address = address
        self.orderHistory = orderHistory
    }
}

