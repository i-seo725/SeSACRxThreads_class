//
//  SignUpViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SignUpViewController: UIViewController {
    
    let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    let validationButton = UIButton()
    let nextButton = PointButton(title: "다음")
    
    let disposeBag = DisposeBag()
    
    enum EunseoError: Error {
        case gunpodo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.white
        
        configureLayout()
        configure()
        
        nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
        
        //        disposeExample()
        //        incrementExample()
        //        aboutPublishSubject()
//        aboutBehaviorSubject()
//        aboutReplaySubject()
        aboutAsyncSubject()
    }
    
    func aboutAsyncSubject() {
        
        let publish = AsyncSubject<Int>()
        
        publish.onNext(20)
        publish.onNext(810)
        publish.onNext(143)
        publish.onNext(900)
        publish.onNext(443) //버퍼 사이즈를 가져서 구독하기 전에 몇 개의 데이터를 방출할 지.. 정할 수 있음...
        
        publish
            .subscribe(with: self) { owner, value in
                print("PublishSubject - \(value)")
            } onError: { owner, error in
                print("PublishSubject error - \(error)")
            } onCompleted: { owner in
                print("PublishSubject completed")
            } onDisposed: { owner in
                print("PublishSubject disposed")
            }
            .disposed(by: disposeBag)
        
        publish.onNext(8)
        publish.on(.next(199))
        publish.onNext(123)
        
        publish.onCompleted()
        
        publish.onNext(292)
        publish.onNext(5555)
    }
    
    func aboutReplaySubject() {
        
        let publish = ReplaySubject<Int>.create(bufferSize: 3)
        
        publish.onNext(20)
        publish.onNext(810)
        publish.onNext(143)
        publish.onNext(900)
        publish.onNext(443) //버퍼 사이즈를 가져서 구독하기 전에 몇 개의 데이터를 방출할 지.. 정할 수 있음...
        
        publish
            .subscribe(with: self) { owner, value in
                print("PublishSubject - \(value)")
            } onError: { owner, error in
                print("PublishSubject error - \(error)")
            } onCompleted: { owner in
                print("PublishSubject completed")
            } onDisposed: { owner in
                print("PublishSubject disposed")
            }
            .disposed(by: disposeBag)
        
        publish.onNext(8)
        publish.on(.next(199))
        publish.onNext(123)
        
        publish.onCompleted()
        
        publish.onNext(292)
        publish.onNext(5555)
    }
    
    func aboutBehaviorSubject() {
        
        let publish = BehaviorSubject(value: 345)
        
        publish.onNext(1)
        publish.onNext(90)  //가장 마지막에 방출된 값을 버퍼처럼 가지고 있음, 얘를 초기값으로 가지게 됨(하나만 가짐!)
        
        publish
            .subscribe(with: self) { owner, value in
                print("PublishSubject - \(value)")
            } onError: { owner, error in
                print("PublishSubject error - \(error)")
            } onCompleted: { owner in
                print("PublishSubject completed")
            } onDisposed: { owner in
                print("PublishSubject disposed")
            }
            .disposed(by: disposeBag)
        
        publish.onNext(8)
        publish.on(.next(199))
        publish.onNext(123)
        
        publish.onCompleted()
        
        publish.onNext(292)
        publish.onNext(5555)
    }
    
    func aboutPublishSubject() {
        
        let publish = PublishSubject<Int>()
        
        publish.onNext(1)
        publish.onNext(90)
        
        publish
            .subscribe(with: self) { owner, value in
                print("PublishSubject - \(value)")
            } onError: { owner, error in
                print("PublishSubject error - \(error)")
            } onCompleted: { owner in
                print("PublishSubject completed")
            } onDisposed: { owner in
                print("PublishSubject disposed")
            }
            .disposed(by: disposeBag)
        
        publish.onNext(8)
        publish.on(.next(199))
        publish.onNext(123)
        
        publish.onCompleted()
        
        publish.onNext(292)
        publish.onNext(5555)
    }
    
    deinit {
        print("signUp Deinit")  //뷰컨이 deinit 돼서, disposeBag도 deinit되고 dispose 시켜서 incrementExample 메서드에서 방출하던 게 멈춤
    }
    
    func incrementExample() {
        //1초마다 무한대로 방출
        let increment = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        
        increment
            .subscribe(with: self) { owner, value in
                print("next - \(value)")
            } onError: { owner, error in
                print("error - \(error)")
            } onCompleted: { owner in
                print("completed")
            } onDisposed: { owner in
                print("disposed")   //명시적으로 dispose 할 때 실행, 화면이 사라져서 deinit 될 땐 호출 안됨
            }
            .disposed(by: disposeBag)
    }
    
    func disposeExample() {
        //from : 배열의 각 요소를 방출해주는 연산자, 배열의 수만큼 next 이벤트 발생, 이벤트를 방출만 하고 끝
        //        let textArray = Observable.from(["딸기", "바나나", "망고", "블루베리"]) 에러가 안 나옴 만약에 진짜 에러여도 next로 보냄
        
        //subject : Observable + Observer, 값을 방출하고 전달받을 수 있어야 해서 complet 되지 않음
        let textArray = BehaviorSubject(value: ["딸기", "바나나", "망고", "블루베리"]) //observable
        
        //상수에 담으면 필요한 시점에 리소스 해제 할 수 있음
        //observer
        let textArrayValue = textArray
            .subscribe(with: self) { owner, value in
                print("next - \(value)")
            } onError: { owner, error in
                print("error - \(error)")
            } onCompleted: { owner in
                print("completed")
            } onDisposed: { owner in    //이벤트 종류에 포함시키지는 않음
                print("disposed")
            }
        //            .disposed(by: disposeBag)
        
        textArray.onNext(["코코아", "우유", "라떼"])
        //        textArray.onError(EunseoError.gunpodo)
        textArray.onNext(["치즈케이크", "무화과타르트"])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            textArrayValue.dispose()
        }
        
        
    }
    
    @objc func nextButtonClicked() {
        navigationController?.pushViewController(PasswordViewController(), animated: true)
    }
    
    func configure() {
        validationButton.setTitle("중복확인", for: .normal)
        validationButton.setTitleColor(Color.black, for: .normal)
        validationButton.layer.borderWidth = 1
        validationButton.layer.borderColor = Color.black.cgColor
        validationButton.layer.cornerRadius = 10
    }
    
    func configureLayout() {
        view.addSubview(emailTextField)
        view.addSubview(validationButton)
        view.addSubview(nextButton)
        
        validationButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(100)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(validationButton.snp.leading).offset(-8)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    
}
