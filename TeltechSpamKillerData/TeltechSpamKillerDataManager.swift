//
//  TeltechSpamKillerDataManager.swift
//  TeltechSpamKillerData
//
//  Created by DTech on 30.09.2023..
//

import Foundation
import CoreData
import CallKit

public final class TeltechSpamKillerDataManager {
    
    public static let shared = TeltechSpamKillerDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let momdName = "TeltechContacts"
        let groupName = "group.com.trifunovicd.TeltechSpamKiller"
        let fileName = "demo.sqlite"
        
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: momdName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        guard let baseURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName) else {
            fatalError("Error creating base URL for \(groupName)")
        }
        
        let storeUrl = baseURL.appendingPathComponent(fileName)
        
        let container = NSPersistentContainer(name: momdName, managedObjectModel: mom)
        
        let description = NSPersistentStoreDescription()
        
        description.url = storeUrl
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    public var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func reloadExtension() {
        let identifier = "com.trifunovicd.TeltechSpamKiller.TeltechSpamKillerExtension"
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: identifier, completionHandler: { [unowned self] (error) in
            if let error = error {
                print("Error reloading extension: \(error.localizedDescription)")
            } else {
                deleteRemovedContacts()
            }
        })
    }
    
    public func fetchRequest(blocked: Bool, includeRemoved: Bool = false, since date: Date? = nil) -> NSFetchRequest<TeltechContact> {
        let fetchRequest: NSFetchRequest<TeltechContact> = TeltechContact.fetchRequest()
        var predicates = [NSPredicate]()
        
        let blockedPredicate = NSPredicate(format:"isBlocked == %@", NSNumber(value:blocked))
        predicates.append(blockedPredicate)
        
        if !includeRemoved {
            let removedPredicate = NSPredicate(format:"isRemoved == %@", NSNumber(value:false))
            predicates.append(removedPredicate)
        }
        
        if let dateFrom = date {
            let datePredicate = NSPredicate(format:"updatedDate > %@", dateFrom as NSDate)
            predicates.append(datePredicate)
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        return fetchRequest
    }
    
    public func updateIdentificationContacts(_ contacts: [Int64]) {
        guard let currentlySuspiciousContacts = try? context.fetch(fetchRequest(blocked: false)) else { return }
        let contactsToRemove = currentlySuspiciousContacts.filter { !contacts.contains($0.number) }
        let contactsToAdd = contacts.filter { number in
            !currentlySuspiciousContacts.contains { $0.number == number }
        }
        
        let updatedDate = Date()
        contactsToRemove.forEach { contact in
            contact.isRemoved = true
            contact.updatedDate = updatedDate
        }
        
        contactsToAdd.forEach { contactNumber in
            let contact = TeltechContact(context: context)
            contact.name = "Suspicious Caller"
            contact.number = contactNumber
            contact.isBlocked = false
            contact.isRemoved = false
            contact.isUserAdded = false
            contact.updatedDate = updatedDate
        }
    }
    
    public func updateBlockedContacts(_ contacts: [Int64]) {
        guard let currentlyBlockedContacts = try? context.fetch(fetchRequest(blocked: true)) else { return }
        let contactsToRemove = currentlyBlockedContacts.filter { !contacts.contains($0.number) }
        let contactsToAdd = contacts.filter { number in
            !currentlyBlockedContacts.contains { $0.number == number }
        }
        
        let updatedDate = Date()
        contactsToRemove.forEach { contact in
            if !contact.isUserAdded {
                contact.isRemoved = true
                contact.updatedDate = updatedDate
            }
        }
        
        contactsToAdd.forEach { contactNumber in
            let contact = TeltechContact(context: context)
            contact.name = ""
            contact.number = contactNumber
            contact.isBlocked = true
            contact.isRemoved = false
            contact.isUserAdded = false
            contact.updatedDate = updatedDate
        }
    }
    
    public func removeContact(_ contact: TeltechContact) {
        let updatedDate = Date()
        contact.isRemoved = true
        contact.updatedDate = updatedDate
    }
    
    public func deleteRemovedContacts() {
        guard let removedBlockedContacts = try? context.fetch(fetchRequest(blocked: true, includeRemoved: true)) else { return }
        removedBlockedContacts.forEach { contact in
            if contact.isRemoved {
                context.delete(contact)
            }
        }
    }
}
