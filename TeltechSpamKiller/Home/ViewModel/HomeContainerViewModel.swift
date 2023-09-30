//
//  HomeContainerViewModel.swift
//  TeltechSpamKiller
//
//  Created by DTech on 29.09.2023..
//

import Foundation
import RxSwift

class HomeContainerViewModel: ViewModelType {
    
    struct Input {
        
    }
    
    struct Output {
        var disposables: [Disposable]
    }
    
    struct Dependencies {
        let subscribeScheduler: SchedulerType
    }
    
    var input: Input!
    var output: Output!
    let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func transform(input: Input) -> Output {
        let disposables = [Disposable]()
        let output = Output(disposables: disposables)
        self.input = input
        self.output = output
        return output
    }
}
