//
//  PhoneFormatService.swift
//  TeltechSpamKiller
//
//  Created by DTech on 01.10.2023..
//

import Foundation
import PhoneNumberKit

class PhoneFormatService {
    static let shared = PhoneFormatService()
    private let phoneNumberKit = PhoneNumberKit()
    
    func getFormattedPhoneString(number: Int64) -> String {
        let numberString = "+" + String(number)
        guard let phoneNumber = try? phoneNumberKit.parse(numberString) else {
            return String(number)
        }
        return phoneNumberKit.format(phoneNumber, toType: .international)
    }
}
