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
        presenter.pushViewController(controller, animated: true)
    }
}

private extension BlockedCoordinator {
    func createBlockedController() -> BlockedViewController {
        let dependencies = BlockedViewModel.Dependencies(subscribeScheduler: RxSchedulers.concurentBackgroundScheduler, 
                                                         dataSource: BlockedDataSource(),
                                                         coordinatorDelegate: self,
                                                         addEditBlockedDelegate: self)
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

extension BlockedCoordinator: AddEditBlockedDelegate {
    func openAddEditBlockedScreen(name: String?, number: String?) {
        let dependencies = AddEditBlockedViewModel.Dependencies(subscribeScheduler: RxSchedulers.concurentBackgroundScheduler,
                                                                name: name,
                                                                number: number,
                                                                addEditBlockedDelegate: self)
        let viewModel = AddEditBlockedViewModel(dependencies: dependencies)
        let addEditScreen = AddEditBlockedViewController(viewModel: viewModel)
        presenter.pushViewController(addEditScreen, animated: true)
    }
    
    func saveContact(name: String?, number: Int64, isEditMode: Bool) {
        controller.viewModel.input.userInteractionSubject.onNext(.itemUpdated(name: name, number: number, isEditMode: isEditMode))
        presenter.popViewController(animated: true)
    }
}
