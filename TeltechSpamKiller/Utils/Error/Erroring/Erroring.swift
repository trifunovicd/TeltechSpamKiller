//
//  Erroring.swift
//  TeltechSpamKiller
//
//  Created by DTech on 01.10.2023..
//

import UIKit
import RxSwift

public protocol Erroring: AnyObject {
    var disposeBag: DisposeBag { get }
    
    func initializeErrorObserver(for errorObservable: Observable<NetworkError>)
}

extension Erroring where Self: UIViewController {
    func initializeErrorObserver(for errorObservable: Observable<NetworkError>) {
        errorObservable
            .asDriver(onErrorJustReturn: .generalError)
            .do(onNext: { [unowned self] value in
                switch value {
                case .generalError:
                    presentAlert(title: R.string.localizable.general_error_title(), message: R.string.localizable.general_error_message())
                case .parseError:
                    presentAlert(title: R.string.localizable.parse_error_title(), message: R.string.localizable.parse_error_message())
                }
            })
            .drive()
            .disposed(by: disposeBag)
    }
    
    func presentAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.general_error_action(), style: .cancel))
        present(alert, animated: true, completion: nil)
    }
}
