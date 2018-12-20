import RxSwift
import Foundation

let elementsPerSecond = 1
let maxElements = 5
let replayedElements = 1
let replayDelay: TimeInterval = 3

let sourceObservable = Observable<Int>.create { observer in
    var value = 1
    let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
        if value <= maxElements {
            observer.onNext(value)
            value = value + 1
        }
    }
    return Disposables.create {
        timer.suspend()
    }}

sourceObservable.subscribe {
    print($0)
}

/*
 使用rx的定时器实现上面的功能
 
 疑问: 如何终止定时器？
 调用dispose(）停止定时器
 */
//var value = 1
//let otherObservable = Observable<Int>
//    .interval(1.0 / Double(elementsPerSecond), scheduler: MainScheduler.instance)
//    .subscribe(onNext: {
//        if value <= maxElements {
//            print($0)
//            value = value + 1
//        }
//    })
