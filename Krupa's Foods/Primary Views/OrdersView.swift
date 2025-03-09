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
    
    @Query(sort: \Order.date, order: .reverse) var orders: [Order]
    
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
            return order.product?.id == id
        }, sort: \.date, order: .forward, animation: .default)
        
        self.product = product
    }
    
    var pendingOrders: [Order] {
        orders.filter { $0.isPending }
    }
    
    var completedOrders: [Order] {
        orders.filter { $0.isCompleted }
    }
    
    @Namespace var ordersSpace
    
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
                        .padding(.bottom, 2.5)
                        
                        LazyVStack(pinnedViews: [.sectionHeaders]) {
                            Section {
                                ForEach(pendingOrders) { order in
                                    OrderListItem(order, namespace: ordersSpace)
                                }
                            } header: {
                                Text("Pending")
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12.5)
                                    .background {
                                        // VariableBlur backgrounds prevent the title from interfering with the orders content.
                                        VariableBlurView(maxBlurRadius: 20, direction: .blurredTopClearBottom)
                                            .padding(.top, -10)
                                            .frame(height: 30)
                                    }
                            }
                            .opacity(pendingOrders.isEmpty ? 0 : 1)
                            .padding(.bottom, 2.5)
                            
                            Section {
                                ForEach(completedOrders) { order in
                                    OrderListItem(order, namespace: ordersSpace)
                                }
                            } header: {
                                Text("Completed")
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12.5)
                                    .background {
                                        // VariableBlur backgrounds prevent the title from interfering with the orders content.
                                        VariableBlurView(maxBlurRadius: 20, direction: .blurredTopClearBottom)
                                            .padding(.top, -10)
                                            .frame(height: 30)
                                    }
                            }
                            .opacity(completedOrders.isEmpty ? 0 : 1)
                        }
                    }
#if targetEnvironment(macCatalyst)
                    .padding(.top)
#endif
                }
                .scrollIndicators(.visible)
            }
        }
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
            .padding([.horizontal, .bottom])
            .padding(.top, 40)
            .background(.bar)
        })
        .sheet(isPresented: $showingNewOrderView) {
            AddOrderView(product: product)
        }
        .animation(.easeInOut.speed(1.75), value: orders.count)
    }
}
