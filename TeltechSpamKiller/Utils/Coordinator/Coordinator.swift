//
//  Coordinator.swift
//  TeltechSpamKiller
//
//  Created by DTech on 28.09.2023..
//

import UIKit

public protocol Coordinator: AnyObject {
    var parentCoordinatorDelegate: ParentCoordinatorDelegate? { get }
    var childCoordinators: [Coordinator] { get set }
    var presenter: UINavigationController { get }
    func start()
}

public extension Coordinator {
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}
