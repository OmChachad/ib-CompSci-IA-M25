//
//  CustomersView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 1/27/25.
//

import SwiftUI
import SwiftData

/// A view that displays all the customers ever obtained by the business, and their order count.
struct CustomersView: View {
    @Query var customers: [Customer]
    @Environment(\.modelContext) var modelContext
    
    @State private var presentCannotDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            // List with all customers ever acquired by the business.
            List {
                ForEach(customers, id: \.self) { customer in
                    // Links to AddCustomerView with the customer passed in, allowing for the editing of customer details.
                    NavigationLink(destination: AddCustomerView(existingCustomer: customer)) {
                        CustomerItem(customer: customer)
                    }
                }
                .onDelete(perform: deleteCustomer)
            }
            #if targetEnvironment(macCatalyst)
            .padding(.top, 65)
            #else
            .padding(.top, 50)
            #endif
            .navigationTitle("Customers")
            // Alert if the customer has existing orders and therefore cannot delete the the customer record to prevent orphaned records.
            .alert("This customer cannot be deleted.", isPresented: $presentCannotDeleteAlert) {
                Button("OK", role: .cancel) {
                    presentCannotDeleteAlert = false
                }
            } message: {
                Text("This customer has previously placed orders. Delete associated orders to delete this customer.")
            }

        }
    }
    
    
    /// Check if the customer can be deleted if they have zero orders. If orders are detected, an alert indicating the customer cannot be deleted is presented.
    /// - Parameter offsets: The offsets of the customers to be deleted from the customers array.
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
