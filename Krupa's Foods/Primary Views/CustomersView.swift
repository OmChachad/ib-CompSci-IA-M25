//
//  CustomersView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 1/27/25.
//

import SwiftUI
import SwiftData

struct CustomersView: View {
    @Query var customers: [Customer]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(customers, id: \.self) { customer in
                    NavigationLink(destination: AddCustomerView(existingCustomer: customer)) {
                        CustomerItem(customer: customer)
                    }
                }
                .onDelete(perform: deleteCustomer)
            }
            #if targetEnvironment(macCatalyst)
            .padding(.top, 65)
            #endif
            .navigationTitle("Customers")
        }
    }
    
    private func deleteCustomer(at offsets: IndexSet) {
        for index in offsets {
            let customer = customers[index]
            modelContext.delete(customer)
        }
        
        try? modelContext.save()
    }
}

#Preview {
    CustomersView()
}
