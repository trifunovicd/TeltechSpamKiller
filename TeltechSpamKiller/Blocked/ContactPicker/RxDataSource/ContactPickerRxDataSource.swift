//
//  ContactPickerRxDataSource.swift
//  TeltechSpamKiller
//
//  Created by DTech on 02.10.2023..
//

import Foundation
import RxDataSources

class ContactPickerRxDataSource {
    typealias DataSource = RxTableViewSectionedAnimatedDataSource
    
    static func dataSource() -> DataSource<IdentifiableSectionItem<Contact>> {
        return .init(configureCell: { (dataSource, tableView, indexPath, rowItem) -> UITableViewCell in
            let item = dataSource[indexPath.section].items[indexPath.row]
            let cell: ContactPickerUITableViewCell = tableView.dequeue(for: indexPath)
            cell.configure(item.item)
            return cell
        })
    }
}
