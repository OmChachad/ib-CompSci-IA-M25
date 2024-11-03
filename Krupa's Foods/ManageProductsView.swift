//
//  ManageProductsView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 11/3/24.
//

import SwiftUI
import SwiftData
import SwipeActions

struct ManageProductsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query var products: [Product]
    
    @State private var addingNewProduct = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(products, id: \.self) { product in
                        ProductItemView(product)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading).combined(with: .swipeDelete)))
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Product", systemImage: "plus.circle.fill") {
                        addingNewProduct = true
                    }
                    .sheet(isPresented: $addingNewProduct) {
                        AddProductView()
                    }
                }
            }
            .navigationTitle("Manage Products")
            .animation(.easeInOut.speed(1.75), value: products.count)
        }
    }
}

#Preview {
    ManageProductsView()
}
