//
//  AddEditBlockedViewController.swift
//  TeltechSpamKiller
//
//  Created by DTech on 01.10.2023..
//

import UIKit
import SnapKit
import PhoneNumberKit
import RxSwift
import RxCocoa

protocol AddEditBlockedDelegate: AnyObject {
    func openAddEditBlockedScreen(name: String?, number: String?)
    func saveContact(name: String?, number: Int64, isEditMode: Bool)
}

final class AddEditBlockedViewController: UIViewController, Loading, Erroring {
    let disposeBag = DisposeBag()
    let viewModel: AddEditBlockedViewModel
    var refreshControl: UIRefreshControl?
    
    private lazy var nameInputView: TextField = {
        let view = TextField(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        view.attributedPlaceholder = NSAttributedString(
            string: R.string.localizable.name_placeholder(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray.withAlphaComponent(0.5)]
        )
        view.setStyle()
        return view
    }()
    
    private lazy var numberInputView: PhoneNumberTextField = {
        let view = PhoneNumberTextField(insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), clearButtonPadding: 0)
        view.withPrefix = true
        view.withExamplePlaceholder = true
        view.countryCodePlaceholderColor = .lightGray
        view.numberPlaceholderColor = .lightGray.withAlphaComponent(0.5)
        view.setStyle()
        return view
    }()
    
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: nil)
        return button
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        return view
    }()
    
    init(viewModel: AddEditBlockedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.isEditMode ? R.string.localizable.edit_contact() : R.string.localizable.add_contact()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initializeVM()
        observeInputs()
        viewModel.input.loadDataSubject.onNext(())
    }
}

private extension AddEditBlockedViewController {
    func setupUI() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = saveButton
        view.addSubviews(nameInputView, numberInputView)
        setupConstraints()
    }
    
    func setupConstraints() {
        nameInputView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        numberInputView.snp.makeConstraints { make in
            make.top.equalTo(nameInputView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}

private extension AddEditBlockedViewController {
    func initializeVM() {
        let input = AddEditBlockedViewModel.Input(loadDataSubject: ReplaySubject.create(bufferSize: 1),
                                                  userInteractionSubject: PublishSubject())
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
        observeScreenData(for: output.screenData)
        initializeLoaderObserver(for: output.loaderSubject)
        initializeErrorObserver(for: output.errorSubject)
    }
    
    func observeScreenData(for relay: BehaviorRelay<(String?, String?)>) {
        relay
            .asDriver(onErrorJustReturn: (nil, nil))
            .do(onNext: { [unowned self] (name, number) in
                nameInputView.text = name
                numberInputView.setTextUnformatted(newValue: number)
            })
            .drive()
            .disposed(by: disposeBag)
    }
    
    func observeInputs() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        subscribeToTextInputs()
        subscribeToSaveAction()
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    func subscribeToTextInputs() {
        let nameObservable = nameInputView.rx.text.orEmpty.distinctUntilChanged().asObservable()
        let numberObservable = numberInputView.rx.text.orEmpty.distinctUntilChanged().asObservable()
        Observable.combineLatest(nameObservable, numberObservable).subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.saveButton.isEnabled = self.numberInputView.isValidNumber
        }).disposed(by: disposeBag)
    }
    
    func subscribeToSaveAction() {
        saveButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.viewModel.input.userInteractionSubject.onNext(.saveItem(name: self.nameInputView.text, phoneNumber: self.numberInputView.phoneNumber))
        }).disposed(by: disposeBag)
    }
}
