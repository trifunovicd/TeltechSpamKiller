//
//  AddEditBlockedViewModel.swift
//  TeltechSpamKiller
//
//  Created by DTech on 01.10.2023..
//

import Foundation
import RxSwift
import RxCocoa
import PhoneNumberKit

class AddEditBlockedViewModel: ViewModelType {
    
    struct Input {
        var loadDataSubject: ReplaySubject<()>
        let userInteractionSubject: PublishSubject<AddEditBlockedInteractionType>
    }
    
    struct Output: OutputViewModeling {
        var loaderSubject: PublishSubject<Bool>
        var errorSubject: PublishSubject<NetworkError>
        var screenData: BehaviorRelay<(String?, String?)>
        var disposables: [Disposable]
    }
    
    struct Dependencies {
        let subscribeScheduler: SchedulerType
        let name: String?
        let number: String?
        weak var addEditBlockedDelegate: AddEditBlockedDelegate?
    }
    
    var input: Input!
    var output: Output!
    let dependencies: Dependencies
    
    var isEditMode: Bool {
        return dependencies.number != nil
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func transform(input: Input) -> Output {
        var disposables = [Disposable]()
        disposables.append(initializeScreenDataObservable(for: input.loadDataSubject))
        disposables.append(initializeInteractionObservable(for: input.userInteractionSubject))
        let output = Output(loaderSubject: PublishSubject(),
                            errorSubject: PublishSubject(),
                            screenData: BehaviorRelay(value: ("", "")),
                            disposables: disposables)
        self.input = input
        self.output = output
        return output
    }
}

private extension AddEditBlockedViewModel {
    func initializeScreenDataObservable(for subject: ReplaySubject<()>) -> Disposable {
        return subject
            .flatMap { [unowned self] (_) -> Observable<(String?, String?)> in
                output.loaderSubject.onNext(true)
                return .just((dependencies.name, dependencies.number))
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
    
    func initializeInteractionObservable(for subject: PublishSubject<AddEditBlockedInteractionType>) -> Disposable {
        return subject
            .observe(on: MainScheduler.instance)
            .subscribe(on: dependencies.subscribeScheduler)
            .subscribe(onNext: { [unowned self] type in
                switch type {
                case .saveItem(let name, let phoneNumber):
                    handleSaveItem(name: name, phoneNumber: phoneNumber)
                }
            }, onError: { [unowned self] error in
                output.onError(error)
            })
    }
    
    func handleSaveItem(name: String?, phoneNumber: PhoneNumber?) {
        guard let countryCode = phoneNumber?.countryCode,
              let nationalNumber = phoneNumber?.nationalNumber else {
            return
        }
        let numberString = "\(countryCode)" + "\(nationalNumber)"
        guard let number = Int64(numberString) else { return }
        dependencies.addEditBlockedDelegate?.saveContact(name: name, number: number, isEditMode: isEditMode)
    }
}
