//
//  HomeContainerViewController.swift
//  TeltechSpamKiller
//
//  Created by DTech on 29.09.2023..
//

import UIKit
import RxSwift
import CallKit

class HomeContainerViewController: UITabBarController, Erroring {
    
    var disposeBag = DisposeBag()
    let viewModel: HomeContainerViewModel
    
    init(viewModel: HomeContainerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeVM()
        viewModel.input.loadDataSubject.onNext(())
    }

    func initializeVM() {
        let input = HomeContainerViewModel.Input(loadDataSubject: ReplaySubject.create(bufferSize: 1))
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
        initializeErrorObserver(for: output.errorSubject)
    }
    
    func presentAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: R.string.localizable.general_error_action(), style: .cancel))
        alert.addAction(UIAlertAction(title: R.string.localizable.go_to_settings(), style: .default, handler: { action in
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
        }))
        present(alert, animated: true, completion: nil)
    }
}
