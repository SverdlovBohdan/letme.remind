//
//  ColorTagPickerView.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 15.10.2023.
//

import SwiftUI

struct PickerColors {
    static let colors: [Color] = [.orange, .blue, .green, .yellow, .red, .white]
    
    static func getColor(by name: String) -> Color {
        return colors.first { color in
            return color.description == name
        }!
    }
}

struct ColorTagPickerView: View {
    @State private var pickedIndex: Int = 0
    private let colors: [Color] = PickerColors.colors
    private var onPickedColorChange: ((String?) -> Void)?
    
    init(onChange: ((String?) -> Void)? = nil) {
        self.onPickedColorChange = onChange
    }
    
    var body: some View {
        HStack {
            ForEach(colors.indices, id: \.self) { idx in
                makeColorCircle(for: colors[idx], index: idx)
                    .onTapGesture {
                        pickedIndex = idx
                        onPickedColorChange?(pickedIndex < colors.count - 1 ? colors[pickedIndex].description : nil)
                    }
            }
        }
        .onAppear {
            pickedIndex = colors.endIndex - 1
        }
    }
    
    private func makeColorCircle(for color: Color, index: Int!) -> some View {
        VStack {
            Circle()
                .frame(width: 4, height: 4)
                .foregroundStyle(.primary)
                .opacity(index == pickedIndex ? 1.0 : 0.0)
                .animation(.easeIn, value: pickedIndex)
            
            if color != Color.white {
                Circle()
                    .foregroundStyle(color)
            } else {
                Circle()
                    .foregroundStyle(color)
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
