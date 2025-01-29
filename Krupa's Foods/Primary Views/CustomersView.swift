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
    
    @State private var presentCannotDeleteAlert = false
    
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
            .alert("This customer cannot be deleted.", isPresented: $presentCannotDeleteAlert) {
                Button("OK", role: .cancel) {
                    presentCannotDeleteAlert = false
                }
            } message: {
                Text("This customer has previously placed orders. Delete associated orders to delete this customer.")
            }

        }
    }
    
    private func deleteCustomer(at offsets: IndexSet) {
        for index in offsets {
            let customer = customers[index]
            if customer.wrappedOrderHistory.isEmpty {
                modelContext.delete(customer)
            } else {
                presentCannotDeleteAlert = true
            }
        }
        
        try? modelContext.save()
    }
}

#Preview {
    CustomersView()
}
