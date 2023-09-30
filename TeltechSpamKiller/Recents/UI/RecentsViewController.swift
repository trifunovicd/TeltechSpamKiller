//
//  RecentsViewController.swift
//  TeltechSpamKiller
//
//  Created by DTech on 29.09.2023..
//

import UIKit
import RxSwift

class RecentsViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel: RecentsViewModel
    
    init(viewModel: RecentsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initializeVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = navigationController?.tabBarItem.title
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent{
            viewModel.dependencies.coordinatorDelegate?.viewControllerHasFinished()
        }
    }

    func initializeVM() {
        let input = RecentsViewModel.Input()
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
    }
}
