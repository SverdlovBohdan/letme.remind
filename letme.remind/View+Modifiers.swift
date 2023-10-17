//
//  View+Modifiers.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 17.10.2023.
//

import SwiftUI

struct CapsuleBackgroundWithRespectToPickedColor: ViewModifier {
    var color: Color
    var colorsProvider: PickerColorsProvider
    
    
    func body(content: Content) -> some View {
        if colorsProvider.getUnpickableColor() != color {
            content.background(Capsule().fill(color))
        } else {
            content.overlay {
                Capsule().stroke(Color.gray, style: StrokeStyle(lineWidth: 2.0))
            }
        }
    }
}

struct CircleStrokeWithRespectToPickedColorAndColorScheme: ViewModifier {
    var colorScheme: ColorScheme
    var color: Color
    var colorsProvider: PickerColorsProvider
    
    func body(content: Content) -> some View {
        
        if colorsProvider.getUnpickableColor() != color {
            content.background(Circle().fill(colorScheme == .light ? .white : .black))
        } else {
            content.overlay(content: {
                Circle().stroke(colorScheme == .light ? .black : .white)
            })
        }
    }
}

extension View {
    func capsuleBackgroundWithRespectToPickedColor(_ color: Color, colorsProvider: PickerColorsProvider) -> some View {
        modifier(CapsuleBackgroundWithRespectToPickedColor(color: color, colorsProvider: colorsProvider))
    }
    
    func circleStrokeWithRespectToPickedColorAndColorScheme(_ color: Color, _ scheme: ColorScheme,
                                                            colorsProvider: PickerColorsProvider) -> some View {
        modifier(CircleStrokeWithRespectToPickedColorAndColorScheme(colorScheme: scheme,
                                                                    color: color,
                                                                    colorsProvider: colorsProvider))
    }
}
