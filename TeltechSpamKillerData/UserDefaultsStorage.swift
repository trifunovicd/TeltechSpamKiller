//
//  UserDefaultsStorage.swift
//  TeltechSpamKiller
//
//  Created by DTech on 01.10.2023..
//

import Foundation

public class UserDefaultsStorage {
    public static let shared = UserDefaultsStorage()
    
    private let userDefaults = UserDefaults.standard
    private let lastUpdatedKey = "lastUpdated"
    
    public func setLastUpdate(date: Date) {
        userDefaults.set(date, forKey: lastUpdatedKey)
    }

    public func getLastUpdate() -> Date? {
        return userDefaults.value(forKey: lastUpdatedKey) as? Date
    }
}
