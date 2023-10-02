//
//  ContactService.swift
//  TeltechSpamKiller
//
//  Created by DTech on 02.10.2023..
//

import Foundation
import Contacts
import RxSwift
import RxCocoa
import PhoneNumberKit

public class ContactsService {
    public static let shared = ContactsService()
    
    private init() {}
    
    let contactsRelay = BehaviorRelay<[Contact]?>(value: nil)
    private let phoneNumberKit = PhoneNumberKit()
    private var alreadyLoaded = false

    func loadContacts(force: Bool) {
        if !force {
            switch CNContactStore.authorizationStatus(for: .contacts) {
            case .authorized:
                break
            default:
                return
            }
        }

        if alreadyLoaded {
            return
        }

        alreadyLoaded = true

        DispatchQueue
            .global(qos: .background)
            .async { [weak self] in
                guard let self = self else { return }
                self.contactsRelay.accept(self.contacts)
            }
    }

    private lazy var contacts: [Contact] = {
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        let defaultRegion = PhoneNumberKit.defaultRegionCode()
        var contacts = [Contact]()
        _ = try? store.enumerateContacts(with: request, usingBlock: { contactObject, _ in
            var phoneNumberStrings = [String]()
            var phoneNumbers = [Int64]()
            
            contactObject.phoneNumbers.forEach { phone in
                let phoneValue = phone.value.stringValue
                
                if let phoneNumber = try? phoneNumberKit.parse(phoneValue, withRegion: defaultRegion),
                   phoneNumber.type == .fixedOrMobile || phoneNumber.type == .mobile {
                    let countryCode = phoneNumber.countryCode
                    let nationalNumber = phoneNumber.nationalNumber
                    let formattedString = "\(countryCode)" + "\(nationalNumber)"
                    phoneNumberStrings.append(formattedString)
                    if let phoneNumber = Int64(formattedString) {
                        phoneNumbers.append(phoneNumber)
                    }
                }
            }
            
            guard !phoneNumberStrings.isEmpty else { return }
            let contact = Contact(firstName: contactObject.givenName,
                                  middleName: contactObject.middleName,
                                  lastName: contactObject.familyName,
                                  phoneNumbers: phoneNumbers,
                                  phoneNumberStrings: phoneNumberStrings, 
                                  isBlocked: false)
            contacts.append(contact)
        })

        return contacts
    }()
}
