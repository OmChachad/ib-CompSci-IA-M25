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
            return stock.product.id == id
        }, sort: \.date, order: .reverse, animation: .default)
        
        self.product = product
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                Section {
                    VStack {
                        ForEach(stock) { stockOrder in
                            StockItemView(stockOrder)
                                .padding(.horizontal)
                                .padding(.vertical, 2.5)
                        }
                    }
                } header: {
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
                }
            }
            .padding(.bottom, 125)
            .sheet(isPresented: $showingAddStockView) {
                AddStockView(product: product)
            }
        }
    }
}
