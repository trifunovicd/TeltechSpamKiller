//
//  UIView+Extension.swift
//  TeltechSpamKiller
//
//  Created by DTech on 30.09.2023..
//

import UIKit

public extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
