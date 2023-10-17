//
//  PickerColors.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 17.10.2023.
//

import Foundation
import SwiftUI

class PickerColors: PickerColorsProvider {
    var colors: [Color] {
        [.white, .orange, .blue, .green, .yellow, .red]
    }
    
    func getColor(by name: String) -> Color {
        let color: Color? = colors.first { color in
            return color.description == name
        }
        
        guard let color = color else { fatalError() }
        return color
    }
    
    func getUnpickableColor() -> Color {
        let nonePickedColor: Color? =  colors.first
        guard let color = nonePickedColor else { fatalError() }
        return color
    }
}
