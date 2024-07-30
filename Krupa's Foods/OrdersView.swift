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
        }
    }
}
