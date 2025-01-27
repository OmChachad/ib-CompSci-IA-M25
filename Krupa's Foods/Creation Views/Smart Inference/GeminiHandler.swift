//
//  GeminiHandler.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 03/09/24.
//

import Foundation
import GoogleGenerativeAI
import SwiftUI

class GeminiHandler: ObservableObject {
    enum APIKey {
      // Fetch the API key from `GenerativeAI-Info.plist`
      static var `default`: String {
          guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist")
          else {
            fatalError("Couldn't find file 'GenerativeAI-Info.plist'.")
          }
          let plist = NSDictionary(contentsOfFile: filePath)
          guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_KEY' in 'GenerativeAI-Info.plist'.")
          }
          if value.starts(with: "_") {
            fatalError(
              "Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key."
            )
          }
          return value
      }
    }
    
    struct Response: Codable, Identifiable, Equatable {
        var id: UUID = UUID()
        var quantity: Double?
        var priceToBePaid: Double?
        var paymentMethod: Order.PaymentMethod?
        var addressLine1: String?
        var addressLine2: String?
        var city: String?
        var pincode: String?
        var customerName: String?
        var phoneNumber: String?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            quantity = try container.decodeIfPresent(Double.self, forKey: .quantity)
            priceToBePaid = try container.decodeIfPresent(Double.self, forKey: .priceToBePaid)
            paymentMethod = try container.decodeIfPresent(Order.PaymentMethod.self, forKey: .paymentMethod)
            addressLine1 = try container.decodeIfPresent(String.self, forKey: .addressLine1)
            addressLine2 = try container.decodeIfPresent(String.self, forKey: .addressLine2)
            city = try container.decodeIfPresent(String.self, forKey: .city)
            pincode = try container.decodeIfPresent(String.self, forKey: .pincode)
            customerName = try container.decodeIfPresent(String.self, forKey: .customerName)
            phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
            id = UUID()
        }
        
        var wrappedQuantity: Double {
            quantity ?? 0.0
        }
        
        var wrappedPriceToBePaid: Double {
            priceToBePaid ?? 0.0
        }
        
        var wrappedPaymentMethod: Order.PaymentMethod {
            paymentMethod ?? .UPI
        }
        
        var wrappedAddressLine1: String {
            addressLine1 ?? ""
        }
        
        var wrappedAddressLine2: String {
            addressLine2 ?? ""
        }
        
        var wrappedCity: String {
            city ?? ""
        }
        
        var wrappedPincode: String {
            pincode ?? ""
        }
        
        var wrappedCustomerName: String {
            customerName ?? ""
        }
        
        var wrappedPhoneNumber: String {
            phoneNumber ?? ""
        }
    }


    
    func inferOrderDetails(for product: Product, from image: UIImage) async throws -> Response {
        let generativeModel = GenerativeModel(
                                name: "gemini-1.5-flash",
                                apiKey: APIKey.default
                              )

        let prompt = """
        This is a screenshot of a chat. Contextually figure out the following details about the chat.
        If a particular detail is not present in the chat, you can leave it empty.
        - Quantity being ordered
        - Address of the Customer
        - Price to be paid by the customer
        - The Full Name and Phone Number of the Customer
        - Mode of Payment (UPI, Cash, or Other - No other value to be here)
        
        And then, format it into the JSON format with the following Keys. All keys are optional:
        - quantity (Double)
        - priceToBePaid (Double)
        - paymentMethod (UPI, Cash, or Other - No other value to be here)
        - addressLine1 (String)
        - addressLine2 (String)
        - city (String)
        - pincode (String)
        - customerName (String)
        - phoneNumber (String)
        
        Your output should strictly adhere to the provided JSON schema, and nothing else should be included in your reply.
        """
        
        guard let jsonResponse = try await generativeModel.generateContent(prompt, image).text else {
            throw CancellationError()
        }
        
        let pattern = "\\{(?:[^{}]|\\{[^{}]*\\})*\\}"

        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(jsonResponse.startIndex..<jsonResponse.endIndex, in: jsonResponse)
            if let match = regex.firstMatch(in: jsonResponse, options: [], range: range) {
                if let matchRange = Range(match.range, in: jsonResponse) {
                    let jsonString = String(jsonResponse[matchRange])
                    print("Extracted JSON: \(jsonString)")
                    guard let data = jsonString.data(using: .utf8) else {
                        throw CancellationError()
                    }
                    
                    do {
                        let geminiResponse = try JSONDecoder().decode(Response.self, from: data)
                        
                        return geminiResponse
                    } catch {
                        throw error
                    }
                }
            }
        }
        
        throw CancellationError()
    }
}
