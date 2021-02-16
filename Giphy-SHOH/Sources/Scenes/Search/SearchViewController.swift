//
//  SearchViewController.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import UIKit
import RxCocoa
import SnapKit
import ReactorKit
import Kingfisher

final class SearchViewController: BaseViewController {
    
    private enum Constants {
        static let SearchTypeViewWidth: CGFloat = 100
        static let TypeButtonWidthPadding: CGFloat = 50
        static let EmptyWidth: CGFloat = 30
    }
    
    @IBOutlet private weak var searchTextField: CustomTextField!
    @IBOutlet private weak var searchBtn: UIButton!
    @IBOutlet private weak var searchTypeSV: UIStackView!
    
    @IBOutlet private weak var collectionView: ResultCollectionView!
    
    private var trendingVC: TrendingViewController?
    private let autoCompleteVC = AutoCompleteViewController.storyboard()
    
    private let searchTypeSelectView = UIView().then {
        $0.layer.cornerRadius = 25
        $0.backgroundColor = SearchType.GIFs.buttonColor
        $0.clipsToBounds = true
        $0.isHidden = true
        $0.isUserInteractionEnabled = false
    }
    
    private var centerX: Constraint?
    private var width: Constraint?
    
    private var sharedShowKeyboard: Observable<Void> {
        return NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .map { _ in }
            .share(replay: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchTypeSelectView()
        setupTrending()
        setupAutoComplete()
        setupSearchResult()
    }
    
    override func actionBackButton() {
        self.didPop()
        super.actionBackButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchTextField.resignFirstResponder()
    }
    
}

// MARK: - Binding

extension SearchViewController: StoryboardView {
    
    func bind(reactor: SearchViewReactor) {
        bindKeyboard(reactor)
        bindTitle(reactor)
        bindTextField(reactor)
        bindTypeButtons(reactor)
        bindNavigation(reactor)
    }
    
    private func bindNavigation(_ reactor:  SearchViewReactor) {
        rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in !reactor.isSearchResult }
            .filter { $0 }
            .asDriverOnEmpty()
            .drive(reactor.navigation.rx.hiddenBarButton)
            .disposed(by: disposeBag)
        
        reactor.pushControlRelay
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] in self?.didPush($0) })
            .disposed(by: disposeBag)
    }
    
    private func bindKeyboard(_ reactor: SearchViewReactor) {
        Observable.merge(
            sharedShowKeyboard
                .map { _ in false },
            NotificationCenter.default.rx
                .notification(UIResponder.keyboardWillHideNotification)
                .map { _ in true }
        )
        .filter { _ in !reactor.isSearchResult }
        .distinctUntilChanged()
        .asDriverOnEmpty()
        .drive(reactor.navigation.rx.hiddenBarButton)
        .disposed(by: disposeBag)
    }
    
    private func bindTitle(_ reactor: SearchViewReactor) {
        reactor.state.map { $0.searchedKeyword }
            .filter { $0.isCurrentVCIndex(reactor.getCurrentVCIndex()) }
            .map { $0.data }
            .distinctUntilChanged()
            .filter { _ in reactor.isSearchResult }
            .asDriverOnEmpty()
            .drive(rx.title)
            .disposed(by: disposeBag)
    }
    
    private func bindTextField(_ reactor: SearchViewReactor) {
        Observable.merge(
            sharedShowKeyboard,
            searchTextField.rx
                .controlEvent(.editingChanged)
                .asObservable()
        )
        .withLatestFrom(searchTextField.rx.text.orEmpty)
        .map { Reactor.Action.enterKeyword($0)}
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        Observable.merge(
            searchTextField.rx
                .controlEvent(.editingDidEndOnExit)
                .asObservable(),
            searchBtn.rx.tap
                .asObservable()
        )
        .withLatestFrom(reactor.state.map { $0.curKeyword.data ?? "" })
        .observeOn(MainScheduler.instance)
        .bind(onNext: { [weak self] in self?.didPush($0) })
        .disposed(by: disposeBag)
    }
    
    private func bindTypeButtons(_ reactor: SearchViewReactor) {
        let buttons = makeAndSetupTypeButtons(reactor,
                                              sv: searchTypeSV)
        Observable.merge(buttons)
            .distinctUntilChanged()
            .map { Reactor.Action.didTapTypeButton($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.searchType }
            .filter { $0.isCurrentVCIndex(reactor.getCurrentVCIndex()) }
            .map { $0.data }
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] in self?.didClickSearchType($0) })
            .disposed(by: disposeBag)
    }
}

// MARK: - Setup UI

extension SearchViewController {
    
