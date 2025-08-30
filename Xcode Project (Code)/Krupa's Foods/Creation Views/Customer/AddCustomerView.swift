//
//  AddCustomerView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 06/08/24.
//

import SwiftUI
import Contacts

/// A view for adding or editing a new customer.
struct AddCustomerView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var phoneNumber = ""
    
    @State private var addressLine1 = ""
    @State private var addressLine2 = ""
    @State private var pincode: String = ""
    @State private var city = ""
    
    @State var contact: CNContact?
    @State private var existingCustomer: Customer? = nil
    
    /// Code for controlling the currently focused field programmatically.
    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable {
        case name = 1
        case number = 2
        case addressLine1 = 3
        case addressLine2 = 4
        case city = 5
        case pincode = 6
    }
    
    /// A completion handler that returns the newly created or edited customer.
    var completion: (Customer?) -> Void
    
    /// Standard initializer for using the AddCustomerView in Create Mode.
    init(completion: @escaping (Customer?) -> Void) {
        self.completion = completion
    }
    
    /// Overloaded initializer for using the AddCustomerView in Smart Inference Mode with Pre-filled Details.
    init (name: String, phoneNumber: String, addressLine1: String, addressLine2: String, city: String, pincode: String, completion: @escaping (Customer?) -> Void) {
        self._name = State(initialValue: name)
        self._phoneNumber = State(initialValue: phoneNumber)
        self._addressLine1 = State(initialValue: addressLine1)
        self._addressLine2 = State(initialValue: addressLine2)
        self._city = State(initialValue: city)
        self._pincode = State(initialValue: pincode)
        self.completion = completion
    }
    
    /// Overloaded initializer for using the AddCustomerView in Edit Mode.
    init(existingCustomer: Customer, completion: @escaping (Customer?) -> Void = { _ in }) {
        self._name = State(initialValue: existingCustomer.name)
        self._phoneNumber = State(initialValue: existingCustomer.phoneNumber)
        self._addressLine1 = State(initialValue: existingCustomer.address.line1)
        self._addressLine2 = State(initialValue: existingCustomer.address.line2)
        self._city = State(initialValue: existingCustomer.address.city)
        self._pincode = State(initialValue: existingCustomer.address.pincode)
        self.existingCustomer = existingCustomer
        self.completion = completion
    }
    
    @State private var showingExistingCustomerPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                if existingCustomer == nil {
                    Section {
                        // A button to import details from the user's system contacts.
                        ContactPickerButton(contact: $contact) {
                            Label("Import Details from Contacts", systemImage: "book.closed.fill")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // A button to choose an existing customer stored in the app.
                        Button {
                            showingExistingCustomerPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "person.2.fill")
                                Text("Choose from Existing Customers")
                            }
                        }
                        .navigationDestination(isPresented: $showingExistingCustomerPicker) {
                            ExistingCustomerPicker(
                                customer: Binding(
                                    get: { nil },
                                    set: {
                                        showingExistingCustomerPicker = false
                                        completion($0)
                                        dismiss()
                                    }
                                ),
                                style: .navigation
                            )
                        }
                    }
                }
                
                Section(header: Text("Customer Details")) {
                    TextField("Name", text: $name)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .name)
                        .onSubmit(submitAction)
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .submitLabel(.next)
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: .number)
                        .onSubmit(submitAction)
                }
                
                Section(header: Text("Address")) {
                    TextField("Line 1", text: $addressLine1)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .addressLine1)
                        .onSubmit(submitAction)
                    
                    TextField("Line 2", text: $addressLine2)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .addressLine2)
                        .onSubmit(submitAction)
                    
                    TextField("City", text: $city)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .city)
                        .onSubmit(submitAction)
                    
                    TextField("Pincode", text: $pincode)
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .pincode)
                        .onSubmit(submitAction)
                }
            }
            // Determine the title of the navigation bar based on whether the customer is new or existing.
            .navigationTitle("\(existingCustomer == nil ? "New" : "Edit") Customer")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Group {
                        // If the customer is being edited, show the Save button, else show the Add button.
                        if let existingCustomer {
                            Button("Save") {
                                existingCustomer.name = name
                                existingCustomer.phoneNumber = phoneNumber
                                existingCustomer.address.line1 = addressLine1
                                existingCustomer.address.line2 = addressLine2
                                existingCustomer.address.city = city
                                existingCustomer.address.pincode = pincode
                                
                                completion(existingCustomer)
                                dismiss()
                            }
                        } else {
                            Button("Add") {
                                let address = Address(line1: addressLine1, line2: addressLine2, city: city, pincode: pincode)
                                let customer = Customer(name: name, phoneNumber: phoneNumber, address: address)
                                
                                modelContext.insert(customer)
                                completion(customer)
                                dismiss()
                            }
                        }
                    }
                    // Disable if any of the required fields are empty.
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).count < 9 || addressLine1.isEmpty || city.isEmpty)
                    .bold()
                }
                
            }
        }
        .onChange(of: contact) {
            // If a system contact is selected, fill the details from the contact
            if let contact {
                importDetails(from: contact)
            }
        }
    }
    
    /// Function to handle the submission of the form fields and switching of focused fields.
    func submitAction() {
        if focusedField == .pincode {
            focusedField = nil
        } else if let field = focusedField {
            focusedField = Field(rawValue: field.rawValue + 1)
        }
    }
    
    /// Function to import details from a system `CNContact` object.
    /// - Parameter contact: System `CNContact` object to import details
    func importDetails(from contact: CNContact) {
        self.name = (contact.givenName + " " + contact.familyName)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
        
        #warning("Add Support for Multiple Phone Numbers later")
        
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            self.phoneNumber = phoneNumber
        } else {
            focusedField = .number
        }
        
        if let address = contact.postalAddresses.first?.value {
            self.addressLine1 = address.street
            self.addressLine2 = address.subLocality
            self.pincode = address.postalCode
            self.city = address.city
        } else if !self.phoneNumber.isEmpty {
            focusedField = .addressLine1
        }
    }
}

#Preview {
    AddCustomerView() { _ in
        
    }
}
