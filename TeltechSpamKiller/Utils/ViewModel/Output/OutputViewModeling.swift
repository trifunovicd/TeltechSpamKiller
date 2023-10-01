//
//  OutputViewModeling.swift
//  TeltechSpamKiller
//
//  Created by DTech on 30.09.2023..
//

import Foundation
import RxSwift

public protocol OutputViewModeling {
    var loaderSubject: PublishSubject<Bool> { get }
    var errorSubject: PublishSubject<NetworkError> { get }
    
    func onError(_ error: Error)
}

public extension OutputViewModeling {
    func onError(_ error: Error) {
        loaderSubject.onNext(false)
        if let networkError = error as? NetworkError {
            errorSubject.onNext(networkError)
        } else {
            errorSubject.onNext(NetworkError.generalError)
        }
    }
}
