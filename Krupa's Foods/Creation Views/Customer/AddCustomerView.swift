//
//  AddCustomerView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 06/08/24.
//

import SwiftUI
import Contacts

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
    
    @FocusState private var focusedField: Field?
    
    enum Field: Int, Hashable {
        case name = 1
        case number = 2
        case addressLine1 = 3
        case addressLine2 = 4
        case city = 5
        case pincode = 6
    }
    
    var completion: (Customer?) -> Void
    
    @State private var showingExistingCustomerPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ContactPickerButton(contact: $contact) {
                        Label("Import Details from Contacts", systemImage: "book.closed.fill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
            .navigationTitle("New Customer")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Add") {
                        let address = Address(line1: addressLine1, line2: addressLine2, city: city, pincode: pincode)
                        let customer = Customer(name: name, phoneNumber: phoneNumber, address: address)
                        
                        modelContext.insert(customer)
                        completion(customer)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).count < 9 || addressLine1.isEmpty || city.isEmpty)
                    .bold()
                }
                
            }
        }
        .onChange(of: contact) {
            if let contact {
                importDetails(from: contact)
            }
        }
    }
    
    func submitAction() {
        if focusedField == .pincode {
            focusedField = nil
        } else if let field = focusedField {
            focusedField = Field(rawValue: field.rawValue + 1)
        }
    }
    
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
