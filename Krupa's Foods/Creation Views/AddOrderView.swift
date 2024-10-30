//
//  AddOrderView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 30/07/24.
//

import SwiftUI
import SwiftData

struct AddOrderView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Query var customers: [Customer]
    @Query var stock: [Stock]
    
    @State private var customer: Customer?
    @State private var paymentMethod: Order.PaymentMethod = .UPI
    @State private var quantity: Double = 0.0
    @State private var amountPaid: Double = 0.0
    @State private var paymentStatus = Order.Status.pending
    @State private var deliveryStatus = Order.Status.pending
    
    @State private var showCustomerPicker = false
    @State private var showAddCustomerView = false
    
    var product: Product
    
    init(product: Product) {
        let id = product.id
        self._stock = Query(filter: #Predicate<Stock> { stock in
            return stock.product?.id == id
        }, sort: \.date, order: .forward, animation: .default)
        
        self.product = product
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Customer Information") {
                    if let customer {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(customer.name)
                                    .bold()
                                Text(customer.phoneNumber)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("^[\(customer.wrappedOrderHistory.count) Orders](inflect: true)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Menu("\(customer == nil ? "Choose" : "Change") Customer") {
                        if !customers.isEmpty {
                            Button("Choose from existing", systemImage: "person.fill.badge.plus") {
                                showCustomerPicker = true
                            }
                        }
                        
                        Button("Add new", systemImage: "plus") {
                            showAddCustomerView = true
                        }
                    }
                    
                }
                
                Section {
                    TextField("Amount to be paid", value: $amountPaid, formatter: INRFormatter)
                        .keyboardType(.numberPad)
                    
                    Stepper(value: $quantity, in: 0.0...product.availableStock, step: product.stepAmount, format: .number) {
                        Text("\(quantity.formatted()) \(product.measurementUnit.title)")
                    }
                } footer: {
                    if product.availableStock == 0.0 {
                        Text("\(Image(systemName: "exclamationmark.triangle")) You do not have any stock left.")
                            .foregroundStyle(.red)
                    }
                }
                
                Section("Payment Details") {
                    EnumPicker(title: "Payment Method", selection: $paymentMethod)
                    
                    EnumPicker(title: "Payment Status", selection: $paymentStatus)
                }
                
                Section("Status") {
                    EnumPicker(title: "Delivery Status", selection: $deliveryStatus)
                }
            }
            .navigationTitle("New Order")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        let order = Order(for: product, customer: customer!, paymentMethod: paymentMethod, quantity: quantity, stock: [], amountPaid: amountPaid, date: Date.now, paymentStatus: paymentStatus, deliveryStatus: deliveryStatus)
                        modelContext.insert(order)
                        
                        var usedStock: [Stock] = []
                        var quantity = order.quantity
                        while quantity != 0 {
                            if let stockToUse = stock.first(where: { $0.quantityLeft > 0 }) {
                                usedStock.append(stockToUse)
                                
                                if stockToUse.quantityLeft >= quantity {
                                    stockToUse.quantityLeft -= quantity
                                    break
                                } else {
                                    stockToUse.quantityLeft = 0
                                    quantity -= stockToUse.quantityLeft
                                }
                            } else {
                                break
                            }
                        }
                        
                        order.stock = usedStock
                        
                        dismiss()
                    }
                    .bold()
                    .disabled(customer == nil || quantity == 0.0)
                }
            }
            .customerPicker(isPresented: $showCustomerPicker, selection: $customer)
            .sheet(isPresented: $showAddCustomerView) {
                AddCustomerView {
                    self.customer = $0
                }
            }
        }
    }
    
    struct EnumPicker<T: RawRepresentable & CaseIterable & Codable & Hashable>: View where T.AllCases: RandomAccessCollection, T.RawValue == String {
        let title: String
        @Binding var selection: T

        var body: some View {
            Picker(title, selection: $selection) {
                ForEach(T.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .tag(option)
                }
            }
        }
    }
}

//#Preview {
////    let product = Product(name: "Mangoes", icon: "🥭", measurementUnit: .dozen, orders: [], stock: [], isMadeToDelivery: false)
////    let customer = Customer(name: "Om", phoneNumber: "9082257216", address: Address(line1: "A402, Savoy", line2: "Raheja Gardens", city: "Thane West", pincode: "400604"), orderHistory: [])
////    let order = Order(for: product, customer: customer, paymentMethod: .cash, quantity: 1, amountPaid: 1099, paymentStatus: .pending, deliveryStatus: .pending)
////    return AddOrderView(product: product)
//}
