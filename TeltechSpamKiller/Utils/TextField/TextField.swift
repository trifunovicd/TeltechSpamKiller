//
//  TextField.swift
//  TeltechSpamKiller
//
//  Created by DTech on 01.10.2023..
//

import UIKit

class TextField: UITextField {
    let insets: UIEdgeInsets
    
    init(_ insets: UIEdgeInsets = .zero) {
        self.insets = insets
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }
}

extension UITextField {
    func setStyle() {
        textColor = .black
        tintColor = .black
        backgroundColor = .white
        font = .systemFont(ofSize: 24, weight: .medium)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
    }
}
