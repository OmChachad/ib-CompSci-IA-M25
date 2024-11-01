//
//  ScreenshotInferenceView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 10/30/24.
//

import SwiftUI
import PhotosUI

struct ScreenshotInferenceView: View {
    @Environment(\.dismiss) var dismiss
    var product: Product
    @Binding var response: GeminiHandler.Response?
    
    @StateObject var geminiHandler = GeminiHandler()
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    var selectedImage: UIImage? {
        if let selectedImageData, let image = UIImage(data: selectedImageData) {
            return image
        }
        
        return nil
    }
    
    @State private var isProcessing = false
    @State private var showErrorAlert = false
    @State private var isShowingPhotoPicker = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    isShowingPhotoPicker.toggle()
                } label: {
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(.rect(cornerRadius: 15, style: .continuous))
                            .transition(.blurReplace)
                            .shadow(radius: 10)
                            .shimmering(active: isProcessing, bandSize: 1)
                    } else {
                        VStack {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Gradient(colors: [.purple, .blue]).opacity(0.2))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .shadow(radius: 10)
                                .overlay {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.title)
                                        .bold()
                                        .foregroundStyle(.gray.opacity(0.5))
                                        .foregroundStyle(.ultraThickMaterial)
                                }
                                .transition(.blurReplace)
                        }
                    }
                }
                .photosPicker(isPresented: $isShowingPhotoPicker, selection: $selectedItem, photoLibrary: .shared())
                .disabled(isProcessing)
                .padding()
                .onChange(of: selectedItem) {
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                            withAnimation(.default.speed(0.5)) {
                                selectedImageData = data
                            }
                        }
                    }
                }
                
                if selectedImage != nil {
                    HStack(spacing: 20) {
                        Button("\(isProcessing ? "Stop" : "Start") Processing") {
                            if isProcessing {
                                stopProcessing()
                            } else {
                                startProcessing()
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.blue.gradient, in: .capsule)
                        .transition(.blurReplace)
                        
                        if !isProcessing {
                            Button("Change Image", systemImage: "arrow.2.circlepath") {
                                isShowingPhotoPicker.toggle()
                            }
                            .labelStyle(.iconOnly)
                            .font(.title2)
                            .transition(.blurReplace)
                        }
                    }
                    .padding(.bottom)
                }
                
                
                Text("\(Image(systemName: "sparkles")) Powered by Google Gemini")
                    .bold()
                Text("Do not share any private or sensitive conversations. Screenshots will be sent to Google Servers for processing.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .alert("An Error Ocurred", isPresented: $showErrorAlert, actions: {
                Button("Cancel") {
                    dismiss()
                }
            }, message: {Text("Please try again later.")})
        }
    }
    
    func stopProcessing() {
        isProcessing = false
    }
    
    func startProcessing() {
        isProcessing = true
        
        Task {
            do {
                self.response = try await geminiHandler.inferOrderDetails(for: product, from: selectedImage!)
            } catch {
                showErrorAlert = true
                isProcessing = false
            }
        }
    }
}
