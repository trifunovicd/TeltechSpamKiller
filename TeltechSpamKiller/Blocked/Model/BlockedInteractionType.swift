//
//  BlockedInteractionType.swift
//  TeltechSpamKiller
//
//  Created by DTech on 30.09.2023..
//

import Foundation

enum BlockedInteractionType {
    case itemAdded(name: String, number: Int64)
    case itemDeleted(_ indexPath: IndexPath)
}
