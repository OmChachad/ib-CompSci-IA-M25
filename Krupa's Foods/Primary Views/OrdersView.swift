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
    @State private var showingNewOrderView: Bool = false
    
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
        VStack {
            if orders.isEmpty {
                ContentUnavailableView("No Orders Placed", systemImage: "shippingbox.fill", description: Text("Click \(Image(systemName: "plus.circle.fill")) to add your first order"))
                    .frame(maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    LazyVStack {
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
                                    Text(order.customer!.name)
                                        .bold()
                                    Text(order.customer!.address.line1)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text("^[\(order.quantity.formatted()) \(order.product.measurementUnit.rawValue.capitalized)](inflect: true)")
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
                }
            }
        }
        .padding(.bottom, 125)
    
        .safeAreaInset(edge: .top, content: {
            HStack {
                Text("Orders")
                    .font(.largeTitle.bold())
                
                Spacer()
                
                Button("Add Order", systemImage: "plus.circle.fill") {
                    showingNewOrderView = true
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
        })
        .sheet(isPresented: $showingNewOrderView) {
            AddOrderView(product: product)
        }
    }
}
