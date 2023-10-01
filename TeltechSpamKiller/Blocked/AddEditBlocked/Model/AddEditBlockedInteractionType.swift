//
//  AddEditBlockedInteractionType.swift
//  TeltechSpamKiller
//
//  Created by DTech on 01.10.2023..
//

import Foundation
import PhoneNumberKit

enum AddEditBlockedInteractionType {
    case saveItem(name: String?, phoneNumber: PhoneNumber?)
}
