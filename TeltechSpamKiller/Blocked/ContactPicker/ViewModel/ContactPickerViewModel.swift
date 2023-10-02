//
//  ContactPickerViewModel.swift
//  TeltechSpamKiller
//
//  Created by DTech on 02.10.2023..
//

import Foundation
import RxSwift
import RxCocoa
import TeltechSpamKillerData

class ContactPickerViewModel: ViewModelType {
    
    struct Input {
        let loadDataSubject: ReplaySubject<()>
        let userInteractionSubject: PublishSubject<ContactPickerInteractionType>
    }
    
    struct Output: OutputViewModeling {
        var loaderSubject: PublishSubject<Bool>
        var errorSubject: PublishSubject<NetworkError>
        var screenData: BehaviorRelay<[IdentifiableSectionItem<Contact>]>
        var disposables: [Disposable]
    }
    
    struct Dependencies {
        let subscribeScheduler: SchedulerType
        let contactsService: ContactsService
        let dataSource: BlockedDataSourcing
        weak var contactPickerDelegate: ContactPickerDelegate?
    }
    
    var input: Input!
    var output: Output!
    let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func transform(input: Input) -> Output {
        var disposables = [Disposable]()
        disposables.append(initializeScreenDataObservable(for: input.loadDataSubject))
        disposables.append(initializeInteractionObservable(for: input.userInteractionSubject))
        let output = Output(loaderSubject: PublishSubject(),
                            errorSubject: PublishSubject(),
                            screenData: BehaviorRelay(value: []),
                            disposables: disposables)
        self.input = input
        self.output = output
        return output
    }
}

private extension ContactPickerViewModel {
    func initializeScreenDataObservable(for subject: ReplaySubject<()>) -> Disposable {
        return subject
            .flatMap { [unowned self] (_) -> Observable<([Contact], [TeltechContact])> in
                output.loaderSubject.onNext(true)
                dependencies.contactsService.loadContacts(force: true)
                return Observable.zip(fetchAllContacts().asObservable(), dependencies.dataSource.fetchBlockedContacts().asObservable())
            }
            .flatMap { [unowned self] (contacts, teltechContacts) -> Observable<[IdentifiableSectionItem<Contact>]> in
                return createScreenData(contacts: contacts, teltechContacts: teltechContacts)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(on: dependencies.subscribeScheduler)
            .subscribe(onNext: { [unowned self] screenData in
                output.loaderSubject.onNext(false)
                output.screenData.accept(screenData)
            }, onError: { [unowned self] error in
                output.onError(error)
            })
    }
    
    func fetchAllContacts() -> Single<[Contact]> {
        return dependencies.contactsService
            .contactsRelay
            .asObservable()
            .filter { (contacts) -> Bool in
                contacts != nil
            }
            .map { (contacts) -> [Contact] in
                contacts ?? []
            }
            .take(1)
            .asSingle()
    }
    
    func createScreenData(contacts: [Contact], teltechContacts: [TeltechContact]) -> Observable<[IdentifiableSectionItem<Contact>]> {
        var items: [IdentifiableRowItem<Contact>] = []
        let blockedNumbers = teltechContacts.map { $0.number }
        let sortedContacts = contacts.sorted(by: { (first, second) -> Bool in
            first.fullName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() < second.fullName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        })
        sortedContacts.forEach { contact in
            var contact = contact
            var isBlocked = false
            contact.phoneNumbers.forEach { number in
                if blockedNumbers.contains(number) {
                    isBlocked = true
                }
            }
            contact.isBlocked = isBlocked
            items.append(IdentifiableRowItem<Contact>(identity: "\(contact.fullName)\(contact.phoneNumberStrings.first ?? "")", item: contact))
        }
        return .just([IdentifiableSectionItem<Contact>(identity: "Contacts", items: items)])
    }
    
    func initializeInteractionObservable(for subject: PublishSubject<ContactPickerInteractionType>) -> Disposable {
        return subject
            .observe(on: MainScheduler.instance)
            .subscribe(on: dependencies.subscribeScheduler)
            .subscribe(onNext: { [unowned self] type in
                switch type {
                case .itemTapped(let indexPath):
                    handleItemTapped(indexPath)
                }
            }, onError: { [unowned self] error in
                output.onError(error)
            })
    }
    
    func handleItemTapped(_ indexPath: IndexPath) {
        let contact = output.screenData.value[indexPath.section].items[indexPath.row].item
        guard let number = contact.phoneNumbers.first, !contact.isBlocked else { return }
        dependencies.contactPickerDelegate?.saveContact(name: contact.fullName, number: number)
    }
}
