//
//  ViewController.swift
//  RxSwiftStudyPlayground
//
//  Created by 杨方明 on 2018/11/15.
//  Copyright © 2018年 杨方明. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let bag = DisposeBag()
//
//        let observable1 = asyncTask("1")
//        let observable2 = asyncTask("2")
//        let observable3 = asyncTask("3")
//
//        Observable.concat([observable1, observable2, observable3])
//            .observeOn(MainScheduler.asyncInstance)
//            .subscribe(onNext: {
//                print($0)
//            }).disposed(by: bag)
        
        let seq = Observable
            .of(1, 2, 3, 4, 5)
            .map { (n) -> Observable<Int> in
                let o = self.doAsyncWork(n,
                                    desc: "start \(n) - wait \(5 - n)",
                    time: 6 - n
                    ).share(replay: 1)
                o.subscribe()
                return o.asObservable()
            }
            .concat()
        
        let sharedSeq = seq.share(replay: 0)
        sharedSeq.subscribe(onNext: {
            print("=> \($0)")
        }) {
            print("=> completed")
        }
//        sharedSeq.subscribeNext { print("=> \($0)") }
//        sharedSeq.subscribeCompleted { print("=> completed") }
    }
    
    func delay(_ time: Int, closure: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now()) {
            closure()
        }
    }
    
    func doAsyncWork(_ value: Int, desc: String, time: Int) -> Observable<Int> {
        return Observable.create() { (observer) -> Disposable in
            print(desc)
            self.delay(time) {
                observer.onNext(value)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

}

extension ViewController {
    func asyncTask(_ label: String) -> Observable<String> {
        return Observable.create({ observer -> Disposable in
            DispatchQueue.global().async {
                observer.onNext(label)
            }
            observer.onCompleted()
            return Disposables.create()
        })
    }
}
