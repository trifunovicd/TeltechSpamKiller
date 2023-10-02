//
//  CallDirectoryHandler.swift
//  TeltechSpamKillerExtension
//
//  Created by DTech on 01.10.2023..
//

import Foundation
import CallKit
import CoreData
import TeltechSpamKillerData

final class CallDirectoryHandler: CXCallDirectoryProvider {
    
    private let dataManager = TeltechSpamKillerDataManager.shared
    
    private func contacts(blocked: Bool, includeRemoved: Bool = false, since date: Date? = nil) throws -> [TeltechContact]  {
        let contactsRequest: NSFetchRequest<TeltechContact> = dataManager.fetchRequest(blocked: blocked, includeRemoved: includeRemoved, since: date)
        let contacts = try dataManager.context.fetch(contactsRequest)
        return contacts
    }

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        
        if let lastUpdate = UserDefaultsStorage.shared.getLastUpdate(), context.isIncremental {
            addOrRemoveIncrementalBlockingPhoneNumbers(to: context, since: lastUpdate)
            
            addOrRemoveIncrementalIdentificationPhoneNumbers(to: context, since: lastUpdate)
        } else {
            addAllBlockingPhoneNumbers(to: context)
            
            addAllIdentificationPhoneNumbers(to: context)
        }
        
        UserDefaultsStorage.shared.setLastUpdate(date: Date())
        
        context.completeRequest()
    }

    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        if let callers = try? contacts(blocked: true) {
            for caller in callers {
                context.addBlockingEntry(withNextSequentialPhoneNumber: caller.number)
            }
        }
    }

    private func addOrRemoveIncrementalBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext, since date: Date) {
        if let callers = try? contacts(blocked: true, includeRemoved: true, since: date) {
            for caller in callers {
                if caller.isRemoved {
                    context.removeBlockingEntry(withPhoneNumber: caller.number)
                } else {
                    context.addBlockingEntry(withNextSequentialPhoneNumber: caller.number)
                }
            }
        }
    }

    private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        if let callers = try? contacts(blocked: false) {
            for caller in callers {
                if let name = caller.name {
                    context.addIdentificationEntry(withNextSequentialPhoneNumber: caller.number, label: name)
                }
            }
        }
    }

    private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext, since date: Date) {
        if let callers = try? contacts(blocked: false, includeRemoved: true, since: date) {
            for caller in callers {
                if caller.isRemoved {
                    context.removeIdentificationEntry(withPhoneNumber: caller.number)
                } else {
                    if let name = caller.name {
                        context.addIdentificationEntry(withNextSequentialPhoneNumber: caller.number, label: name)
                    }
                }
            }
        }
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occurred while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }

}
