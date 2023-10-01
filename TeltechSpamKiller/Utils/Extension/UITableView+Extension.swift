//
//  UITableView+Extension.swift
//  TeltechSpamKiller
//
//  Created by DTech on 30.09.2023..
//

import UIKit

public extension UITableView {
    func dequeue<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Can't dequeue cell with identifier: \(String(describing: T.self))")
        }
        return cell
    }
    
    func registerCell<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: T.self))
    }
}
