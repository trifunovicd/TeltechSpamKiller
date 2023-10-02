//
//  Contact.swift
//  TeltechSpamKiller
//
//  Created by DTech on 02.10.2023..
//

import Foundation

struct Contact: Equatable {
    let firstName: String
    let middleName: String
    let lastName: String
    let phoneNumbers: [Int64]
    let phoneNumberStrings: [String]
    var isBlocked: Bool

    var fullName: String {
        let middleNameText = middleName.isEmpty ? "" : " \(middleName)"
        return firstName + middleNameText + " \(lastName)"
    }
}
