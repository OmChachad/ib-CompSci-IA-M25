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
    
    @State private var showingDetails = false
    
    var associatedOrders: [Order] {
        if let fulfilledStock = stockOrder.fulfillingStock {
            return stockOrder.wrappedUsedBy + fulfilledStock.filter { !stockOrder.wrappedUsedBy.contains($0.order!) }.compactMap { $0.order }
        } else {
            return stockOrder.wrappedUsedBy
        }
    }
    
    var body: some View {
        SwipeView {
            VStack(alignment: .leading) {
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
                    
                    Image(systemName: "chevron.right")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(showingDetails ? 90 : 0))
                        .accessibilityHint("\(showingDetails ? "Hide" : "Show") Details for Stock Order on \(stockOrder.date.formatted())")
                }
                .strikethrough(stockOrder.quantityLeft == 0 && !showingDetails)
                .opacity((stockOrder.quantityLeft == 0 && showingDetails) ? 0.6 : 1)
                
                if showingDetails {
                    Group {
                        Divider()
                        
                        LabeledContent("Amount Paid", value: "\(INRFormatter.string(from: NSNumber(value: stockOrder.amountPaid)) ?? "")")
                        
                        if !stockOrder.wrappedUsedBy.isEmpty {
                            Divider()
                            
                            Text("Associated Orders:")
                                .bold()
                                .font(.title3)
                            
                            ForEach(stockOrder.wrappedUsedBy) { order in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(order.wrappedCustomer.name)
                                            .bold()
                                        Text(order.amountPaid, format: .currency(code: "INR"))
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(order.quantity.formatted())")
                                }
                            }
                            .padding(5)
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .blurReplace))
                }
            }
            .padding(10)
            .background(.ultraThickMaterial, in: .rect(cornerRadius: 20, style: .continuous))
            .clipped()
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading).combined(with: .swipeDelete)))
            .onTapGesture {
                showingDetails.toggle()
            }
        } trailingActions: { context in
            SwipeAction("Delete", systemImage: "trash", backgroundColor: .red) {
                showingDetails = false
                showDeleteConfirmation = true
            }
            .allowSwipeToTrigger()
            .confirmationDialog("Confirm Deletion", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(stockOrder)
                }
                
                Button("Cancel", role: .cancel) {
                    showingDetails = false
                    context.state.wrappedValue = .closed
                }
            } message: {
                Text("Are you sure you want to delete this stock order?")
            }
        }
        .swipeActionCornerRadius(20)
        .animation(.bouncy, value: showingDetails)
    }
}
