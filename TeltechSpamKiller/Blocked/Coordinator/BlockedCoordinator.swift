//
//  BlockedCoordinator.swift
//  TeltechSpamKiller
//
//  Created by DTech on 29.09.2023..
//

import UIKit
import RxSwift

final class BlockedCoordinator: NSObject, Coordinator {
    weak var parentCoordinatorDelegate: ParentCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    var controller: BlockedViewController!
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        super.init()
        self.controller = createBlockedController()
    }
    
    func start() {
        presenter.setNavigationBarHidden(false, animated: true)
        presenter.pushViewController(controller, animated: true)
    }
}

private extension BlockedCoordinator {
    func createBlockedController() -> BlockedViewController {
        let dependencies = BlockedViewModel.Dependencies(subscribeScheduler: RxSchedulers.concurentBackgroundScheduler, coordinatorDelegate: self)
        let viewModel = BlockedViewModel(dependencies: dependencies)
        let viewController = BlockedViewController(viewModel: viewModel)
        return viewController
    }
}

extension BlockedCoordinator: CoordinatorDelegate, ParentCoordinatorDelegate {
    func viewControllerHasFinished() {
        childCoordinators.removeAll()
        parentCoordinatorDelegate?.childHasFinished(self)
    }
    
    func childHasFinished(_ coordinator: Coordinator) {
        removeChildCoordinator(coordinator)
    }
}
