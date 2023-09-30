//
//  HomeContainerViewController.swift
//  TeltechSpamKiller
//
//  Created by DTech on 29.09.2023..
//

import UIKit
import RxSwift

class HomeContainerViewController: UITabBarController {
    
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
    }

    func initializeVM() {
        let input = HomeContainerViewModel.Input()
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
    }
}
