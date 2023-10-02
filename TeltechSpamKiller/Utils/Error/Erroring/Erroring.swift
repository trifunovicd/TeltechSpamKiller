//
//  Erroring.swift
//  TeltechSpamKiller
//
//  Created by DTech on 01.10.2023..
//

import UIKit
import RxSwift
import CallKit

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
                case .extensionError:
                    presentAlert(title: R.string.localizable.call_directory_extension_error_title(), message: R.string.localizable.call_directory_extension_error_message(), preferredStyle: .actionSheet)
                }
            })
            .drive()
            .disposed(by: disposeBag)
    }
    
    func presentAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: R.string.localizable.general_error_action(), style: .cancel))
        if preferredStyle == .actionSheet {
            alert.addAction(UIAlertAction(title: R.string.localizable.go_to_settings(), style: .default, handler: { [weak self] _ in
                self?.goToSettings()
            }))
        }
        present(alert, animated: true, completion: nil)
    }
    
    func goToSettings() {
        if #available(iOS 13.4, *) {
            CXCallDirectoryManager.sharedInstance.openSettings { (error) in
                if let error = error {
                    print("Error fetching status: \(error.localizedDescription)")
                }
            }
        } else {
            if let url = URL(string:UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
