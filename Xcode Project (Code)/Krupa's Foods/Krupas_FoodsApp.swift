//
//  Krupas_FoodsApp.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 09/07/24.
//

import SwiftUI

@main
struct Krupas_FoodsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Order.self, Product.self, Customer.self]) // This line is used to initialize the SwiftData database with the required entities.
    }
}
