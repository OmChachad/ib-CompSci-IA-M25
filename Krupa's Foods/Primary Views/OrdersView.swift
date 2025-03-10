//
//  OrdersView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 22/07/24.
//

import SwiftUI
import SwiftData

/// OrdersView is a view that displays all the orders placed for a specific product.
struct OrdersView: View {
    @Environment(\.modelContext) var modelContext
    @State private var showingNewOrderView: Bool = false
    
    @Query(sort: \Order.date, order: .reverse) var orders: [Order]
    
    var product: Product
    
    /// Initializes a new `OrdersView` with the specified product and fetches the orders that belong to the specified product.
    /// - Parameter product: Pass the product for which the orders are to be displayed
    init(product: Product) {	
        let id = product.id
        self._orders = Query(filter: #Predicate<Order> { order in
            return order.product?.id == id
        }, sort: \.date, order: .forward, animation: .default)
        
        self.product = product
    }
    
    /// Orders that have .isPending as true.
    var pendingOrders: [Order] {
        orders.filter { $0.isPending }
    }
    
    /// Orders that have .isCompleted as true.
    var completedOrders: [Order] {
        orders.filter { $0.isCompleted }
    }
    
    /// A namespace facilitates animations and transitions in the OrdersView.
    @Namespace var ordersSpace
    
    var body: some View {
        VStack {
            if orders.isEmpty {
                // Unavailability View in case no orders have been placed yet.
                ContentUnavailableView("No Orders Placed", systemImage: "shippingbox.fill", description: Text("Click \(Image(systemName: "plus.circle.fill")) to add your first order"))
                    .frame(maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    LazyVStack {
                        // Shows a header with the current status of the number of pending and completed orders.
                        HStack {
                            VStack(spacing: 0) {
                                Text("\(pendingOrders.count)")
                                    .font(.title.bold())
                                Text("Pending")
                            }
                            .opacity(0.8)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.orange.gradient.opacity(0.2), in: .rect(cornerRadius: 20, style: .continuous))
                            .padding(2.5)
                            
                            VStack(spacing: 0) {
                                Text("\(completedOrders.count)")
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
                        
                        // Pending orders section
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
                            
                            // Completed orders section
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
            // Title and Toolbar at the top with the Tab Title and "Add Order" button.
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
