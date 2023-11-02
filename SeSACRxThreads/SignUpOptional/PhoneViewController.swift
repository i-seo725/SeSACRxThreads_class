//
//  PhoneViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PhoneViewController: UIViewController {
   
    let phoneTextField = SignTextField(placeholderText: "연락처를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    
    let phone = BehaviorSubject(value: "010")
    let buttonColor = BehaviorSubject(value: UIColor.red)
    let buttonEnabled = BehaviorSubject(value: false)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        
        nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
        
        bind()
    }
    
    @objc func nextButtonClicked() {
        navigationController?.pushViewController(NicknameViewController(), animated: true)
    }

    func bind() {
        buttonEnabled
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        buttonColor
            .bind(to: nextButton.rx.backgroundColor, phoneTextField.rx.tintColor)
            .disposed(by: disposeBag)
        
        buttonColor
            .map { $0.cgColor }
            .bind(to: phoneTextField.layer.rx.borderColor)
            .disposed(by: disposeBag)
        
        phone
            .bind(to: phoneTextField.rx.text)
            .disposed(by: disposeBag)
        
//        phone
//            .map { $0.count > 10 }
//            .subscribe { value in
//                print("==\(value)")
//                let color = value ? UIColor.blue : UIColor.red
//                self.buttonColor.onNext(color)
//                self.buttonEnabled.onNext(value)
////                self.buttonEnabled.on(.next(value)) //위와 같은 코드
//            }
//            .disposed(by: disposeBag)
//
//
//
//        phone
//            .map { $0.count > 10 }
//            .withUnretained(self)   //RxSwift6부터 지원, weak self 역할
//            .subscribe { object, value in   //object: self 대신 사용할 코드(UIVC)
//                print("==\(value)")
//                let color = value ? UIColor.blue : UIColor.red
//                object.buttonColor.onNext(color)
//                object.buttonEnabled.onNext(value)
////                object.buttonEnabled.on(.next(value)) //위와 같은 코드
//            }
//            .disposed(by: disposeBag)
        
        
        phone
            .map { $0.count > 10 }
            .subscribe(with: self, onNext: { owner, value in    //rxSwift6.1부터 등장, withUnretained와 결합된 형태
                print("==\(value)")
                let color = value ? UIColor.blue : UIColor.red
                owner.buttonColor.onNext(color)
                owner.buttonEnabled.onNext(value)
//                owner.buttonEnabled.on(.next(value)) //위와 같은 코드
            })
            .disposed(by: disposeBag)
 
        
        
        phoneTextField.rx.text.orEmpty  //orEmpty : Optional Binding
            .subscribe { value in   //value: 가지고 온 값을 보여주는 요소
                let result = value.formated(by: "###-####-####")
                print(result, value)
                self.phone.onNext(result)
            }
            .disposed(by: disposeBag)
    }
    
    func configureLayout() {
        view.addSubview(phoneTextField)
        view.addSubview(nextButton)
         
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(phoneTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}


