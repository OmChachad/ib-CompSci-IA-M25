//
//  ExistingCustomerPicker.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 11/08/24.
//

import SwiftUI
import SwiftData

/// A view that allows the user to pick from existing customers.
struct ExistingCustomerPicker: View {
    @Environment(\.dismiss) var dismiss
    
    @Query var customers: [Customer]
    
    @Binding var customer: Customer?
    
    @State private var searchTerm: String = ""
    
    /// The style of the picker. This adapts the UI to match the style of the parent view.
    enum Style {
        case navigation
        case sheet
    }
    
    var style: Style = .sheet
    
    var body: some View {
        NavigationStack {
            Group {
                if customers.isEmpty {
                    // Content Unavailable View if no customers are available.
                    VStack {
                        Spacer()
                        
                        ContentUnavailableView("No Customers", systemImage: "person.2.slash.fill", description: Text("You don't have any customers, yet."))
                        
                        Button("Done", action: dismiss.callAsFunction)
                            .buttonStyle(.borderedProminent)
                        
                        Spacer()
                    }
                } else {
                    // Form with picker to choose from existing customers.
                    Form {
                        Picker("Choose Customer", selection: $customer) {
                            CustomersList(customer: $customer, searchTerm: searchTerm)
                        }
                        .pickerStyle(.inline)
                    }
                }
            }
            // Searchable to select for a partocular customer.
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
    
    /// List of customers that match the search term.
    /// - Parameters:
    ///   - customer: The customer that is to be selected.
    ///   - searchTerm: The search term to filter the customers by.
    init(customer: Binding<Customer?>, searchTerm: String) {
        self._customer = customer
        self._customers = Query(filter: #Predicate {
                if searchTerm.isEmpty {
                    return true
                } else {
                    // Finds any similarity between the search term and the customer's name, phone number, address line 1, address line 2, city, or pincode.
                    return $0.name.localizedStandardContains(searchTerm) || $0.phoneNumber.localizedStandardContains(searchTerm) || $0.address.line1.localizedStandardContains(searchTerm) || $0.address.line2.localizedStandardContains(searchTerm) || $0.address.city.localizedStandardContains(searchTerm) || $0.address.pincode.localizedStandardContains(searchTerm)
                }
            }
        )
    }
    
    /// List of customers with a predicate.
    /// - Parameters:
    ///   - customer: The customer that is to be selected.
    ///   - filter: The predicate to filter the customers by.
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

/// A view that displays a an individual customers details in the CustomersList
struct CustomerItem: View {
    var customer: Customer
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(customer.name)
                    .bold()
                
                ViewThatFits {
                    Text([customer.address.line1, customer.address.line2, customer.address.city, customer.address.pincode]
                        .compactMap { $0 }
                        .joined(separator: ", "))
                        .lineLimit(1)
                    
                    Text([customer.address.line1, customer.address.line2, customer.address.city]
                        .compactMap { $0 }
                        .joined(separator: ", "))
                        .lineLimit(1)
                    
                    Text([customer.address.line1, customer.address.line2]
                        .compactMap { $0 }
                        .joined(separator: ", "))
                        .lineLimit(1)
                    
                    Text(customer.address.line1)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text("^[\(customer.wrappedOrderHistory.count) Orders](inflect: true)")
                .foregroundStyle(.secondary)
        }
        .tag(customer as Customer?)
    }
}

#Preview {
    ExistingCustomerPicker(customer: .constant(nil))
}

extension View {
    /// An extension to present the ExistingCustomerPicker as a sheet. This is a convenience method to present the picker as a sheet.
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines whether to present the customer picker sheet.
    ///   - selection: A binding to the selected customer.
    func customerPicker(isPresented: Binding<Bool>, selection: Binding<Customer?>) -> some View {
        self
            .sheet(isPresented: isPresented) {
                ExistingCustomerPicker(customer: selection)
            }
    }
}
