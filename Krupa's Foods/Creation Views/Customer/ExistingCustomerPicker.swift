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
    
    @State private var searchTerm: String = ""
    
    enum Style {
        case navigation
        case sheet
    }
    
    var style: Style = .sheet
    
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
                            CustomersList(customer: $customer, searchTerm: searchTerm)
                        }
                        .pickerStyle(.inline)
                    }
                }
            }
            .searchable(text: $searchTerm, prompt: "Search for an existing customer...")
            .navigationTitle("Choose Customer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if style == .sheet {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel", action: dismiss.callAsFunction)
                    }
                }
            }
            .onChange(of: customer, dismiss.callAsFunction)
        }
    }
}

struct CustomersList: View {
    @Binding var customer: Customer?
    
    @Query var customers: [Customer]
    
    init(customer: Binding<Customer?>, searchTerm: String) {
        self._customer = customer
        self._customers = Query(filter: #Predicate {
                if searchTerm.isEmpty {
                    return true
                } else {
                    return $0.name.localizedStandardContains(searchTerm) || $0.phoneNumber.localizedStandardContains(searchTerm) || $0.address.line1.localizedStandardContains(searchTerm) || $0.address.line2.localizedStandardContains(searchTerm) || $0.address.city.localizedStandardContains(searchTerm) || $0.address.pincode.localizedStandardContains(searchTerm)
                }
            }
        )
    }
    
    init(customer: Binding<Customer?>, filter: Predicate<Customer>) {
        self._customer = customer
        self._customers = Query(filter: filter)
    }
    
    var body: some View {
        ForEach(customers, id: \.self) {
            CustomerItem(customer: $0)
        }
    }
}

struct CustomerItem: View {
    var customer: Customer
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(customer.name)
                .bold()
            
            Text("^[\(customer.wrappedOrderHistory.count) Orders](inflect: true)")
        }
        .tag(customer as Customer?)
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
