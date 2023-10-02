//
//  ContactPickerUITableViewCell.swift
//  TeltechSpamKiller
//
//  Created by DTech on 02.10.2023..
//

import UIKit

class ContactPickerUITableViewCell: UITableViewCell {
    
    private lazy var nameInitialView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var nameInitialLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ contact: Contact) {
        let nameInitial = String(contact.fullName.prefix(1))
        nameInitialLabel.text = nameInitial.uppercased()
        nameLabel.text = contact.fullName
        contentView.backgroundColor = contact.isBlocked ? .systemRed.withAlphaComponent(0.2) : .white
    }
}

private extension ContactPickerUITableViewCell {
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .white
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.addSubviews(nameInitialView, nameLabel)
        nameInitialView.addSubview(nameInitialLabel)
        setConstraints()
    }
    
    func setConstraints() {
        nameInitialView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(12)
            make.size.equalTo(32)
        }
        
        nameInitialLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        nameLabel.snp.remakeConstraints { make in
            make.leading.equalTo(nameInitialView.snp.trailing).offset(12)
            make.top.greaterThanOrEqualToSuperview().inset(12)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
            make.centerY.equalTo(nameInitialView)
            make.trailing.equalToSuperview().inset(12)
        }
    }
}
