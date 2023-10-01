//
//  BlockedViewModel.swift
//  TeltechSpamKiller
//
//  Created by DTech on 29.09.2023..
//

import Foundation
import RxSwift
import RxCocoa
import TeltechSpamKillerData

class BlockedViewModel: ViewModelType {
    
    struct Input {
        var loadDataSubject: ReplaySubject<()>
        let userInteractionSubject: PublishSubject<BlockedInteractionType>
    }
    
    struct Output: OutputViewModeling {
        var loaderSubject: PublishSubject<Bool>
        var errorSubject: PublishSubject<NetworkError>
        var screenData: BehaviorRelay<[IdentifiableSectionItem<TeltechContact>]>
        var disposables: [Disposable]
    }
    
    struct Dependencies {
        let subscribeScheduler: SchedulerType
        let dataSource: BlockedDataSourcing
        weak var coordinatorDelegate: CoordinatorDelegate?
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

private extension BlockedViewModel {
    func initializeScreenDataObservable(for subject: ReplaySubject<()>) -> Disposable {
        return subject
            .flatMap { [unowned self] (_) -> Observable<[IdentifiableSectionItem<TeltechContact>]> in
                output.loaderSubject.onNext(true)
                return dependencies.dataSource.createData()
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
    
    func initializeInteractionObservable(for subject: PublishSubject<BlockedInteractionType>) -> Disposable {
        return subject
            .flatMap({ [unowned self] interactionType -> Observable<[IdentifiableSectionItem<TeltechContact>]> in
                switch interactionType {
                case .itemAdded(let name, let number):
                    return dependencies.dataSource.addContact(output.screenData.value, name: name, number: number)
                case .itemDeleted(let indexPath):
                    return dependencies.dataSource.deleteContact(output.screenData.value, indexPath: indexPath)
                }
            })
            .observe(on: MainScheduler.instance)
            .subscribe(on: dependencies.subscribeScheduler)
            .subscribe(onNext: { [unowned self] screenData in
                output.screenData.accept(screenData)
            }, onError: { [unowned self] error in
                output.onError(error)
            })
    }
}
