//
//  EnumPicker.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 11/19/24.
//

import Foundation
import SwiftUI

/// Custom Picker for Enumerations. The Enum must conform to `RawRepresentable`, `CaseIterable`, `Codable` and `Hashable`. This allows for selection of Enum values in a Picker based on all values of the Enum.
struct EnumPicker<T: RawRepresentable & CaseIterable & Codable & Hashable>: View where T.AllCases: RandomAccessCollection, T.RawValue == String {
    let title: String
    @Binding var selection: T

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(T.allCases, id: \.self) { option in
                Text(option.rawValue)
                    .tag(option)
            }
        }
    }
}
