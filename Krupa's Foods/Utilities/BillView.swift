import SwiftUI

struct BillView: View {
    @Environment(\.dismiss) var dismiss
    
    var order: Order
    
    var body: some View {
        NavigationStack {
            bill
                .frame(maxHeight: .infinity)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Label("Return", systemImage: "chevron.left")
                        }
                    }
                    
                    ToolbarItemGroup(placement: .bottomBar) {
                        let renderer = ImageRenderer(content: bill
                            .background(.white)
                            .environment(\.colorScheme, .light))
                        if let image = renderer.uiImage {
                            let swiftUIImage = Image(uiImage: image)
                            
                            ShareLink(item: swiftUIImage, preview: SharePreview("Bill", image: swiftUIImage))
                        }
                    }
                }
                .navigationTitle("Generated Invoice")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var bill: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .center, spacing: 2) {
                Text("Krupa's Foods")
                    .font(.title)
                    .bold()
                
                Text("XYZ Street, ABC City, 123456")
                    .font(.subheadline)
                
                Text("+91 12345 67890")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("INVOICE")
                        .font(.headline)
                    
                    Text("Date: \(order.date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Billed To:")
                    .font(.headline)
                
                Text(order.wrappedCustomer.name)
                    .bold()
                
                let addressComponents = [
                    order.wrappedCustomer.address.line1,
                    order.wrappedCustomer.address.line2,
                    order.wrappedCustomer.address.city,
                    order.wrappedCustomer.address.pincode
                ]
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
                
                Text(addressComponents)
                    .font(.subheadline)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Description")
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Quantity")
                        .font(.subheadline)
                        .bold()
                        .frame(width: 70, alignment: .trailing)
                    
                    Text("Price")
                        .font(.subheadline)
                        .bold()
                        .frame(width: 90, alignment: .trailing)
                }
                
                Divider()
                
                HStack {
                    Text(order.wrappedProduct.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(order.quantity.formatted()) \(order.wrappedProduct.measurementUnit.rawValue.capitalized)")
                        .frame(width: 70, alignment: .trailing)
                    
                    Text("\(order.amountPaid, format: .currency(code: "INR"))")
                        .frame(width: 90, alignment: .trailing)
                }
                
                Divider()
            }
            
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total:")
                        .font(.subheadline)
                        .bold()
                    
                    Text("\(order.amountPaid, format: .currency(code: "INR"))")
                        .font(.body)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}
