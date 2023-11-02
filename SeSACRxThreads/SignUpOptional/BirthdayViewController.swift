//
//  BirthdayViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BirthdayViewController: UIViewController {
    
    let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    
    let infoLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.text = "만 17세 이상만 가입 가능합니다."
        return label
    }()
    
    let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10 
        return stack
    }()
    
    let yearLabel: UILabel = {
       let label = UILabel()
        label.text = "2023년"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let monthLabel: UILabel = {
       let label = UILabel()
        label.text = "33월"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let dayLabel: UILabel = {
       let label = UILabel()
        label.text = "99일"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
  
    let nextButton = PointButton(title: "가입하기")
    
    
    let birthDay = BehaviorSubject(value: Date.now)
    
    let year = BehaviorSubject(value: 2020)
    let month = BehaviorSubject(value: 12)
    let day = BehaviorSubject(value: 11)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        bind()
        
        nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
    }
    
    @objc func nextButtonClicked() {
        print("가입완료")
    }

    func bind() {
        
        birthDayPicker.rx.date
            .bind(to: birthDay)
            .disposed(by: disposeBag)
        
        
        birthDay
            .subscribe(with: self) { owner, date in
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                owner.year.onNext(component.year!)
                owner.month.onNext(component.month!)
                owner.day.onNext(component.day!)
            } onDisposed: { owner in
                print("Disposed - Birthday")
            }
//            .dispose()  //즉시 리소스 정리 = 구독 해제 = 메모리에서 정리 = 더 이상 코드 동작하지 않음
            .disposed(by: disposeBag)
        
        year
            .observe(on: MainScheduler.instance) //Scheduler : GCD, 메인 쓰레드에서 동작하게 만듦
            .subscribe(with: self) { owner, value in
                owner.yearLabel.text = "\(value)년"
            } onDisposed: { _ in
                print("year - Disposed")
            }
            .disposed(by: disposeBag)
     
        month
            .map { "\($0)월"}
            .observe(on: MainScheduler.instance) //Scheduler : GCD, 메인 쓰레드에서 동작하게 만듦
            .subscribe(with: self) { owner, value in
                owner.monthLabel.text = value
            } onDisposed: { _ in
                print("month - Disposed")
            }
            .disposed(by: disposeBag)
        
        day
            .map { "\($0)일" }
            .bind(to: dayLabel.rx.text) //rxCocoa? 메인 쓰레드에서 동작함, 아닐 때도 있는데 여기선 메인에서 동작
            .disposed(by: disposeBag)
    }
    
    func configureLayout() {
        view.addSubview(infoLabel)
        view.addSubview(containerStackView)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
 
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        [yearLabel, monthLabel, dayLabel].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
   
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
