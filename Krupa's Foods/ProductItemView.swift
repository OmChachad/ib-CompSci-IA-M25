//
//  ProductItemView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 11/3/24.
//

import SwiftUI
import SwipeActions

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
            SwipeAction("Edit", systemImage: "pencil", backgroundColor: .blue) {
                context.state.wrappedValue = .closed
                isEditing = true
            }
            .sheet(isPresented: $isEditing) {
                AddProductView(product: product)
            }
            
            SwipeAction("Delete", systemImage: "trash", backgroundColor: .red) {
                showDeleteConfirmation = true
            }
            .allowSwipeToTrigger()
            .foregroundStyle(.white)
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
