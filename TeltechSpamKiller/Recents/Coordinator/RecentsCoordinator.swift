//
//  RecentsCoordinator.swift
//  TeltechSpamKiller
//
//  Created by DTech on 29.09.2023..
//

import UIKit
import RxSwift

final class RecentsCoordinator: NSObject, Coordinator {
    weak var parentCoordinatorDelegate: ParentCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    var controller: RecentsViewController!
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        super.init()
        self.controller = createRecentsController()
    }
    
    func start() {
        presenter.setNavigationBarHidden(false, animated: true)
        presenter.pushViewController(controller, animated: true)
    }
}

private extension RecentsCoordinator {
    func createRecentsController() -> RecentsViewController {
        let dependencies = RecentsViewModel.Dependencies(subscribeScheduler: RxSchedulers.concurentBackgroundScheduler, coordinatorDelegate: self)
        let viewModel = RecentsViewModel(dependencies: dependencies)
        let viewController = RecentsViewController(viewModel: viewModel)
        return viewController
    }
}

extension RecentsCoordinator: CoordinatorDelegate, ParentCoordinatorDelegate {
    func viewControllerHasFinished() {
        childCoordinators.removeAll()
        parentCoordinatorDelegate?.childHasFinished(self)
    }
    
    func childHasFinished(_ coordinator: Coordinator) {
        removeChildCoordinator(coordinator)
    }
}
