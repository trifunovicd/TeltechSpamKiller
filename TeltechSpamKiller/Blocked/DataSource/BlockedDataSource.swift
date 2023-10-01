//
//  BlockedRepository.swift
//  TeltechSpamKiller
//
//  Created by DTech on 30.09.2023..
//

import Foundation
import RxSwift
import CoreData
import TeltechSpamKillerData

protocol BlockedDataSourcing {
    var dataManager: TeltechSpamKillerDataManager { get }
    
    func createData() -> Observable<[IdentifiableSectionItem<TeltechContact>]>
    func addContact(_ data: [IdentifiableSectionItem<TeltechContact>], name: String, number: Int64) -> Observable<[IdentifiableSectionItem<TeltechContact>]>
    func deleteContact(_ data: [IdentifiableSectionItem<TeltechContact>], indexPath: IndexPath) -> Observable<[IdentifiableSectionItem<TeltechContact>]>
}

class BlockedDataSource: BlockedDataSourcing {
    var dataManager: TeltechSpamKillerDataManager
    
    init(dataManager: TeltechSpamKillerDataManager = TeltechSpamKillerDataManager.shared) {
        self.dataManager = dataManager
    }
    
    func createData() -> Observable<[IdentifiableSectionItem<TeltechContact>]> {
        return fetchBlockedContacts()
            .flatMap { [unowned self] contacts -> Observable<[IdentifiableSectionItem<TeltechContact>]> in
                return .just(createScreenData(contacts))
            }
    }
    
    func addContact(_ data: [IdentifiableSectionItem<TeltechContact>], name: String, number: Int64) -> Observable<[IdentifiableSectionItem<TeltechContact>]> {
        let contact = TeltechContact(context: dataManager.context)
        let updatedDate = Date()
        contact.name = name
        contact.number = number
        contact.isBlocked = true
        contact.isRemoved = false
        contact.updatedDate = updatedDate
        dataManager.saveContext()
        dataManager.reloadExtension()
        var modifiedData = data
        let newRow = IdentifiableRowItem<TeltechContact>(identity: updatedDate.timeIntervalSince1970.description, item: contact)
        modifiedData[0].items.append(newRow)
        return .just(modifiedData)
    }
    
    func deleteContact(_ data: [IdentifiableSectionItem<TeltechContact>], indexPath: IndexPath) -> Observable<[IdentifiableSectionItem<TeltechContact>]> {
        let contact = data[indexPath.section].items[indexPath.row].item
        contact.isRemoved = true
        contact.updatedDate = Date()
        dataManager.saveContext()
        dataManager.reloadExtension()
        var modifiedData = data
        modifiedData[indexPath.section].items.remove(at: indexPath.row)
        return .just(modifiedData)
    }
}

private extension BlockedDataSource {
    func fetchBlockedContacts() -> Observable<[TeltechContact]> {
        return Observable<[TeltechContact]>
            .create { [unowned self] (observer) -> Disposable in
                do {
                    let contactsRequest: NSFetchRequest<TeltechContact> = dataManager.fetchRequest(blocked: true)
                    let contacts = try dataManager.context.fetch(contactsRequest)
                    observer.onNext(contacts)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
    }
    
    func createScreenData(_ contacts: [TeltechContact]) -> [IdentifiableSectionItem<TeltechContact>] {
        var items: [IdentifiableRowItem<TeltechContact>] = []
        contacts.forEach { contact in
            items.append(IdentifiableRowItem<TeltechContact>(identity: "\(contact.id)", item: contact))
        }
        return [IdentifiableSectionItem<TeltechContact>(identity: "TeltechContacts", items: items)]
    }
}
