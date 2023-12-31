//
//  BlockedViewController.swift
//  TeltechSpamKiller
//
//  Created by DTech on 29.09.2023..
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import TeltechSpamKillerData

final class BlockedViewController: UIViewController, Loading, Erroring {
    let disposeBag = DisposeBag()
    let viewModel: BlockedViewModel
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .white
        view.estimatedRowHeight = UITableView.automaticDimension
        view.rowHeight = UITableView.automaticDimension
        view.registerCell(BlockedUITableViewCell.self)
        view.refreshControl = refreshControl
        return view
    }()
    
    private lazy var contactsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.plus"), style: .plain, target: self, action: nil)
        return button
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        return button
    }()
    
    lazy var refreshControl: UIRefreshControl? = {
        let view = UIRefreshControl()
        return view
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        return view
    }()
    
    init(viewModel: BlockedViewModel) {
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
        observeInputs()
        viewModel.input.checkExtensionSubject.onNext(())
        viewModel.input.loadDataSubject.onNext(.initial)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = R.string.localizable.blocked()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent{
            viewModel.dependencies.coordinatorDelegate?.viewControllerHasFinished()
        }
    }
}

private extension BlockedViewController {
    func setupUI() {
        navigationItem.leftBarButtonItem = contactsButton
        navigationItem.rightBarButtonItem = addButton
        view.addSubview(tableView)
        setConstraints()
    }
    
    func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}

private extension BlockedViewController {
    func initializeVM() {
        let input = BlockedViewModel.Input(checkExtensionSubject: ReplaySubject.create(bufferSize: 1),
                                           loadDataSubject: ReplaySubject.create(bufferSize: 1),
                                           userInteractionSubject: PublishSubject())
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
        bindDataSource(for: output.screenData)
        initializeLoaderObserver(for: output.loaderSubject)
        initializeErrorObserver(for: output.errorSubject)
    }
    
    func bindDataSource(for relay: BehaviorRelay<[IdentifiableSectionItem<TeltechContact>]>) {
        let dataSource = BlockedRxDataSource.dataSource()
        relay.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    func observeInputs() {
        subscribeToContactsAction()
        subscribeToAddAction()
        subscribeToPullToRefreshAction()
        subscribeToTapAction()
        subscribeToDeleteAction()
    }
    
    func subscribeToContactsAction() {
        contactsButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.input.userInteractionSubject.onNext(.contactsTapped)
        }).disposed(by: disposeBag)
    }
    
    func subscribeToAddAction() {
        addButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.input.userInteractionSubject.onNext(.addTapped)
        }).disposed(by: disposeBag)
    }
    
    func subscribeToPullToRefreshAction() {
        tableView.refreshControl?.rx.controlEvent(.valueChanged)
        .subscribe(onNext: { [weak self] in
            self?.viewModel.input.loadDataSubject.onNext(.pullToRefresh)
        })
        .disposed(by: disposeBag)
    }
    
    func subscribeToTapAction() {
        tableView.rx.itemSelected
        .subscribe(onNext: { [weak self] in
            self?.viewModel.input.userInteractionSubject.onNext(.itemTapped($0))
        })
        .disposed(by: disposeBag)
    }
    
    func subscribeToDeleteAction() {
        tableView.rx.itemDeleted
        .subscribe(onNext: { [weak self] in
            self?.viewModel.input.userInteractionSubject.onNext(.itemDeleted($0))
        })
        .disposed(by: disposeBag)
    }
}
