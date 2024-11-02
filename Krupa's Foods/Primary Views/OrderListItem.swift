//
//  OrderListItem.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 11/2/24.
//

import SwiftUI
import SwiftData
import SwipeActions

struct OrderListItem: View {
    @Environment(\.modelContext) var modelContext
    
    var order: Order
    
    init(_ order: Order) {
        self.order = order
    }
    
    @State private var showDeleteConfirmation = false
    @State private var showOrderEditView = false
    
    var body: some View {
        SwipeView {
            HStack {
                Text(order.wrappedProduct.icon)
                    .font(.largeTitle)
                
                VStack(alignment: .leading) {
                    Text(order.wrappedCustomer.name)
                        .bold()
                    Text(order.wrappedCustomer.address.line1)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("^[\(order.quantity.formatted()) \(order.wrappedProduct.measurementUnit.rawValue.capitalized)](inflect: true)")
                    Text(order.amountPaid, format: .currency(code: "INR"))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(10)
            .background(.ultraThickMaterial, in: .rect(cornerRadius: 20, style: .continuous))
        } trailingActions: { context in
            SwipeAction("Edit", systemImage: "pencil") {
                context.state.wrappedValue = .closed
                showOrderEditView = true
            }
            
            SwipeAction("Delete", systemImage: "trash", backgroundColor: .red) {
                showDeleteConfirmation = true
            }
            .allowSwipeToTrigger()
            .foregroundStyle(.white)
            .confirmationDialog("Confirm Deletion", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(order)
                }
                
                Button("Cancel", role: .cancel) {
                    context.state.wrappedValue = .closed
                }
            } message: {
                Text("Are you sure you want to delete this order?")
            }
        }
        .swipeActionCornerRadius(20)
        .padding(.horizontal)
        .padding(.vertical, 2.5)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading).combined(with: .swipeDelete)))
        .sheet(isPresented: $showOrderEditView) {
            AddOrderView(order: order)
        }
    }
}
