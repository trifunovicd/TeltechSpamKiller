//
//  BlockedInteractionType.swift
//  TeltechSpamKiller
//
//  Created by DTech on 30.09.2023..
//

import Foundation

enum BlockedInteractionType {
    case addTapped
    case itemTapped(_ indexPath: IndexPath)
    case itemUpdated(name: String?, number: Int64, isEditMode: Bool)
    case itemDeleted(_ indexPath: IndexPath)
}
