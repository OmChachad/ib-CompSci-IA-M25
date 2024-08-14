//
//  INRFormatter.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 14/08/24.
//
import SwiftUI

var INRFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "INR"
    formatter.maximumFractionDigits = 2
    formatter.locale = Locale(identifier: "en_IN")
    return formatter
}
