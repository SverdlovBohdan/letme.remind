//
//  TagsInputView.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 17.10.2023.
//

import SwiftUI
import os

//TODO: Support multi line tags container
struct TagsInputView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var tags: [String] = .init()
    @State private var inputTag: String = ""
    
    private let padding: CGFloat = 6
    private let strokePadding: CGFloat = 2
    private let tagInputId: Int = 13
    
    private var colorsProvider: PickerColorsProvider = AppEnvironment.forceResolve(type: PickerColorsProvider.self)
    private var logger: Logger =
    AppEnvironment.forceResolve(type: Logger.self, arg1: String(describing: TagsInputView.self))
    
    typealias OnTagChange = ((Set<String>) -> Void)
    private var onTagChange: OnTagChange?
    
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
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(tags, id: \.self) { tag in
                        HStack {
                            Image(systemName: "trash.circle")
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            Text(tag)
                                .lineLimit(1)
                        }
                        .padding(.all, padding)
                        .capsuleBackgroundWithRespectToPickedColor(color, colorsProvider: colorsProvider)
                        .padding(.all, strokePadding)
                        .onTapGesture {
                            tags.removeAll { item in
                                item == tag
                            }
                        }
                    }
                    
                    TextField(String(localized: "+ tag"), text: $inputTag)
                        .id(tagInputId)
                        .padding([.top, .bottom], strokePadding + padding)
                        .onSubmit {
                            if !inputTag.isEmpty && !tags.contains(where: { item in
                                item == inputTag
                            }) {
                                tags.append(inputTag)
                                inputTag.removeAll()
                            }
                        }
                }
            }
            .onChange(of: tags, perform: { newTags in
                logger.debug("Tags has been changed: \(newTags)")
                scrollProxy.scrollTo(tagInputId)
                onTagChange?(Set<String>(newTags))
            })
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
