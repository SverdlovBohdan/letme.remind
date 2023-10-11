//
//  UserDefaults+UserDefaultsAdapter.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 11.10.2023.
//

import Foundation

protocol UserDefaultsAdapter {
    func data(forKey defaultName: String) -> Data?
    func setValue(_ value: Any?, forKey key: String)
}

extension UserDefaults: UserDefaultsAdapter {}
