//
//  StockItemView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 03/09/24.
//

import SwiftUI

struct StockItemView: View {
    var stockOrder: Stock
    
    init(_ stockOrder: Stock) {
        self.stockOrder = stockOrder
    }
    
    var body: some View {
        HStack {
            Image(systemName: "shippingbox.fill")
                .foregroundStyle(.yellow.gradient)
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text("^[\(stockOrder.quantityLeft.formatted())/\(stockOrder.quantityPurchased.formatted()) \(stockOrder.product.measurementUnit.title)](inflect: true) remaining")
                    .bold()
                Text(stockOrder.date.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(INRFormatter.string(from: NSNumber(value: stockOrder.amountPaid)) ?? "")
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(.ultraThickMaterial, in: .rect(cornerRadius: 20, style: .continuous))
        .strikethrough(stockOrder.quantityLeft == 0)
        .opacity(stockOrder.quantityLeft == 0 ? 0.6 : 1)
    }
}
