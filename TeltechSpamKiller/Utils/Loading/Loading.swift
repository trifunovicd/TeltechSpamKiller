//
//  Loading.swift
//  TeltechSpamKiller
//
//  Created by DTech on 01.10.2023..
//

import UIKit
import RxSwift
import SnapKit

public protocol Loading: AnyObject {
    var disposeBag: DisposeBag { get }
    var activityIndicator: UIActivityIndicatorView { get }
    var refreshControl: UIRefreshControl? { get }
    
    func initializeLoaderObserver(for loaderObservable: Observable<Bool>)
}

extension Loading where Self: UIViewController {
    func initializeLoaderObserver(for loaderObservable: Observable<Bool>) {
        loaderObservable
            .asDriver(onErrorJustReturn: false)
            .do(onNext: { [unowned self] (showLoader) in
                if showLoader {
                    showLoadingView()
                } else {
                    hideLoadingView()
                }
            })
            .drive()
            .disposed(by: disposeBag)
    }
    
    func showLoadingView() {
        DispatchQueue.main.async { [unowned self] in
            view.addSubview(activityIndicator)
            
            activityIndicator.snp.makeConstraints { make in
                make.centerX.centerY.equalToSuperview()
            }
            
            activityIndicator.startAnimating()
        }
    }
    
    func hideLoadingView() {
        DispatchQueue.main.async { [unowned self] in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            refreshControl?.endRefreshing()
        }
    }
}
