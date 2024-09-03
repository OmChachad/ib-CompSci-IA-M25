//
//  AddStockView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 14/08/24.
//

import SwiftUI
import SwiftData

struct AddStockView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var amountPaid: Double = 0.0
    @State private var quantityPurchased: Double = 0.0
    @State private var quantityLeft: Double = 0.0
    @State private var date: Date = .now
    
    @State private var hasConsumed: Bool = false
    
    var product: Product
    
    @State private var detent: PresentationDetent = .medium
    
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
                .onChange(of: quantityPurchased) { oldValue, newValue in
                    if !hasConsumed || (quantityLeft > quantityPurchased) {
                        quantityLeft = quantityPurchased
                    } else {
                        if (newValue - oldValue) > 0 {
                            quantityLeft += newValue - oldValue
                        }
                    }
                }
                
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        let stock = Stock(amountPaid: amountPaid, quantityPurchased: quantityPurchased, quantityLeft: (hasConsumed  ? quantityLeft : quantityPurchased), for: product)
                        modelContext.insert(stock)
                        
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
