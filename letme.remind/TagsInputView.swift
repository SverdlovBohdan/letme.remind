//
//  TagsInputView.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 17.10.2023.
//

import SwiftUI

//TODO: Support multi line tags container
struct TagsInputView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var tags: [String] = .init()
    @State private var inputTag: String = ""
    
    private let padding: CGFloat = 6
    
    private var colorsProvider: PickerColorsProvider = AppEnvironment.forceResolve(type: PickerColorsProvider.self)
    
    typealias OnTagChange = ((Set<String>) -> Void)
    private var onTagChange: OnTagChange?
    
    private var uniqueTags: Set<String> {
        Set<String>(tags)
    }
    
    var color: Color
    
    init(color: String?, onTagChange: OnTagChange? = nil) {
        self.color = color != nil ? colorsProvider.getColor(by: color!) : colorsProvider.getUnpickableColor()
        self.onTagChange = onTagChange
    }
    
    /// MARK: Injection ctor
    init(color: String?, colorsProvider: PickerColorsProvider, onTagChange: OnTagChange? = nil) {
        self.color = color != nil ? colorsProvider.getColor(by: color!) : colorsProvider.getUnpickableColor()
        self.colorsProvider = colorsProvider
        self.onTagChange = onTagChange
    }
    
    var body: some View {
        HStack {            
            ForEach(tags, id: \.self) { tag in
                HStack {
                    Image(systemName: "trash.circle")
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                    Text(tag)
                        .lineLimit(1)
                }
                .padding(.all, padding)
                .capsuleBackgroundWithRespectToPickedColor(color, colorsProvider: colorsProvider)
                .onTapGesture {
                    tags.removeAll { item in
                        item == tag
                    }
                    onTagChange?(uniqueTags)
                }
            }
            
            TextField(String(localized: "+ tag"), text: $inputTag)
                .onSubmit {
                    if !inputTag.isEmpty && !tags.contains(where: { item in
                        item == inputTag
                    }) {
                        tags.append(inputTag)
                        inputTag.removeAll()
                        onTagChange?(uniqueTags)
                    }
                }
        }
    }
}

extension TagsInputView {
    fileprivate init(tags: Array<String>, color: String?, colorsProvider: PickerColorsProvider? = nil) {
        self._tags = State(initialValue: tags)
        self.colorsProvider = colorsProvider ?? AppEnvironment.forceResolve(type: PickerColorsProvider.self)
        self.color = color != nil ? self.colorsProvider.getColor(by: color!) : self.colorsProvider.getUnpickableColor()
    }
}

#Preview {
    Group {
        TagsInputView(tags: ["dasdasd", "123123123"], color: Color.green.description)
        TagsInputView(tags: ["dasdasd", "123123123"], color: Color.white.description)
    }
}
