//
//  ProductItemView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 11/3/24.
//

import SwiftUI
import SwipeActions

/// A view that represents a single product item in the ManageProductsView.
struct ProductItemView: View {
    @Environment(\.modelContext) var modelContext
    var product : Product
    
    init(_ product: Product) {
        self.product = product
    }
    
    @State private var isEditing = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        SwipeView {
            HStack {
                Text(product.icon)
                    .font(.title)
                    .font(.largeTitle)
                
                VStack(alignment: .leading) {
                    Text(product.name)
                        .bold()
                }
                
                Spacer()
            }
            .padding(10)
            .background(.ultraThickMaterial, in: .rect(cornerRadius: 20, style: .continuous))
        } trailingActions: { context in
            // Swipe actions for the product item.
            
            // Edit Button
            SwipeAction("Edit", systemImage: "pencil", backgroundColor: .blue) {
                context.state.wrappedValue = .closed
                isEditing = true
            }
            .sheet(isPresented: $isEditing) {
                // Passing the existing product into AddProductView allows for edit functionality.
                AddProductView(product: product)
            }
            
            // Delete Button
            SwipeAction("Delete", systemImage: "trash", backgroundColor: .red) {
                showDeleteConfirmation = true // Show delete confirmation dialog first instead of directly deleting the product.
            }
            .allowSwipeToTrigger()
            .foregroundStyle(.white)
            // Delete confirmation to prevent accidental deletions from swipes.
            .confirmationDialog("Confirm Deletion", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(product)
                }
                
                Button("Cancel", role: .cancel) {
                    context.state.wrappedValue = .closed
                }
            } message: {
                Text("Are you sure you want to delete this product?")
            }
        }
        .swipeActionCornerRadius(20)
        .padding(.horizontal)
    }
}
