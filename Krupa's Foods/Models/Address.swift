//
//  Address.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 22/07/24.
//

import Foundation

/// A struct representing a customer's address.
struct Address: Codable {
    var line1: String
    var line2: String
    var city: String
    var pincode: String
    
    /// Initializes a new `Address` instance.
    ///
    /// - Parameters:
    ///   - line1: The first line of the address (e.g., street name and number).
    ///   - line2: The second line of the address (e.g., apartment or suite number).
    ///   - city: The city where the address is located.
    ///   - pincode: The postal code or ZIP code of the address.
    init(line1: String, line2: String, city: String, pincode: String) {
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.pincode = pincode
    }
}
