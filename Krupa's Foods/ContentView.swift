//
//  ContentView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 09/07/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query var products: [Product]
    
    @State private var product: Product?
    
    @State private var addingNewProduct = false
    
    var body: some View {
        NavigationStack {
            TabView {
                if let product {
                    Group {
                        OrdersView(product: product)
                            .tabItem {
                                Label("Orders", systemImage: "shippingbox.fill")
                            }
                        
                        if !product.isMadeToDelivery {
                            StockView(product: product)
                                .tabItem {
                                    Label("Stock", systemImage: "tray.2.fill")
                                }
                        }
                    }
                } else {
                    VStack {
                        ContentUnavailableView("No Product Available", systemImage: "tag.slash.fill", description: Text("You haven't set up any products yet.\nClick **Add Product** to get started."))
                        Button("Add Product") {
                            addingNewProduct = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .tabBar)
            .safeAreaInset(edge: .top, content: {
                if !products.isEmpty {
                    Picker("Product", selection: $product) {
                        ForEach(products) { product in
                            Group {
                                Text("\(product.icon) \(product.name)").foregroundStyle(.primary) + Text(Image(systemName: "chevron.up.chevron.down")).font(.caption)
                            }
                            .tag(product as Product?)
                        }
                        
                        Divider()
                        
                        Label("Add New Product", systemImage: "plus")
                            .tag(nil as Product?)
                    }
                    .labelsHidden()
                    .background(.primary.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .clipShape(.capsule)
#if targetEnvironment(macCatalyst)
                    .padding(.top)
#endif
                }
            })
            .onAppear {
                if let data = UserDefaults.standard.data(forKey: "currentProduct"), let decodedID  = try? JSONDecoder().decode(UUID.self, from: data)  {
                    product = products.first { $0.id == decodedID }
                } else if let product = products.first {
                    let encodedID = try? JSONEncoder().encode(product.id)
                    UserDefaults.standard.setValue(encodedID, forKey: "currentProduct")
                    self.product = product
                }
            }
            .onChange(of: product) { oldProduct, newProduct in
                if let newProduct {
                    // Stored to UserDefaults to persist across app launches.
                    let encodedID = try? JSONEncoder().encode(newProduct.id)
                    UserDefaults.standard.setValue(encodedID, forKey: "currentProduct")
                } else {
                    // A value of 'nil' indicates that "Add New Product" has been selected, so the addingNewProduct value is set to true to show the adding product sheet.
                    addingNewProduct = true
                    self.product = oldProduct
                }
            }
            .sheet(isPresented: $addingNewProduct, onDismiss: {
                self.product = products.last
            }, content: AddProductView.init)
            .animation(.default, value: product)
        }
    }
}

#Preview {
    ContentView()
}
