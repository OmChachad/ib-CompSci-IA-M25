//
//  SmartOrderInfererenceView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 03/09/24.
//

import SwiftUI
import PhotosUI
import Shimmer

struct SmartOrderInfererenceView: View {
    @Environment(\.dismiss) var dismiss
    var product: Product
    
    @StateObject var geminiHandler = GeminiHandler()
    @State private var response: GeminiHandler.Response? = nil
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @State private var customer: Customer?
    
    var selectedImage: UIImage? {
        if let selectedImageData, let image = UIImage(data: selectedImageData) {
            return image
        }
        
        return nil
    }
    
    @State private var isProcessing = false
    @State private var showErrorAlert = false
    @State private var isShowingPhotoPicker = false
    
    @State private var selection = 0
    
    var completion: (GeminiHandler.Response, Customer) -> Void
    
    var body: some View {
        NavigationStack {
            Group {
                if response == nil {
                    ScreenshotInferenceView(product: product, response: $response)
                        .tag(0)
                } else if let response {
                    SmartCustomerPicker(product: product, response: response) { customer in
                        self.customer = customer
                        completion(response, customer)
                        dismiss()
                    }
                    .tag(1)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
            }
        }
        .onChange(of: response) {
            if response != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    selection += 1
                }
            }
        }
        .animation(.default, value: response)
        .tabViewStyle(.page)
    }
}

#Preview {
//    SmartOrderInfererenceView(product: Product())
}
