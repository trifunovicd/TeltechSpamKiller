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
    var contactsRepository: TeltechContactsRepositoring { get }
    
    func createData(for type: BlockedLoadType) -> Observable<[IdentifiableSectionItem<TeltechContact>]>
    func addContact(_ data: [IdentifiableSectionItem<TeltechContact>], name: String?, number: Int64) -> Observable<[IdentifiableSectionItem<TeltechContact>]>
    func editContact(_ data: [IdentifiableSectionItem<TeltechContact>], name: String?, number: Int64, contact: TeltechContact?) -> Observable<[IdentifiableSectionItem<TeltechContact>]>
    func deleteContact(_ data: [IdentifiableSectionItem<TeltechContact>], indexPath: IndexPath) -> Observable<[IdentifiableSectionItem<TeltechContact>]>
    func fetchBlockedContacts() -> Single<[TeltechContact]>
}

final class BlockedDataSource: BlockedDataSourcing {
    var dataManager: TeltechSpamKillerDataManager
    var contactsRepository: TeltechContactsRepositoring
    
    init(dataManager: TeltechSpamKillerDataManager = TeltechSpamKillerDataManager.shared,
         contactsRepository: TeltechContactsRepositoring = TeltechContactsRepository()) {
        self.dataManager = dataManager
        self.contactsRepository = contactsRepository
    }
    
    func createData(for loadType: BlockedLoadType) -> Observable<[IdentifiableSectionItem<TeltechContact>]> {
        switch loadType {
        case .initial:
            return fetchOfflineData()
        case .pullToRefresh:
            return fetchOnlineData()
        }
    }
    
    func addContact(_ data: [IdentifiableSectionItem<TeltechContact>], name: String?, number: Int64) -> Observable<[IdentifiableSectionItem<TeltechContact>]> {
        let contact = TeltechContact(context: dataManager.context)
        let updatedDate = Date()
        contact.name = name
        contact.number = number
        contact.isBlocked = true
        contact.isRemoved = false
        contact.isUserAdded = true
        contact.updatedDate = updatedDate
        dataManager.saveContext()
        dataManager.reloadExtension()
        var modifiedData = data
        let newRow = IdentifiableRowItem<TeltechContact>(identity: updatedDate.timeIntervalSince1970.description, item: contact)
        modifiedData[0].items.append(newRow)
        return .just(modifiedData)
    }
    
    func editContact(_ data: [IdentifiableSectionItem<TeltechContact>], name: String?, number: Int64, contact: TeltechContact?) -> Observable<[IdentifiableSectionItem<TeltechContact>]> {
        guard let contact = contact,
              let index = data[0].items.firstIndex(where: { $0.item == contact }) else { return .just(data) }
        if number == contact.number {
            let updatedDate = Date()
            contact.name = name
            contact.updatedDate = updatedDate
            dataManager.saveContext()
            var modifiedData = data
            let newRow = IdentifiableRowItem<TeltechContact>(identity: updatedDate.timeIntervalSince1970.description, item: contact)
            modifiedData[0].items[index] = newRow
            return .just(modifiedData)
        } else {
            dataManager.removeContact(contact)
            var modifiedData = data
            modifiedData[0].items.remove(at: index)
            return addContact(modifiedData, name: name, number: number)
        }
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
    
    func fetchBlockedContacts() -> Single<[TeltechContact]> {
        return Single<[TeltechContact]>
            .create { [weak self] single -> Disposable in
                guard let self = self else {
                    single(.failure(NetworkError.generalError))
                    return Disposables.create()
                }
                do {
                    let contactsRequest: NSFetchRequest<TeltechContact> = dataManager.fetchRequest(blocked: true)
                    let contacts = try dataManager.context.fetch(contactsRequest)
                    single(.success(contacts))
                } catch {
                    single(.failure(error))
                }
                return Disposables.create()
            }
    }
}

private extension BlockedDataSource {
    func fetchOfflineData() -> Observable<[IdentifiableSectionItem<TeltechContact>]> {
        return fetchBlockedContacts()
            .asObservable()
            .flatMap { [unowned self] contacts -> Observable<[IdentifiableSectionItem<TeltechContact>]> in
                return .just(createScreenData(contacts))
            }
    }
    
    func createScreenData(_ contacts: [TeltechContact]) -> [IdentifiableSectionItem<TeltechContact>] {
        var items: [IdentifiableRowItem<TeltechContact>] = []
        contacts.forEach { contact in
            items.append(IdentifiableRowItem<TeltechContact>(identity: "\(contact.id)", item: contact))
        }
        return [IdentifiableSectionItem<TeltechContact>(identity: "TeltechContacts", items: items)]
    }
    
    func fetchOnlineData() -> Observable<[IdentifiableSectionItem<TeltechContact>]> {
        return contactsRepository.getContacts()
            .asObservable()
            .flatMap { [unowned self] response -> Single<()> in
                return handleContactsResponse(response)
            }
            .flatMap { [unowned self] _ -> Observable<[IdentifiableSectionItem<TeltechContact>]> in
                return fetchOfflineData()
            }
    }
    
    func handleContactsResponse(_ response: TeltechContactResponse) -> Single<()> {
        return Single<()>
            .create { [weak self] single -> Disposable in
                var contactsToIdentify: [Int64] = []
                var contactsToBlock: [Int64] = []
                
                response.suspicious.forEach { numberString in
                    let filteredString = numberString.filter({ $0.isWholeNumber })
                    if let number = Int64(filteredString) {
                        contactsToIdentify.append(number)
                    }
                }
                
                response.scam.forEach { numberString in
                    let filteredString = numberString.filter({ $0.isWholeNumber })
                    if let number = Int64(filteredString) {
                        contactsToBlock.append(number)
                    }
                }
                
                self?.dataManager.updateIdentificationContacts(contactsToIdentify)
                self?.dataManager.updateBlockedContacts(contactsToBlock)
                
                self?.dataManager.saveContext()
                self?.dataManager.reloadExtension()
                
                single(.success(()))
                return Disposables.create()
            }
    }
}
