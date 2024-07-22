//
//  Address.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 22/07/24.
//

import Foundation

struct Address: Codable {
    var line1: String
    var line2: String
    var city: String
    var pincode: Int
    
    init(line1: String, line2: String, city: String, pincode: Int) {
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.pincode = pincode
    }
}
