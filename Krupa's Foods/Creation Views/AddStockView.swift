//
//  AddStockView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 14/08/24.
//

import SwiftUI
import SwiftData

// A view for adding stock to a product.
struct AddStockView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query(sort: \PendingStock.date, order: .forward) var pendingStocks: [PendingStock]
    
    @State private var amountPaid: Double = 0.0
    @State private var quantityPurchased: Double = 0.0
    @State private var quantityLeft: Double = 0.0
    @State private var date: Date = .now
    
    @State private var hasConsumed: Bool = false
    
    var product: Product
    
    @State private var detent: PresentationDetent = .medium
    
    /// Initializes the stock creation view for a product.
    /// - Parameter product: The product for which the stock is to be added.
    init(product: Product) {
        self.product = product
        self._pendingStocks = Query(filter: #Predicate<PendingStock> { pendingStock in
            if pendingStock.fulfilledBy != nil {
                return false
            } else if let product = pendingStock.product {
                return product.persistentModelID == product.persistentModelID
            } else {
                return false
            }
        }, sort: \.date, order: .forward)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Purchase Details") {
                    TextField("Amount Paid", value: $amountPaid, formatter: INRFormatter)
                        .keyboardType(.numberPad)
                    DatePicker("Purchase Date", selection: $date)
                        .datePickerStyle(.compact)
                        .frame(maxHeight: 400)
                }
                
                Section("Quantity Purchased") {
                    Stepper(value: $quantityPurchased, in: 0.0...(.infinity), step: product.stepAmount, format: .number) {
                        Text("\(quantityPurchased.formatted()) \(product.measurementUnit.title)")
                    }
                    
                    if !hasConsumed {
                        Toggle("Set Remaining Quantity", isOn: $hasConsumed.animation())
                    }
                }
                // Adjust the quantity left linearly when the quantity purchased is changed.
                .onChange(of: quantityPurchased) { oldValue, newValue in
                    if !hasConsumed || (quantityLeft > quantityPurchased) {
                        quantityLeft = quantityPurchased
                    } else {
                        if (newValue - oldValue) > 0 {
                            quantityLeft += newValue - oldValue
                        }
                    }
                }
                
                // Allow the user to set the quantity left if the stock has been consumed.
                if hasConsumed {
                    Section("Quantity Left") {
                        Stepper(value: $quantityLeft, in: 0.0...quantityPurchased, step: product.stepAmount, format: .number) {
                            Text("\(quantityLeft.formatted()) \(product.measurementUnit.title)")
                        }
                    }
                    .onAppear {
                        detent = .large
                    }
                }
                
            }
            .navigationTitle("\(product.icon) Add Stock")
            .toolbar {
                // Cancel button to dismiss the view
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                
                // Add button to save the stock.
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        let stock = Stock(amountPaid: amountPaid, quantityPurchased: quantityPurchased, quantityLeft: (hasConsumed  ? quantityLeft : quantityPurchased), for: product)
                        modelContext.insert(stock)
                        
                        // Fulfill pending stocks if any.
                        if !pendingStocks.isEmpty {
                            var quantityRemaining = self.quantityLeft
                            for pendingStock in pendingStocks {
                                if quantityRemaining > 0 && (pendingStocks.reduce(0.0) { $0 + $1.quantityToBePurchased } > 0) {
                                    if pendingStock.quantityToBePurchased > quantityRemaining {
                                        pendingStock.quantityToBePurchased -= quantityRemaining
                                        quantityRemaining = 0
                                    } else {
                                        quantityRemaining -= pendingStock.quantityToBePurchased
                                        pendingStock.fulfilledBy = stock
                                    }
                                }
                            }
                        }
                        
                        dismiss()
                    }
                    .bold()
                    .disabled(quantityPurchased == 0.0)
                }
            }
        }
        .presentationDetents([.medium, .large], selection: $detent)
    }
}
