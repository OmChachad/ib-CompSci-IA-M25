//
//  StockView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 22/07/24.
//

import SwiftUI
import SwiftData

struct StockView: View {
    @Query var pendingStock: [PendingStock]
    @Query var stock: [Stock]
    
    @State private var showingAddStockView = false
    
    var product: Product
    
    init(product: Product) {
        let id = product.id
        self._stock = Query(filter: #Predicate<Stock> { stock in
            return stock.product?.id == id
        }, sort: \.date, order: .reverse, animation: .default)
        
        self._pendingStock = Query(filter: #Predicate<PendingStock> { pendingStock in
            if pendingStock.fulfilledBy != nil {
                return false
            } else if let product = pendingStock.product {
                return product.persistentModelID == product.persistentModelID
            } else {
                return false
            }
        }, sort: \.date, order: .forward)
        
        self.product = product
    }
    
    var body: some View {
        Group {
            if stock.isEmpty {
                VStack {
                    if !pendingStock.isEmpty {
                        pendingStockAlert()
                    }
                    
                    ContentUnavailableView("No Available Stock", systemImage: "tray.2.fill", description: Text("Click \(Image(systemName: "plus.circle.fill")) to add update your inventory"))
                        .frame(maxHeight: .infinity, alignment: .center)
                }
            } else {
                ScrollView {
                    if !pendingStock.isEmpty {
                        pendingStockAlert()
                    }
                    
                    LazyVStack {
                        ForEach(stock) { stockOrder in
                            StockItemView(stockOrder)
                                .padding(.horizontal)
                                .padding(.vertical, 2.5)
                        }
                    }
#if targetEnvironment(macCatalyst)
                    .padding(.top)
#endif
                }
            }
        }
        .safeAreaInset(edge: .top, content: {
            HStack {
                Text("Stock")
                    .font(.largeTitle.bold())
                
                Spacer()
                
                Button("Add Stock", systemImage: "plus.circle.fill") {
                    showingAddStockView = true
                }
                .labelStyle(.iconOnly)
                .imageScale(.large)
            }
            .padding([.horizontal, .bottom])
            .padding(.top, 30)
            .background(.bar)
        })
        .sheet(isPresented: $showingAddStockView) {
            AddStockView(product: product)
        }
        .badge(Int(pendingStock.reduce(0) { $0 + $1.quantityToBePurchased}))
    }
    
    func pendingStockAlert() -> some View {
        
            VStack(alignment: .leading) {
                Text("Out of stock!")
                    .bold()
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.2), in: Rectangle())
                
                VStack(alignment: .leading) {
                    Text("You have ^[\(pendingStock.reduce(0) { $0 + $1.quantityToBePurchased }.formatted()) \(product.measurementUnit.title)](inflect: true) pending restocking for recent orders to be fulfilled.")
                        .foregroundStyle(.secondary)
                    Divider()
                    Button("Add Stock") {
                        showingAddStockView = true
                    }
                }
                    .padding([.bottom, .horizontal], 10)
            }
            .background(Color.red.opacity(0.2), in: RoundedRectangle(cornerRadius: 20))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
    }
}
