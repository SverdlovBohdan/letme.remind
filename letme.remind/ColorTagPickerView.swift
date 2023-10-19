//
//  ColorTagPickerView.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 15.10.2023.
//

import SwiftUI

struct ColorTagPickerView: View {
    @State private var pickedIndex: Int = 0
    private let colorsProvider: PickerColorsProvider = 
        AppEnvironment.forceResolve(type: PickerColorsProvider.self)
    private var onPickedColorChange: ((String?) -> Void)?
    
    init(onChange: ((String?) -> Void)? = nil) {
        self.onPickedColorChange = onChange
    }
    
    var body: some View {
        HStack {
            ForEach(colorsProvider.colors.indices, id: \.self) { idx in
                makeColorCircle(for: colorsProvider.colors[idx], index: idx)
                    .onTapGesture {
                        pickedIndex = idx
                        let isPickableColor =
                            colorsProvider.colors.firstIndex(of: colorsProvider.getUnpickableColor()) != pickedIndex
                        let color = isPickableColor ? colorsProvider.colors[pickedIndex].description : nil
                        onPickedColorChange?(color)
                    }
            }
        }
    }
    
    private func makeColorCircle(for color: Color, index: Int!) -> some View {
        VStack {
            Circle()
                .frame(width: 4, height: 4)
                .foregroundStyle(.primary)
                .opacity(index == pickedIndex ? 1.0 : 0.0)
                .animation(.easeIn, value: pickedIndex)
            
            if color != colorsProvider.getUnpickableColor() {
                Circle()
                    .foregroundStyle(color)
            } else {
                Circle()
                    .foregroundStyle(color)
                    .opacity(0.0)
                    .overlay(content: {
                        Circle()
                            .stroke(Color.gray, style: StrokeStyle(lineWidth: 2.0))
                    })
            }
        }
    }
}

#Preview {
    ColorTagPickerView()
}