    private func setupTrending() {
        guard let reactor = self.reactor,
              !reactor.isSearchResult else { return }
        
        let trendingRreactor = TrendingViewReactor(reactor)
        self.trendingVC = TrendingViewController(trendingRreactor)
        
        if let trendingVC = self.trendingVC {
            addChild(trendingVC)
            view.addSubview(trendingVC.view)
            trendingVC.view.snp.makeConstraints {
                $0.edges.equalTo(collectionView)
            }
        }
    }
    
    private func setupAutoComplete() {
        guard let reactor = self.reactor else { return }
        autoCompleteVC.reactor = AutoCompleteViewReactor(
            reactor,
            useCase: reactor.useCase,
            curKeyword: reactor.currentState.curKeyword.data
        )
        
        autoCompleteVC.view.isHidden = true
        addChild(autoCompleteVC)
        view.addSubview(autoCompleteVC.view)
        autoCompleteVC.view.snp.makeConstraints {
            $0.edges.equalTo(collectionView)
        }
    }
    
    private func setupSearchResult() {
        guard let reactor = self.reactor,
              reactor.isSearchResult else { return }
        
        let resultCVReactor = ResultCollectionViewReactor(reactor)
        collectionView.setup()
        collectionView.reactor = resultCVReactor
        
        searchTextField.text = reactor.currentState.searchedKeyword.data
    }
    
    private func makeAndSetupTypeButtons(_ reactor: SearchViewReactor,
                                         sv: UIStackView) -> [Observable<SearchType>] {
        makeAndSetupEmptyView(sv)
        
        let buttons = SearchType.allCases.map { (type) -> Observable<SearchType> in
            let btnReactor = TypeButtonReactor(
                title: type.buttonTitle,
                color: type.buttonColor
            )
            let button = TypeButton.nib().then {
                $0.reactor = btnReactor
                $0.layer.zPosition = 1
                let width = $0.titleSize.width + Constants.TypeButtonWidthPadding
                sv.addArrangedSubview($0)
                $0.snp.makeConstraints { m in
                    m.width.equalTo(width)
                    m.height.equalToSuperview()
                }
            }
            
            return button.rx.tap.map { type }
        }
        
        makeAndSetupEmptyView(sv)
        
        return buttons
    }
    
    private func makeAndSetupEmptyView(_ sv: UIStackView) {
        _ = UIView().then {
            sv.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalTo(Constants.EmptyWidth).priority(999)
            }
        }
    }
    
    private func setupSearchTypeSelectView() {
        let searchType = reactor?.currentState.searchType.data ?? .GIFs
        let initCenterXConst: CGFloat = searchTypeSV
            .arrangedSubviews[safe: searchType.rawValue]?.center.x ?? 0
        
        searchTypeSV.addSubview(searchTypeSelectView)
        searchTypeSelectView.snp.makeConstraints {
            $0.top.bottom.equalTo(searchTypeSV)
            centerX = $0.centerX.equalTo(searchTypeSV.snp.leading).offset(initCenterXConst).constraint
            width = $0.width.equalTo(Constants.SearchTypeViewWidth).constraint
        }
    }
    
}

// MARK: - Control UI Events

extension SearchViewController {
    private func didClickSearchType(_ searchType: SearchType) {
        guard let curBtn = self.searchTypeSV
                .arrangedSubviews[safe: searchType.rawValue] as? TypeButton else {
            return
        }
        
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut) {
            self.searchTypeSelectView.backgroundColor = curBtn.reactor?.currentState.color
            self.centerX?.update(offset: curBtn.center.x)
            self.width?.update(offset: curBtn.titleSize.width + Constants.TypeButtonWidthPadding)
            self.searchTypeSV.layoutIfNeeded()
        }
        
        if self.searchTypeSelectView.isHidden {
            self.searchTypeSelectView.isHidden = false
        }
    }
    
    private func didPop() {
        guard let reactor = self.reactor else { return }
        
        if !reactor.isSearchResult {
            self.searchTextField.resignFirstResponder()
            return
        }
    }
    
    private func didPush(_ keyword: String) {
        guard let reactor = self.reactor else { return }
        
        self.autoCompleteVC.view.isHidden = true
        self.searchTextField.resignFirstResponder()
        self.searchTextField.text = reactor.currentState.curKeyword.data
        
        let searchResultVC = SearchViewController.storyboard()
        searchResultVC.reactor = SearchViewReactor(reactor)
        let completion: () -> () = {
            searchResultVC.reactor?.action.onNext(.enterSearchKeyword(keyword))
        }
        reactor.navigation.pushViewController(
            searchResultVC,
            completion: completion
        )
    }
}
