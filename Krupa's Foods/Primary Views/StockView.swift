//
//  StockView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 22/07/24.
//

import SwiftUI
import SwiftData

struct StockView: View {
    @Query var stock: [Stock]
    
    @State private var showingAddStockView = false
    
    var product: Product
    
    init(product: Product) {
        let id = product.id
        self._stock = Query(filter: #Predicate<Stock> { stock in
            return stock.product?.id == id
        }, sort: \.date, order: .reverse, animation: .default)
        
        self.product = product
    }
    
    var body: some View {
        Group {
            if stock.isEmpty {
                ContentUnavailableView("No Available Stock", systemImage: "tray.2.fill", description: Text("Click \(Image(systemName: "plus.circle.fill")) to add update your inventory"))
                    .frame(maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(stock) { stockOrder in
                            StockItemView(stockOrder)
                                .padding(.horizontal)
                                .padding(.vertical, 2.5)
                        }
                    }
                }
            }
        }
        .padding(.bottom, 125)
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
            .padding(.horizontal)
            .background {
                Rectangle()
                    .fill(.clear)
                    .background(.bar)
                    .blur(radius: 10)
                    .padding([.top, .horizontal], -100)
            }
        })
        .sheet(isPresented: $showingAddStockView) {
            AddStockView(product: product)
        }
    }
}
