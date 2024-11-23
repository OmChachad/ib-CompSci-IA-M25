//
//  EnumPicker.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 11/19/24.
//

import Foundation
import SwiftUI

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
