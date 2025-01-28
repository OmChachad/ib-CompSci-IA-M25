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
                withAnimation(.bouncy) {
                    showStatusChanger.toggle()
                }
            } label: {
                VStack {
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
                    .contentShape(Rectangle())
                    
                    if showStatusChanger {
                        Group {
                            Divider()
                            
                            LabeledContent("Payment Status") {
                                EnumPicker(title: "Payment Status", selection: $paymentStatus)
                            }
                            .padding(.leading, 10)
                            
                            LabeledContent("Delivery Status") {
                                EnumPicker(title: "Delivery Status", selection: $deliveryStatus)
                            }
                            .padding(.leading, 10)
                        }
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
            .background(.ultraThickMaterial, in: .rect(cornerRadius: 20, style: .continuous))
        } leadingActions: { context in
            if order.paymentStatus == .completed {
                SwipeAction("Bill", systemImage: "doc.text") {
                    showBillView = true
                }
            }
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
        .matchedGeometryEffect(id: order.id, in: namespace)
        .shadow(color: .black.opacity(showStatusChanger ? 0.15 : 0), radius: 5, x: 0, y: 0)
        .padding(.horizontal)
        .padding(.vertical, showStatusChanger ? 7.5 : 2.5)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading).combined(with: .swipeDelete)))
        .sheet(isPresented: $showOrderEditView) {
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

struct OrderStatusSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var order: Order
    @State private var paymentMethod: Order.PaymentMethod = .UPI
    @State private var paymentStatus = Order.Status.pending
    @State private var deliveryStatus = Order.Status.pending
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Payment Method") {
                    EnumPicker(title: "Payment Method", selection: $paymentMethod)
                }
                Section("Payment Status") {
                    EnumPicker(title: "Payment Status", selection: $paymentStatus)
                }
                
                Section("Delivery Status") {
                    EnumPicker(title: "Delivery Status", selection: $deliveryStatus)
                }
            }
            .pickerStyle(.segmented)
            .navigationTitle("\(order.customer?.name ?? "Unknown")'s Order")
            .toolbar {
                Button("Done", action: dismiss.callAsFunction)
            }
            
        }
    }
}
