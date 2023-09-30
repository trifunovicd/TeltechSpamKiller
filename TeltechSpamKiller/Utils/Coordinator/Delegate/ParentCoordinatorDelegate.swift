//
//  ParentCoordinatorDelegate.swift
//  TeltechSpamKiller
//
//  Created by DTech on 28.09.2023..
//

import Foundation

public protocol ParentCoordinatorDelegate: AnyObject {
    func childHasFinished(_ coordinator: Coordinator)
}
