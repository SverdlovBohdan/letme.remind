//
//  Environment.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 06.10.2023.
//

import Swinject

struct Environment {
    static let shared: Container = Container()
    
    static func forceResolve<T>(type: T.Type) -> T {
        guard let object = shared.resolve(type) else { fatalError("No registered type \(type)") }
        return object
    }
}
