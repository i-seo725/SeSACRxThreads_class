//
//  BirthdayViewModel.swift
//  SeSACRxThreads
//
//  Created by 이은서 on 11/2/23.
//

import Foundation
import RxSwift
import RxCocoa

class BirthdayViewModel {
    
    let birthDay = BehaviorSubject(value: Date.now)
    
    //Label에 그대로 보여줌, 실패할 일이 없음, 완료될 일도 없음
    let year = BehaviorRelay(value: 1998)//BehaviorSubject(value: 2020)
    let month = BehaviorRelay(value: 12)
    let day = BehaviorRelay(value: 11)
    
    let disposeBag = DisposeBag()

    //viewModel 인스턴스 초기화 시점에
    init() {
        birthDay
            .subscribe(with: self) { owner, date in
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
                owner.year.accept(component.year!)  //onNext 대신 accept
                owner.month.accept(component.month!)
                owner.day.accept(component.day!)
            } onDisposed: { owner in
                print("Disposed - Birthday")
            }
    //            .dispose()  //즉시 리소스 정리 = 구독 해제 = 메모리에서 정리 = 더 이상 코드 동작하지 않음
            .disposed(by: disposeBag)
    }
    
    
    
}
