//
//  HomeContainerViewModel.swift
//  TeltechSpamKiller
//
//  Created by DTech on 29.09.2023..
//

import Foundation
import RxSwift
import CallKit
import TeltechSpamKillerData

class HomeContainerViewModel: ViewModelType {
    
    struct Input {
        var loadDataSubject: ReplaySubject<()>
    }
    
    struct Output: OutputViewModeling {
        var loaderSubject: PublishSubject<Bool>
        var errorSubject: PublishSubject<NetworkError>
        var disposables: [Disposable]
    }
    
    struct Dependencies {
        let subscribeScheduler: SchedulerType
        let teltechContactsRepository: TeltechContactsRepositoring
    }
    
    var input: Input!
    var output: Output!
    let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func transform(input: Input) -> Output {
        var disposables = [Disposable]()
        disposables.append(initializeDataObservable(for: input.loadDataSubject))
        let output = Output(loaderSubject: PublishSubject(),
                            errorSubject: PublishSubject(),
                            disposables: disposables)
        self.input = input
        self.output = output
        return output
    }
}

private extension HomeContainerViewModel {
    func initializeDataObservable(for subject: ReplaySubject<()>) -> Disposable {
        return subject
            .flatMap { [unowned self] (_) -> Single<TeltechContactResponse> in
                return dependencies.teltechContactsRepository.getContacts()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(on: dependencies.subscribeScheduler)
            .subscribe(onNext: { [unowned self] response in
                output.loaderSubject.onNext(false)
                checkExtensionStatus()
                handleContactsResponse(response)
            }, onError: { [unowned self] error in
                output.onError(error)
            })
    }
    
    func handleContactsResponse(_ response: TeltechContactResponse) {
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
        
        let dataManager = TeltechSpamKillerDataManager.shared
        dataManager.updateIdentificationContacts(contactsToIdentify)
        dataManager.updateBlockedContacts(contactsToBlock)
        
        dataManager.saveContext()
        dataManager.reloadExtension()
    }
    
    func checkExtensionStatus() {
        let identifier = "com.trifunovicd.TeltechSpamKiller.TeltechSpamKillerExtension"
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: identifier) { [weak self] status, error in
            if let error = error {
                print("Error checking extension: \(error.localizedDescription)")
            }
            if status != .enabled {
                self?.output.errorSubject.onNext(NetworkError.extensionError)
            }
        }
    }
}
