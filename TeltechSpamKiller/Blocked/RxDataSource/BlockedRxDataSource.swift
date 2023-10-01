//
//  BlockedRxDataSource.swift
//  TeltechSpamKiller
//
//  Created by DTech on 30.09.2023..
//

import Foundation
import RxDataSources
import TeltechSpamKillerData

class BlockedRxDataSource {
    typealias DataSource = RxTableViewSectionedAnimatedDataSource
    
    static func dataSource() -> DataSource<IdentifiableSectionItem<TeltechContact>> {
        return .init(configureCell: { (dataSource, tableView, indexPath, rowItem) -> UITableViewCell in
            let item = dataSource[indexPath.section].items[indexPath.row]
            let cell: BlockedUITableViewCell = tableView.dequeue(for: indexPath)
            cell.configure(item.item)
            return cell
        }, canEditRowAtIndexPath: { dataSource, indexPath in
            return true
        })
    }
}
