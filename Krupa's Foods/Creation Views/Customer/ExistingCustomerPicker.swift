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
    
    @Binding var customer: Customer?
    
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
                        Picker("Choose Customer", selection: $customer) {
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
            }
            .onChange(of: customer, dismiss.callAsFunction)
        }
    }
}

#Preview {
    ExistingCustomerPicker(customer: .constant(nil))
}

extension View {
    func customerPicker(isPresented: Binding<Bool>, selection: Binding<Customer?>) -> some View {
        self
            .sheet(isPresented: isPresented) {
                ExistingCustomerPicker(customer: selection)
            }
    }
}
