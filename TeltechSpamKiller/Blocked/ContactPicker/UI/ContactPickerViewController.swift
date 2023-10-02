//
//  ContactPickerViewController.swift
//  TeltechSpamKiller
//
//  Created by DTech on 02.10.2023..
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol ContactPickerDelegate: AnyObject {
    func openContactPickerScreen()
    func saveContact(name: String?, number: Int64)
}

final class ContactPickerViewController: UIViewController, Loading, Erroring {
    let disposeBag = DisposeBag()
    let viewModel: ContactPickerViewModel
    var refreshControl: UIRefreshControl?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.numberOfLines = 0
        label.text = R.string.localizable.select_contact()
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .white
        view.estimatedRowHeight = UITableView.automaticDimension
        view.rowHeight = UITableView.automaticDimension
        view.registerCell(ContactPickerUITableViewCell.self)
        return view
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        return view
    }()
    
    init(viewModel: ContactPickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        initializeVM()
        subscribeToTapAction()
        viewModel.input.loadDataSubject.onNext(())
    }
}

private extension ContactPickerViewController {
    func setupUI() {
        view.addSubviews(titleLabel, tableView)
        setConstraints()
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}

private extension ContactPickerViewController {
    func initializeVM() {
        let input = ContactPickerViewModel.Input(loadDataSubject: ReplaySubject.create(bufferSize: 1),
                                                 userInteractionSubject: PublishSubject())
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
        bindDataSource(for: output.screenData)
        initializeLoaderObserver(for: output.loaderSubject)
        initializeErrorObserver(for: output.errorSubject)
    }
    
    func bindDataSource(for relay: BehaviorRelay<[IdentifiableSectionItem<Contact>]>) {
        let dataSource = ContactPickerRxDataSource.dataSource()
        relay.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    func subscribeToTapAction() {
        tableView.rx.itemSelected
        .subscribe(onNext: { [weak self] in
            self?.viewModel.input.userInteractionSubject.onNext(.itemTapped($0))
        })
        .disposed(by: disposeBag)
    }
}
