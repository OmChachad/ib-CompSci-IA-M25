//
//  AddProductView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 28/07/24.
//

import SwiftUI
import MCEmojiPicker

/// A view to create or edit a product entity.
struct AddProductView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var icon: String = ""
    @State private var name: String = ""
    @State private var measurementUnit: Product.Unit = .piece
    @State private var isMadeToDelivery = false
    
    @State private var showEmojiPicker = false
    
    var product: Product?
    
    
    /// Standard initializer for using the AddProductView in Create Mode.
    init() {}
    
    /// Overloaded initializer for using the AddProductView in Edit Mode.
    /// - Parameter product: Pass in an existing product to edit its details.
    init(product: Product? = nil) {
        self.product = product
        
        if let product {
            self._icon = State(initialValue: product.icon)
            self._name = State(initialValue: product.name)
            self._measurementUnit = State(initialValue: product.measurementUnit)
            self._isMadeToDelivery = State(initialValue: product.isMadeToDelivery)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // A section to add the product icon and name.
                Section("Details") {
                    Group {
                        if !icon.isEmpty  {
                            Text(icon)
                        } else {
                            Image(systemName: "plus.circle.dashed")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .font(.system(size: 100))
                    .frame(maxWidth: .infinity, maxHeight: 250, alignment: .center)
                    .onTapGesture {
                        showEmojiPicker = true
                    }
                    // Use the MCEmojiPicker to select an emoji for the product.
                    .emojiPicker(isPresented: $showEmojiPicker, selectedEmoji: $icon)
                    
                    TextField("Title", text: $name)
                }
                
                // A toggle to set if the product is made to delivery, to determine whether to manage inventory for the product.
                Section {
                    Toggle("Made to delivery", isOn: $isMadeToDelivery)
                } footer: {
                    Text("If a product is made to delivery, you will not be able to manage inventory.")
                }
                
                // A picker to select the unit of measurement for the product.
                Section {
                    Picker("Unit", selection: $measurementUnit) {
                        ForEach(Product.Unit.allCases, id: \.self) { unit in
                            Text(unit.title)
                                .tag(unit)
                        }
                    }
                } header: {
                    Text("Measurement")
                } footer: {
                    Text("This will be the unit of measurement that will be used when placing orders for this product.")
                }
            }
            .navigationTitle(name.isEmpty ? "New Product" : name)
            .toolbar {
                // Toolbar items for the top bar.
                
                // Cancel button to dismiss the view.
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Group {
                        // If the product is being edited, show the Save button, else show the Add button.
                        if let product {
                            Button("Save") {
                                product.name = name
                                product.icon = icon
                                product.measurementUnit = measurementUnit
                                product.isMadeToDelivery = isMadeToDelivery
                                dismiss()
                            }
                        } else {
                            Button("Add") {
                                let product = Product(name: name, icon: icon, measurementUnit: measurementUnit, isMadeToDelivery: isMadeToDelivery)
                                modelContext.insert(product)
                                dismiss()
                            }
                        }
                    }
                    .bold()
                    .disabled(name.isEmpty || icon.isEmpty)
                }
            }
        }
        
    }
}
