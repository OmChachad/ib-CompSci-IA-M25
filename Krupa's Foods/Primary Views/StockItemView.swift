//
//  StockItemView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 03/09/24.
//

import SwiftUI
import SwipeActions

struct StockItemView: View {
    @Environment(\.modelContext) var modelContext
    var stockOrder: Stock
    
    init(_ stockOrder: Stock) {
        self.stockOrder = stockOrder
    }
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        SwipeView {
            HStack {
                Image(systemName: "shippingbox.fill")
                    .foregroundStyle(.yellow.gradient)
                    .font(.largeTitle)
                
                VStack(alignment: .leading) {
                    Text("^[\(stockOrder.quantityLeft.formatted())/\(stockOrder.quantityPurchased.formatted()) \(stockOrder.wrappedProduct.measurementUnit.title)](inflect: true) remaining")
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
        } trailingActions: { context in
            SwipeAction("Delete", systemImage: "trash", backgroundColor: .red) {
                showDeleteConfirmation = true
            }
            .allowSwipeToTrigger()
            .confirmationDialog("Confirm Deletion", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(stockOrder)
                }
                
                Button("Cancel", role: .cancel) {
                    context.state.wrappedValue = .closed
                }
            } message: {
                Text("Are you sure you want to delete this stock order?")
            }
        }
        .swipeActionCornerRadius(20)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading).combined(with: .swipeDelete)))
    }
}
