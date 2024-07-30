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
        .modelContainer(for: [Order.self, Product.self, Customer.self])
    }
    
    init() {
        UINavigationBar.appearance().barTintColor = .clear
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        
        let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground() // <- HERE
//            appearance.stackedLayoutAppearance.normal.iconColor = .white
//            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

//            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.accentColor)
//            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(Color.accentColor)]

            UITabBar.appearance().standardAppearance = appearance
    }
}
