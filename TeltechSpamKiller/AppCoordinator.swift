//
//  AppCoordinator.swift
//  TeltechSpamKiller
//
//  Created by DTech on 29.09.2023..
//

import UIKit
import RxSwift

final class AppCoordinator: NSObject, Coordinator {
    weak var parentCoordinatorDelegate: ParentCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        self.presenter = UINavigationController()
        super.init()
    }
    
    func start() {
        window.rootViewController = presenter
        window.makeKeyAndVisible()
        createHomeContainerCoordinator(with: presenter)
    }
}

private extension AppCoordinator {
    func createHomeContainerCoordinator(with presenter: UINavigationController) {
        let homeContainerCoordinator = HomeContainerCoordinator(presenter: presenter)
        addChildCoordinator(homeContainerCoordinator)
        homeContainerCoordinator.parentCoordinatorDelegate = self
        homeContainerCoordinator.start()
    }
}

extension AppCoordinator: CoordinatorDelegate, ParentCoordinatorDelegate {
    func viewControllerHasFinished() {
        childCoordinators.removeAll()
        parentCoordinatorDelegate?.childHasFinished(self)
    }
    
    func childHasFinished(_ coordinator: Coordinator) {
        removeChildCoordinator(coordinator)
    }
}
