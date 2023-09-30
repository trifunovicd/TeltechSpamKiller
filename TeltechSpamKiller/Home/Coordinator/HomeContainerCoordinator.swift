//
//  HomeContainerCoordinator.swift
//  TeltechSpamKiller
//
//  Created by DTech on 29.09.2023..
//

import UIKit
import RxSwift

final class HomeContainerCoordinator: NSObject, Coordinator {
    weak var parentCoordinatorDelegate: ParentCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    var controller: HomeContainerViewController!
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        super.init()
        self.controller = createHomeContainerController()
    }
    
    func start() {
        presenter.setNavigationBarHidden(true, animated: true)
        presenter.pushViewController(controller, animated: true)
    }
}

private extension HomeContainerCoordinator {
    func createHomeContainerController() -> HomeContainerViewController {
        let dependencies = HomeContainerViewModel.Dependencies(subscribeScheduler: RxSchedulers.concurentBackgroundScheduler)
        let viewModel = HomeContainerViewModel(dependencies: dependencies)
        let viewController = HomeContainerViewController(viewModel: viewModel)
        let recentsCoordinator = createRecentsCoordinator()
        let blockedCoordinator = createBlockedCoordinator()
        viewController.setViewControllers([recentsCoordinator.presenter,
                                           blockedCoordinator.presenter],
                                          animated: true)
        childCoordinators.append(recentsCoordinator)
        childCoordinators.append(blockedCoordinator)
        recentsCoordinator.start()
        blockedCoordinator.start()
        viewController.selectedIndex = 0
        return viewController
    }
    
    func createRecentsCoordinator() -> Coordinator {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Recents", image: UIImage(systemName: "clock"), selectedImage: UIImage(systemName: "clock.fill"))
        let recentsCoordinator = RecentsCoordinator(presenter: navigationController)
        recentsCoordinator.parentCoordinatorDelegate = self
        return recentsCoordinator
    }
    
    func createBlockedCoordinator() -> Coordinator {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Blocked", image: UIImage(systemName: "person.crop.circle"), selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        let blockedCoordinator = BlockedCoordinator(presenter: navigationController)
        blockedCoordinator.parentCoordinatorDelegate = self
        return blockedCoordinator
    }
}

extension HomeContainerCoordinator: CoordinatorDelegate, ParentCoordinatorDelegate {
    func viewControllerHasFinished() {
        childCoordinators.removeAll()
        parentCoordinatorDelegate?.childHasFinished(self)
    }
    
    func childHasFinished(_ coordinator: Coordinator) {
        removeChildCoordinator(coordinator)
    }
}
