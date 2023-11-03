//
//  SearchViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/11/03.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SampleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        title = "\(Int.random(in: 1...100))"
    }
}


class SearchViewController: UIViewController {
     
    private let tableView: UITableView = {
       let view = UITableView()
        view.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        view.backgroundColor = .white
        view.rowHeight = 180
        view.separatorStyle = .none
       return view
     }()
    
    let searchBar = UISearchBar()
     
//    var items = BehaviorSubject(value: Array(100...150).map { "안녕하세요 \($0)"})
    
    let disposeBag = DisposeBag()
    
    var data = ["A", "B", "C", "AB", "BD", "DC", "FGB"]
    lazy var items = BehaviorSubject(value: data)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configure()
        bind()
        setSearchController()
    }
     
    func bind() {
        
        items   //cellForRowAt
            .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { (row, element, cell) in
                cell.appNameLabel.text = element
                cell.appIconImageView.backgroundColor = .green
                cell.downloadButton.rx.tap
                    .subscribe(with: self) { owner, _ in
                        owner.navigationController?.pushViewController(SampleViewController(), animated: true)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        //didSelectRowAt: indexPath를 알 수 있지만 각 데이터에 어떤 데이터가 있는 지 알 수 없음
//        tableView.rx.itemSelected
//            .subscribe(with: self) { owner, indexPath in
//                print(indexPath)
//            }
//            .disposed(by: disposeBag)
//        
//        //indexPath는 알 수 없지만 어떤 데이터가 있는 지 알 수 있음
//        tableView.rx.modelSelected(String.self) //어떤 데이터 타입인 지 적어주기
//            .subscribe(with: self) { owner, indexPath in
//                print(indexPath)
//            }
//            .disposed(by: disposeBag)
        
        //두 가지를 결합해서 쓰기
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
            .map { "셀 선택 \($0) \($1)" }
//            .subscribe(with: self) { owner, value in
//                print(value)
//            }
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        //SearchBar text를 배열에 추가(리턴키 클릭 시에)
        //text 옵셔널 바인딩 처리 -> 배열에 append -> reloadData로 테이블뷰에 반영
        //SearchBarDelegate searchButtonClicked
        
        searchBar.rx.searchButtonClicked  //여기까진 void 타입 반환하는 옵저버블
        //또 다른 옵저버블 가져와서 결합하는 오퍼레이터, 버튼을 클릭했을 때 데이터와 같이 넘기고자 할 때 사용
            .withLatestFrom(searchBar.rx.text.orEmpty) { void, text in
                return text
            }   //Void에서 String으로 데이터 스트림 변환
            .subscribe(with: self, onNext: { owner, value in
                owner.data.insert(value, at: 0)
                owner.items.onNext(owner.data)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)  //1초간 기다렸다가 구독
            .distinctUntilChanged() //직전 키워드랑 같음 무시한다 = 같은 값이 연달아 제공되면 무시
            .subscribe(with: self) { owner, value in
                let result = value == "" ? owner.data : owner.data.filter { $0.contains(value) }
                owner.items.onNext(result)
                
                print("==실시간 검색== \(value)")
            }
            .disposed(by: disposeBag)
        
        
        
        
        
    }
    
    private func setSearchController() {
        view.addSubview(searchBar)
        self.navigationItem.titleView = searchBar
    }

    
    private func configure() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

    }
}
