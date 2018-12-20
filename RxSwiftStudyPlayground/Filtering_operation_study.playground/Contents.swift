//: Playground - noun: a place where people can play

import UIKit
import RxSwift

// 过滤操作符

/*
 使用ignoreElements，忽略所有.next事件，可是允许停止事件通过，如.compeled或.error事件
 */
example(of: "ignoreElements", action: {
    // 1
    let strikes = PublishSubject<String>()
    let bag = DisposeBag()
    
    strikes
        .ignoreElements()
        .subscribe({ _ in
            print("You're out!")
        })
        .disposed(by: bag)
    
    // 这里发射的next事件将被忽略
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
    
    strikes.onCompleted()
})

/*
 2、使用elementAt(_ index: Int)操作符，忽略其他事件，只允许指定索引的事件通过，索引从0开始
 */
example(of: "elementAt") {
    // 1
    let strikes = PublishSubject<String>()
    
    let bag = DisposeBag()
    
    // 2
    strikes
        .elementAt(2)
        .subscribe(onNext: { (str) in
            print("\(str) has out!")
        })
        .disposed(by: bag)
    
    strikes.onNext("0")
    strikes.onNext("1")
    strikes.onNext("2")
}

/*
 3、使用filter操作符过滤元素，只订阅感兴趣的元素
 */
example(of: "filter") {
    let bag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
        // 2
        .filter({ integer -> Bool in
            integer % 2 == 0
        })
        // 3
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: bag)
}

/*
 4、使用skip操作符跳过一定数量的元素
 如下例，跳过前面3个元素，输出D、E、F
 */
example(of: "skip") {
    let bag = DisposeBag()
    
    // 忽略前面3个元素
    Observable.of("A", "B", "C", "D", "E", "F")
        .skip(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: bag)
}

/*
 5、skipWhile操作符（skip操纵符的类簇），与skip不同的是，skipWhile跳过不符合条件的操作符，直到条件满足，后面的元素都通过
 如下例所示，跳过元素直到碰到奇数，奇数后面的元素都通过
 */
example(of: "skipWhile") {
    let bag = DisposeBag()
    
    Observable.of(2, 2, 3, 4, 4)
        .skipWhile({ integer in
            integer % 2 == 0
        })
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: bag)
}

/*
 6、使用skipUntil动态过滤observable
 如下例，订阅者跳过元素直到被观察的observable发出.next事件，然后停止跳过，接收后面发出的事件
 */
example(of: "skipUntil") {
    let bag = DisposeBag()
    
    // 1
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()

    subject
        .skipUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: bag)

    subject.onNext("A")
    subject.onNext("B")

    trigger.onNext("X") // 停止跳过

    subject.onNext("C")
    subject.onNext("D")
}

/*
 7、take操作符与skip是相反的操作，使用take获取从起始位置开始的指定数量的元素
 如下例，获取1，2，3前面3个元素
 */
example(of: "take") {
    let bag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
        .take(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: bag)
}

/*
 8、使用distinctUntilChanged阻止相邻的重复的元素通过
 */
example(of: "distinctUntilChanged") {
    let bag = DisposeBag()
    
    // 1
    Observable.of("A", "A", "B", "B", "B", "A")
        // 2
        .distinctUntilChanged()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: bag)
}

/*
 9、自定义distinctUntilChanged的比较逻辑
 */
example(of: "distinctUtilChnage(_:)") {
    let bag = DisposeBag()
    
    // 1
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
        .distinctUntilChanged({ (a, b) -> Bool in
            guard let aWords = formatter.string(from: a)?.components(separatedBy: " "), let bWords = formatter.string(from: b)?.components(separatedBy: " ") else {
                    return false
                }
            var containMatch = false
            
            print(aWords, bWords)
            for aWord in aWords {
                for bWord in bWords {
                    if aWord == bWord {
                        containMatch = true
                        break
                    }
                }
            }
            
            return containMatch
            
        })
        .subscribe(onNext: {
            print("---\($0)")
        })
        .disposed(by: bag)
}

