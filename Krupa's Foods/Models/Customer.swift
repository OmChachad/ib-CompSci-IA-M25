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
    
    init(id: UUID = UUID(), name: String, phoneNumber: String, address: Address, orderHistory: [Order] = []) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.address = address
        self.orderHistory = orderHistory
    }
}
