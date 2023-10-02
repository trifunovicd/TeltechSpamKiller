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
        self.applyTheme()
    }
    
    func start() {
        window.rootViewController = presenter
        window.makeKeyAndVisible()
        createBlockedCoordinator(with: presenter)
    }
}

private extension AppCoordinator {
    func createBlockedCoordinator(with presenter: UINavigationController) {
        let blockedCoordinator = BlockedCoordinator(presenter: presenter)
        addChildCoordinator(blockedCoordinator)
        blockedCoordinator.parentCoordinatorDelegate = self
        blockedCoordinator.start()
    }
    
    func applyTheme() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor.white
        navigationBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.black
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.black
        ]
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
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
