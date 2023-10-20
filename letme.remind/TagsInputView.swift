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
    @StateObject private var store: TagsInputStore = .makeDefault()
    
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
                    ForEach(store.tags, id: \.self) { tag in
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
                            store.dispatch(action: .removeTag(tag))
                        }
                    }
                    
                    TextField(String(localized: "+ tag"), text: $store.inputTag)
                        .id(tagInputId)
                        .padding([.top, .bottom], strokePadding + padding)
                        .onSubmit {
                            store.dispatch(action: .addNewTag)
                        }
                }
            }
            .onChange(of: store.tags, perform: { newTags in
                logger.debug("Tags has been changed: \(newTags)")
                scrollProxy.scrollTo(tagInputId)
                onTagChange?(Set<String>(newTags))
            })
        }
    }
}

extension TagsInputView {
    fileprivate init(tags: Array<String>, color: String?, colorsProvider: PickerColorsProvider? = nil) {
        self._store = StateObject(wrappedValue: TagsInputStore(initialState: .init(tags: tags, inputTag: ""), reducer: tagsInputReducer))
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
