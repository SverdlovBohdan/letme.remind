//
//  PickerColorsProvider.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 17.10.2023.
//

import Foundation
import SwiftUI

protocol PickerColorsProvider {
    var colors: [Color] { get }
    func getColor(by name: String) -> Color
    func getUnpickableColor() -> Color
}
