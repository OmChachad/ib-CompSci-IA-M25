//
//  INRFormatter.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 14/08/24.
//
import SwiftUI

/// A number formatter that formats numbers as Indian Rupees.
var INRFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "INR"
    formatter.maximumFractionDigits = 0
    formatter.locale = Locale(identifier: "en_IN")
    return formatter
}
