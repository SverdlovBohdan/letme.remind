//
//  Environment.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 06.10.2023.
//

import Swinject
import os
import Foundation

struct AppEnvironment {
    static let shared: Container = {
        var container = Container()
        
        container.register(Logger.self) { _, category in
            return Logger(subsystem: Bundle.main.bundleIdentifier ?? "letme-remind.app", category: category)
        }
        
        return container
    }()
    
    static func forceResolve<T>(type: T.Type) -> T {
        guard let object = shared.resolve(type) else { fatalError("No registered type \(type)") }
        return object
    }
    
    static func forceResolve<T, A>(type: T.Type, arg1: A) -> T {
        guard let object = shared.resolve(type, argument: arg1) else { fatalError("No registered type \(type)") }
        return object
    }
}
