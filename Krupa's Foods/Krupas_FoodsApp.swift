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
                .onAppear {
                    let urlApp = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
                           let url = urlApp!.appendingPathComponent("default.store")
                           if FileManager.default.fileExists(atPath: url.path) {
                               print("swiftdata db at \(url)")
                           }

                }
        }
        .modelContainer(for: [Order.self, Product.self, Customer.self])
    }
}
