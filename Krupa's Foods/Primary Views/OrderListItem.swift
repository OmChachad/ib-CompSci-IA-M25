//
//  OrderListItem.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 11/2/24.
//

import SwiftUI
import SwiftData
import SwipeActions

/// A view that represents a single order in OrdersView
struct OrderListItem: View {
    @Environment(\.modelContext) var modelContext
    
    var order: Order
    
    /// A view that represents a single order in OrdersView
    /// - Parameters:
    ///   - order: Pass in a order to display its details
    ///   - namespace: Pass in the namespace of the parent view to enable a matched geometry effect animation.
    init(_ order: Order, namespace: Namespace.ID) {
        self.order = order
        self.namespace = namespace
        self._paymentStatus = State(initialValue: order.paymentStatus)
        self._deliveryStatus = State(initialValue: order.deliveryStatus)
    }
    
    @State private var showDeleteConfirmation = false
    @State private var showOrderEditView = false
    
    @State private var paymentStatus = Order.Status.pending
    @State private var deliveryStatus = Order.Status.pending
    @State private var showStatusChanger = false
    
    @State private var showBillView = false
    
    var namespace: Namespace.ID
    
    var body: some View {
        SwipeView {
            Button {
                // Tapping this view expands it to show more order details than visible at the surface.
                withAnimation(.bouncy) {
                    showStatusChanger.toggle()
                }
            } label: {
                VStack {
                    HStack {
                        // Shows the emoji icon associated with the product for which the order has been placed.
                        Text(order.wrappedProduct.icon)
                            .font(.largeTitle)
                        
                        // Basic customer details are shown on the left.
                        VStack(alignment: .leading) {
                            Text(order.wrappedCustomer.name)
                                .bold()
                            Text(order.wrappedCustomer.address.line1)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // If the order has any notes, a small icon is displayed to indicate that.
                        if !(order.notes ?? "").isEmpty {
                            Image(systemName: "text.alignright")
                                .foregroundStyle(.secondary)
                                .padding(.trailing, 5)
                        }
                        
                        // The order count and amount paid is shown on the right.
                        VStack(alignment: .leading) {
                            // Automatic Grammar inflection is used to pluralize the measurement unit.
                            Text("^[\(order.quantity.formatted()) \(order.wrappedProduct.measurementUnit.rawValue.capitalized)](inflect: true)")
                            Text(order.amountPaid, format: .currency(code: "INR"))
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 85, alignment: .leading)
                    }
                    .contentShape(Rectangle())
                    
                    // If the user has expanded the view, more details about the order are shown.
                    if showStatusChanger {
                        Group {
                            Divider()
                            
                            // Shows the payment method that the customer has chosen.
                            HStack {
                                Text("Payment Method:")
                                    .bold()
                                
                                Spacer()
                                
                                Text(order.paymentMethod.rawValue)
                            }
                            .padding([.top, .trailing], 5)
                            
                            Divider()
                            
                            // If order notes are not empty, they are displayed.
                            if let notes = order.notes, !notes.isEmpty {
                                Text("Notes:")
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 5)
                                
                                
                                Text(notes)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                            }
                            
                            // The payment and delivery statuses can be changed by the user.
                            LabeledContent("Payment Status") {
                                EnumPicker(title: "Payment Status", selection: $paymentStatus)
                            }
                            
                            LabeledContent("Delivery Status") {
                                EnumPicker(title: "Delivery Status", selection: $deliveryStatus)
                            }
                        }
                        .padding(.leading, 10)
                        .transition(.move(edge: .top).combined(with: .blurReplace))
                        .onAppear {
                            paymentStatus = order.paymentStatus
                            deliveryStatus = order.deliveryStatus
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThickMaterial)
                    .shadow(color: .black.opacity(showStatusChanger ? 0.15 : 0), radius: 5, x: 0, y: 0)
                    
            }
        } leadingActions: { context in
            // Leading Swipe action to generate an invoice/bill. Only available if the order has been paid for.
            if order.paymentStatus == .completed {
                SwipeAction("Bill", systemImage: "doc.text") {
                    showBillView = true
                }
            }
        } trailingActions: { context in
            // Trailing Swipe actions to edit or delete the order.
            
            // Edit Button
            SwipeAction("Edit", systemImage: "pencil") {
                context.state.wrappedValue = .closed
                showOrderEditView = true
            }
            
            // Delete Button
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
        .matchedGeometryEffect(id: order.id, in: namespace)
        .padding(.horizontal)
        .padding(.vertical, showStatusChanger ? 7.5 : 2.5)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading).combined(with: .swipeDelete)))
        .sheet(isPresented: $showOrderEditView) {
            // Passing an existing order to the AddOrderView allows for it to be edited.
            AddOrderView(order: order)
        }
        .sheet(isPresented: $showBillView) {
            BillView(order: order)
        }
        .onChange(of: paymentStatus) {
            withAnimation {
                self.order.paymentStatus = paymentStatus
            }
        }
        .onChange(of: deliveryStatus) {
            withAnimation {
                self.order.deliveryStatus = deliveryStatus
            }
        }
        .onChange(of: paymentStatus == .completed && deliveryStatus == .completed) {
            withAnimation(.bouncy) {
                showStatusChanger = false
            }
        }
    }
}
