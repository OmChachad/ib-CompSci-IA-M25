//
//  OrdersView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 22/07/24.
//

import SwiftUI
import SwiftData

struct OrdersView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query var orders: [Order]
    
    var pendingOrdersCount: Int {
        orders.filter{ $0.isPending }.count
    }
    
    var completedOrdersCount: Int {
        orders.filter { $0.isCompleted }.count
    }
    
    var product: Product
    
    init(product: Product) {
        let id = product.id
        self._orders = Query(filter: #Predicate<Order> { order in
            return order.product.id == id
        }, sort: \.date, order: .forward, animation: .default)
        
        self.product = product
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                Section {
                    VStack {
                        HStack {
                            VStack(spacing: 0) {
                                Text("\(pendingOrdersCount)")
                                    .font(.title.bold())
                                Text("Pending")
                            }
                            .opacity(0.8)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.orange.gradient.opacity(0.2), in: .rect(cornerRadius: 20, style: .continuous))
                            .padding(2.5)
                            
                            VStack(spacing: 0) {
                                Text("\(completedOrdersCount)")
                                    .font(.title.bold())
                                Text("Completed")
                            }
                            .opacity(0.8)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.green.gradient.opacity(0.3), in: .rect(cornerRadius: 20, style: .continuous))
                            .padding(2.5)
                        }
                        .padding(.horizontal, 12.5)
                        
                        
                        ForEach(orders) { order in
                            HStack {
                                Text(order.product.icon)
                                    .font(.largeTitle)
                                
                                VStack(alignment: .leading) {
                                    Text(order.customer.name)
                                        .bold()
                                    Text(order.customer.address.line1)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text("\(order.quantity.formatted()) \(order.product.measurementUnit.rawValue.capitalized)")
                                    Text(order.amountPaid, format: .currency(code: "INR"))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(10)
                            .background(.ultraThickMaterial, in: .rect(cornerRadius: 20, style: .continuous))
                            .padding(.horizontal)
                            .padding(.vertical, 2.5)
                        }
                    }
                } header: {
                    HStack {
                        Text("Orders")
                            .font(.largeTitle.bold())
                        
                        Spacer()
                        
                        Button("Add Order", systemImage: "plus.circle.fill") {
                            let product = Product(name: "Mangoes", icon: "🥭", measurementUnit: .dozen, orders: [], stock: [], isMadeToDelivery: false)
                            let customer = Customer(name: "Om", phoneNumber: "9082257216", address: Address(line1: "A402, Savoy", line2: "Raheja Gardens", city: "Thane West", pincode: 400604), orderHistory: [])
                            let order = Order(for: product, customer: customer, paymentMethod: .cash, quantity: 1, amountPaid: 1099, paymentStatus: .pending, deliveryStatus: .pending)
                            
                            modelContext.insert(order)
                        }
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                    }
                    .padding(.horizontal)
                    .background {
                        Rectangle()
                            .fill(.clear)
                            .background(.bar)
                            .blur(radius: 10)
                            .padding([.top, .horizontal], -100)
                    }
                }
            }
            
            .padding(.bottom, 125)
        }
    }
}
