//
//  BlockedUITableViewCell.swift
//  TeltechSpamKiller
//
//  Created by DTech on 30.09.2023..
//

import Foundation
import SnapKit
import TeltechSpamKillerData

class BlockedUITableViewCell: UITableViewCell {
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ contact: TeltechContact) {
        numberLabel.text = PhoneFormatService.shared.getFormattedPhoneString(number: contact.number)
        let nameExist: Bool
        if let name = contact.name, !name.isEmpty {
            nameLabel.text = name
            numberLabel.font = .systemFont(ofSize: 16)
            nameExist = true
        } else {
            nameLabel.text = nil
            numberLabel.font = .boldSystemFont(ofSize: 20)
            nameExist = false
        }
        updateConstraints(nameExist: nameExist)
    }
}

private extension BlockedUITableViewCell {
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .white
        contentView.backgroundColor = .white
        contentView.addSubviews(nameLabel, numberLabel)
        setConstraints()
    }
    
    func setConstraints() {
        nameLabel.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        numberLabel.snp.remakeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
    
    func updateConstraints(nameExist: Bool) {
        if nameExist {
            if !contentView.subviews.contains(nameLabel) {
                contentView.addSubviews(nameLabel)
            }
            setConstraints()
        } else {
            nameLabel.removeFromSuperview()
            numberLabel.snp.remakeConstraints { make in
                make.top.bottom.leading.trailing.equalToSuperview().inset(16)
            }
        }
    }
}
