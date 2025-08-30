//
//  AddOrderView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 30/07/24.
//

import SwiftUI
import SwiftData

/// A view to create or edit an order entity.
struct AddOrderView: View {
    @Query var orders: [Order]
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var notes: String = ""
    
    @Query var customers: [Customer]
    @Query var stock: [Stock]
    
    @State private var customer: Customer?
    @State private var paymentMethod: Order.PaymentMethod = .UPI
    @State private var quantity: Double = 0.0
    @State private var amountPaid: Double = 0.0
    @State private var paymentStatus = Order.Status.pending
    @State private var deliveryStatus = Order.Status.pending
    
    @State private var showCustomerPicker = false
    @State private var showAddCustomerView = false
    @State private var showingSmartOrderInference = false
    
    @State private var showingLossAlert = false
    
    var toBeEditedOrder: Order? = nil
    
    var product: Product
    
    
    /// Standard initializer to add a new order for the specified product.
    /// - Parameter product: Pass in the product for which the order is to be placed.
    init(product: Product) {
        let id = product.id
        self._stock = Query(filter: #Predicate<Stock> { stock in
            return stock.product?.id == id
        }, sort: \.date, order: .forward, animation: .default)
        
        self.product = product
    }
    
    /// Overloaded initializer to edit an existing order.
    /// - Parameter order: Pass in the existing order to be edited.
    init(order: Order) {
        self.product = order.wrappedProduct
        self.toBeEditedOrder = order
        self._customer = State(initialValue: order.wrappedCustomer)
        self._paymentMethod = State(initialValue: order.paymentMethod)
        self._quantity = State(initialValue: order.quantity)
        self._amountPaid = State(initialValue: order.amountPaid)
        self._paymentStatus = State(initialValue: order.paymentStatus)
        self._deliveryStatus = State(initialValue: order.deliveryStatus)
        self._notes = State(initialValue: order.notes ?? "")
    }
    
    /// A computed property that returns the stock that will be consumed by this order.
    var usedStock: [Stock] {
        var usedStock: [Stock] = []
        var quantity = quantity
        while quantity != 0 {
            if let stockToUse = stock.first(where: { $0.quantityLeft > 0 }) {
                usedStock.append(stockToUse)
                if stockToUse.quantityLeft >= quantity {
                    break
                } else {
                    quantity -= stockToUse.quantityLeft
                }
            } else {
                break
            }
        }
        
        return usedStock
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Customer Information") {
                    if let customer {
                        // If a customer is selected, their details are displayed.
                        HStack {
                            VStack(alignment: .leading) {
                                Text(customer.name)
                                    .bold()
                                Text(customer.phoneNumber)
                                    .foregroundStyle(.secondary)
                                Text("^[\(customer.wrappedOrderHistory.count) Orders](inflect: true)")
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            // A button to change the customer.
                            Menu {
                                menuOptions()
                            } label: {
                                Label("Change Customer", systemImage: "arrow.2.circlepath")
                                    .bold()
                                    .labelStyle(.iconOnly)
                                    .imageScale(.large)
                                    .padding(5)
                                    .background(.ultraThinMaterial, in: .circle)
                            }
                        }
                    } else {
                        // If no customer is selected, the user is prompted to choose or add a new customer.
                        Menu("Choose Customer") {
                            menuOptions()
                        }
                    }
                    
                }
                
                // Section to input the quantity and amount to be paid
                Section {
                    TextField("Amount to be paid", value: $amountPaid, formatter: INRFormatter)
                        .keyboardType(.numberPad)
                    
                    Stepper(value: $quantity, in: 0.0...(.infinity), step: product.stepAmount, format: .number) {
                        Text("\(quantity.formatted()) \(product.measurementUnit.title)")
                    }
                } footer: {
                    // Footer to display warnings if the quantity exceeds available stock.
                    if product.availableStock == 0.0 {
                        Text("\(Image(systemName: "exclamationmark.triangle")) You do not have any stock left. You will be prompted to add stock.")
                            .foregroundStyle(.yellow)
                    } else if quantity > product.availableStock {
                        Text("\(Image(systemName: "exclamationmark.triangle")) You do not have enough stock left. You will be prompted to add stock.")
                            .foregroundStyle(.yellow)
                    }
                }
                
                // An option to add notes to the order.
                Section("Order Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(5, reservesSpace: true)
                }
                
                // If the order is not being sent out for free, the payment details status pickers are displayed.
                if amountPaid != 0 {
                    Section("Payment Details") {
                        EnumPicker(title: "Payment Method", selection: $paymentMethod)
                            .transition(.opacity)
                        EnumPicker(title: "Payment Status", selection: $paymentStatus)
                            .transition(.opacity)
                    }
                }
                
                // Delivery Status Details
                Section("Status") {
                    EnumPicker(title: "Delivery Status", selection: $deliveryStatus)
                }
            }
            .navigationTitle("\(toBeEditedOrder == nil ? "New" : "Edit") Order")
            .toolbar {
                // A toolbar with a cancel and save button.
                
                // Cancel button
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        // If the order is not being edited, it means this is a new order being placed. In that case, the smart AI add button is displayed.
                        if toBeEditedOrder == nil {
                            Button("Smart Add", systemImage: "sparkles") {
                                showingSmartOrderInference = true
                            }
                        }
                        
                        // Calculates the unit cost price for the stock being used by this product.
                        let unitCostPrice = (usedStock.map(\.averageCost).max() ?? 0)
                        
                        // Determine based on whether is being edited or not the button label
                        Button(toBeEditedOrder == nil ? "Add" : "Save") {
                            // If the user is selling at a loss, an alert is shown before the order is placed.
                            if amountPaid/quantity < unitCostPrice {
                                showingLossAlert = true
                            } else {
                                completionAction()
                            }
                        }
                        .bold()
                        .disabled(customer == nil || quantity == 0.0)
                        .alert(isPresented: $showingLossAlert) {
                            // Alert to show the user that they are selling at a loss with calculated cost price, loss, and break-even price. This is allowed because sometimes the client might want to sell at a loss or send a free sample to a customer.
                            Alert(
                                title: Text("Are you sure you want to sell at a loss?"),
                                message: Text("""
                                Your cost price is ₹\(unitCostPrice.formatted())/\(product.measurementUnit.title)
                                
                                You are incurring a loss of ₹\(((unitCostPrice - amountPaid/quantity)*quantity).formatted()) on this order.
                                
                                You must sell at least ₹\((unitCostPrice*quantity).formatted()) to break even.
                                """),
                                primaryButton: .cancel(),
                                secondaryButton: .destructive(Text("Yes, Continue"), action: completionAction)
                            )
                        }
                    }
                }
            }
            .customerPicker(isPresented: $showCustomerPicker, selection: $customer)
            .sheet(isPresented: $showAddCustomerView) {
                AddCustomerView {
                    // Completion handler to assign the customer once a new customer has been added.
                    self.customer = $0
                }
            }
            .sheet(isPresented: $showingSmartOrderInference) {
                // A sheet to show the smart order inference view.
                SmartOrderInfererenceView(product: product) { response, customer in
                    // Completion handler to assign the customer and the inferred data to the form.
                    
                    self.customer = customer
                    self.quantity = response.wrappedQuantity
                    self.amountPaid = response.wrappedPriceToBePaid
                    self.paymentMethod = response.wrappedPaymentMethod
                }
            }
            .animation(.default, value: amountPaid == 0)
        }
    }
    
    /// A function to complete the action of adding or editing an order.
    func completionAction() {
        if let toBeEditedOrder {
            // Saves changes to the original order.
            toBeEditedOrder.customer = customer
            toBeEditedOrder.paymentMethod = paymentMethod
            toBeEditedOrder.quantity = quantity
            toBeEditedOrder.amountPaid = amountPaid
            toBeEditedOrder.paymentStatus = paymentStatus
            toBeEditedOrder.deliveryStatus = deliveryStatus
            toBeEditedOrder.notes = notes
            
            // If the amount is 0, the payment status is marked as complete.
            if toBeEditedOrder.amountPaid == 0 {
                toBeEditedOrder.paymentStatus = .completed
            }
            #warning("Stock must be updated")
        } else {
            var pendingStock: PendingStock? = nil
            
            // Adds a backorder if the quantity exceeds the available stock.
            if quantity > product.availableStock {
                pendingStock = PendingStock(quantityToBePurchased: quantity - product.availableStock, product: product)
                modelContext.insert(pendingStock!)
            }
            
            // Calculates the order number for the new order
            let orderNumber = orders.reduce(0) { max($0, $1.orderNumber ?? 0) } + 1
            
            // Creates a new order with the given details.
            let order = Order(orderNumber: orderNumber, for: product, customer: customer!, paymentMethod: paymentMethod, quantity: quantity, stock: [], amountPaid: amountPaid, date: Date.now, paymentStatus: paymentStatus, deliveryStatus: deliveryStatus, notes: notes)
            modelContext.insert(order)
            pendingStock?.order = order
            
            // Calculates the stock that is consumed by this order.
            var usedStock: [Stock] = []
            var quantity = order.quantity
            while quantity != 0 {
                if let stockToUse = stock.first(where: { $0.quantityLeft > 0 }) {
                    usedStock.append(stockToUse)
                    
                    stockToUse.usedBy?.append(order)
                    if stockToUse.quantityLeft >= quantity {
                        break
                    } else {
                        quantity -= stockToUse.quantityLeft
                    }
                } else {
                    break
                }
            }
            
            order.stock = usedStock
            
            if order.amountPaid == 0 {
                order.paymentStatus = .completed
            }
        }
        
        
        dismiss()
    }
    
    func menuOptions() -> some View {
        Group {
            Button("Choose from existing", systemImage: "person.fill.badge.plus") {
                showCustomerPicker = true
            }
            
            Button("Add new", systemImage: "plus") {
                showAddCustomerView = true
            }
        }
    }
}

//#Preview {
////    let product = Product(name: "Mangoes", icon: "🥭", measurementUnit: .dozen, orders: [], stock: [], isMadeToDelivery: false)
////    let customer = Customer(name: "Om", phoneNumber: "9082257216", address: Address(line1: "A402, Savoy", line2: "Raheja Gardens", city: "Thane West", pincode: "400604"), orderHistory: [])
////    let order = Order(for: product, customer: customer, paymentMethod: .cash, quantity: 1, amountPaid: 1099, paymentStatus: .pending, deliveryStatus: .pending)
////    return AddOrderView(product: product)
//}
