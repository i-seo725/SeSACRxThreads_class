//
//  SignInViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SignInViewController: UIViewController {

    let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let signInButton = PointButton(title: "로그인")
    let signUpButton = UIButton()
    
    let test = UISwitch()
    //Observable: 이벤트 생성 및 전달만 가능, 값을 전달 받거나 교체, 처리는 불가능
    //subject: observable + observer 역할 모두 수행
    //BehaviorSubject는 기본값을 가짐
    //PublishSubject는 초기값이 없어 이벤트 전달 필요
    let isOn = PublishSubject<Bool>()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        bind()
        aboutCombineLatest()
        
        configureLayout()
        configure()
        
        signUpButton.addTarget(self, action: #selector(signUpButtonClicked), for: .touchUpInside)
    }
    
    func aboutCombineLatest() {
        
        let a = PublishSubject<Int>()//BehaviorSubject(value: 11)
        let b = PublishSubject<String>()//BehaviorSubject(value: "밥")
        
        Observable.combineLatest(a, b) { a, b in
            return "결과: \(a) 그리고 \(b) "
        }
        .subscribe(with: self) { owner, value in
            print(value)
        }
        .disposed(by: disposeBag)
        
        a.on(.next(99))
        a.onNext(999)
        a.onNext(11122)
        
        b.onNext("@@")  //모든 옵저버블의 next 이벤트가 방출되어서 여기서부터 구독됨
        a.onNext(999)
        b.onNext("$%$%")
        
    }
    
    func bind() {
        
        let email = emailTextField.rx.text.orEmpty
        let password = passwordTextField.rx.text.orEmpty
        
        //combineLatest: 여러 Observable을 하나의 Observable로 묶기, 최대 8개까지, 아이디와 비밀번호의 조건을 한 번에 처리하기 위해 사용함
        let validation = Observable.combineLatest(email, password) { email, password in
            return email.count > 8 && password.count >= 10
        }
        
        validation
            .bind(to: signInButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        validation
            .subscribe(with: self) { owner, value in
                owner.signInButton.backgroundColor = value ? UIColor.blue : UIColor.red
                owner.emailTextField.layer.borderColor = value ? UIColor.blue.cgColor : UIColor.red.cgColor
                owner.passwordTextField.layer.borderColor = value ? UIColor.blue.cgColor : UIColor.red.cgColor
            }
            .disposed(by: disposeBag)
        
        signInButton.rx.tap
            .subscribe(with: self) { owner, value in
                owner.navigationController?.pushViewController(SearchViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
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
        
        increment
             .subscribe(with: self) { owner, value in
                 print("next - \(value)")
             } onError: { owner, error in
                 print("error - \(error)")
             } onCompleted: { owner in
                 print("completed")
             } onDisposed: { owner in
                 print("disposed")
             }
             .disposed(by: disposeBag)
        
        increment
             .subscribe(with: self) { owner, value in
                 print("next - \(value)")
             } onError: { owner, error in
                 print("error - \(error)")
             } onCompleted: { owner in
                 print("completed")
             } onDisposed: { owner in
                 print("disposed")
             }
             .disposed(by: disposeBag)
        
        //루트뷰는 deinit 되지 않아서 직접 리소스 정리 필요
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            //정리할 게 여러 개일 경우 인스턴스를 교체 - 기존 인스턴스는 deinit 되고 새로운 인스턴스가 생성됨
            self.disposeBag = DisposeBag()
            
//            incrementValue.dispose()
//            incrementValue2.dispose()
//            incrementValue3.dispose()
        }
    }
    
    @objc func signUpButtonClicked() {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
    
    
    func configure() {
        signUpButton.setTitle("회원이 아니십니까?", for: .normal)
        signUpButton.setTitleColor(Color.black, for: .normal)
    }
    
    func testSwitch() {
        view.addSubview(test)
        test.snp.makeConstraints { make in
            make.top.equalTo(150)
            make.leading.equalTo(100)
        }
//        isOn    //데이터의 변화를 감지해서 onNext 코드로 데이터가 변경되면 다시 실행됨
//            .subscribe { value in
//                self.test.setOn(value, animated: true)
//            }.disposed(by: disposeBag)
        
        
        isOn //위 코드와 동일한 역할
            .bind(to: test.rx.isOn)
            .disposed(by: disposeBag)
        
        //PublishSubject를 사용하기 때문에 초기값을 갖도록 이벤트 전달
        //코드 위치가 구독(subscribe, bind) 이후에 있어야 함
        isOn.onNext(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isOn.onNext(false) //Observable은 이 메서드 사용 불가, BehaviorSubject는 가능
        }
        
        //UIKit 코드
//        test.setOn(true, animated: true)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.test.setOn(false, animated: true)
//        }
    }
    
    func configureLayout() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        signInButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(signInButton.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    

}
