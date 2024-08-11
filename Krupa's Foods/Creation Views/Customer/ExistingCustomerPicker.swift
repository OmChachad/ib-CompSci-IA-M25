//
//  ExistingCustomerPicker.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 11/08/24.
//

import SwiftUI
import SwiftData

struct ExistingCustomerPicker: View {
    @Environment(\.dismiss) var dismiss
    
    @Query var customers: [Customer]
    
    @State private var selectedCustomer: Customer? = nil
    
    var completion: (Customer?) -> Void
    
    var body: some View {
        
        NavigationStack {
            Group {
                if customers.isEmpty {
                    VStack {
                        Spacer()
                        
                        ContentUnavailableView("No Customers", systemImage: "person.2.slash.fill", description: Text("You don't have any customers, yet."))
                        
                        Button("Done", action: dismiss.callAsFunction)
                            .buttonStyle(.borderedProminent)
                        
                        Spacer()
                    }
                } else {
                    Form {
                        Picker("Choose Customer", selection: $selectedCustomer) {
                            ForEach(customers, id: \.self) { customer in
                                VStack(alignment: .leading) {
                                    Text(customer.name)
                                        .bold()
                                    Text("^[\(customer.orderHistory.count) Orders](inflect: true)")
                                }
                                .tag(customer as Customer?)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                }
            }
            .toolbar {
                if !customers.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel", action: dismiss.callAsFunction)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            completion(selectedCustomer)
                            dismiss()
                        }
                        .bold()
                    }
                }
            }
        }
    }
}

#Preview {
    ExistingCustomerPicker() { _ in
        
    }
}
