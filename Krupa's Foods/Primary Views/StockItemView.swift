//
//  StockItemView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 03/09/24.
//

import SwiftUI
import SwipeActions

/// A view that represents an individual stock order in StockView
struct StockItemView: View {
    @Environment(\.modelContext) var modelContext
    var stockOrder: Stock
    
    /// Initialize the StockItemView with a stock order
    /// - Parameter stockOrder: The stock order which is to be displayed.
    init(_ stockOrder: Stock) {
        self.stockOrder = stockOrder
    }
    
    @State private var showDeleteConfirmation = false
    
    @State private var showingDetails = false
    
    /// The customer orders who have consumed stock from this stock order.
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
                        // Shows the quantity of stock left and the date of the stock order. Automatic grammar inflection is used to show the correct plural form of the measurement unit.
                        Text("^[\(stockOrder.quantityLeft.formatted())/\(stockOrder.quantityPurchased.formatted()) \(stockOrder.wrappedProduct.measurementUnit.title)](inflect: true) remaining")
                            .bold()
                        
                        // A secondary label showing the date of the stock order.
                        Text(stockOrder.date.formatted(date: .abbreviated, time: .omitted))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // The chevron indicates that this view can be expanded to show more details. Tapping it changes the chevron's rotation to 90 degrees to indicate that the view is expanded.
                    Image(systemName: "chevron.right")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(showingDetails ? 90 : 0))
                        .accessibilityHint("\(showingDetails ? "Hide" : "Show") Details for Stock Order on \(stockOrder.date.formatted())")
                }
                // Reduce opacity and add a strikethrough to the stock order if it has been fully consumed and the details are not being shown.
                .strikethrough(stockOrder.quantityLeft == 0 && !showingDetails)
                .opacity((stockOrder.quantityLeft == 0 && showingDetails) ? 0.6 : 1)
                
                // If the view is tapped, the further details are shown.
                if showingDetails {
                    Group {
                        Divider()
                        
                        // The exact amount that was paid for the stock order is shown with the INR symbol.
                        LabeledContent("Amount Paid", value: "\(INRFormatter.string(from: NSNumber(value: stockOrder.amountPaid)) ?? "")")
                        
                        // If the stock order has been tied to orders placed by customers, the customer and order details are shown here.
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
                // Tapping to reveal more details about the stock order.
                showingDetails.toggle()
            }
        } trailingActions: { context in
            // Trailing swipe action to delete the stock order.
            
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
