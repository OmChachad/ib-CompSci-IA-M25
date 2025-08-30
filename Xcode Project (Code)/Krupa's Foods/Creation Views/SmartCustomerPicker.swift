//
//  SmartCustomerPicker.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 15/10/24.
//

import SwiftUI
import SwiftData

/// A view that allows the user to pick a customer from a list of customers when in Smart Inference Mode based on the details inferred from the screenshot.
struct SmartCustomerPicker: View {
    @Environment(\.dismiss) var dismiss
    @State private var customer: Customer?
    
    var product: Product
    var response: GeminiHandler.Response?
    
    @State private var predicate: Predicate<Customer> = #Predicate { _ in true }
    
    @Query var customers: [Customer]
    
    var filteredCustomers: [Customer] {
        return (try? customers.filter(predicate)) ?? []
    }
    
    var completion: (Customer) -> Void
    
    /// Initializes the SmartCustomerPicker to display customers relevant to the inferred details.
    /// - Parameters:
    ///   - product: The product for which the order is being placed.
    ///   - response: The response from the Gemini API with the inferred details.
    ///   - completion: A completion handler that returns the selected customer.
    init(product: Product, response: GeminiHandler.Response?, completion: @escaping (Customer) -> Void) {
        self.product = product
        self.response = response
        self.completion = completion
        if let response {
            let addressLine1 = response.wrappedAddressLine1
            let addressLine2 = response.wrappedAddressLine2
            let city = response.wrappedCity
            let customerName = response.wrappedCustomerName
            let phoneNumber = response.wrappedPhoneNumber
            let pincode = response.wrappedPincode
            
            // Create a predicate that filters customers based on the inferred details.
            self._predicate = State(initialValue: #Predicate<Customer> { customer in
                return (
                    (customer.address.line1.localizedStandardContains(addressLine1) || customer.address.line2.localizedStandardContains(addressLine2) || customer.address.city.localizedStandardContains(city) || customer.address.pincode.localizedStandardContains(pincode) || customer.name.localizedStandardContains(customerName) || customer.phoneNumber.localizedStandardContains(phoneNumber))
                )
            })
        }
    }
    
    var body: some View {
        Group {
            Form {
                if filteredCustomers.isEmpty, let response {
                    // If no customers are found based on the inferred details, allow the user to add a new customer.
                    
                    AddCustomerView(name: response.wrappedCustomerName, phoneNumber: response.wrappedPhoneNumber, addressLine1: response.wrappedAddressLine1, addressLine2: response.wrappedAddressLine2, city: response.wrappedCity, pincode: response.wrappedPincode) { customer in
                        if let customer {
                            completion(customer)
                        }
                    }
                } else {
                    // If customers are found based on the inferred details, allow the user to choose from existing customers.
                    
                    Picker("Choose Customer", selection: $customer) {
                        CustomersList(customer: $customer, filter: predicate)
                    }
                    .pickerStyle(.inline)
                    .navigationTitle("Choose Customer")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Continue") {
                        completion(customer!)
                    }
                    .disabled(customer == nil)
                }
            }
        }
    }
}
