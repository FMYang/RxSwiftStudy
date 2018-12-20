/*
 当一个序列发出元素时，经常需要确定将来的订阅者，接收序列之前发出的部分或者全部的元素，这就是replay和replayAll运算符的目的
 
 replay确保观察者接收到同样的序列，即使是在 Observable 发出元素后才订阅
 
 可被连接的 Observable 和普通的 Observable 十分相似，不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。这样一来你可以控制 Observable 在什么时候开始发出元素。
 
 replay 操作符将 Observable 转换为可被连接的 Observable，并且这个可被连接的 Observable 将缓存最新的 n 个元素。当有新的观察者对它进行订阅时，它就把这些被缓存的元素发送给观察者。
 */

import UIKit
import RxSwift
import RxCocoa

let maxElements = 5

// 每秒发射几个元素
let elementsPerSecond = 1
// 缓存几个元素，当有新的观察者对它进行订阅时，它就把这些被缓存的元素发送给观察者。
let replayedElements = 3
// 多少秒后重播
let replayDelay: TimeInterval = 5

// 创建rx定时器发射元素，并缓存
// replay(:) 当新的订阅者订阅时，发送缓存的最新的元素给新的订阅者
// replayAll 当新的订阅者订阅时，发送之前所有发出去的元素给新的订阅者
let sourceObservable = Observable<Int>
    .interval(RxTimeInterval(1.0 / Double(elementsPerSecond)), scheduler: MainScheduler.instance)
    .replay(replayedElements)
//    .replayAll()

let sourceTimeline = TimelineView<Int>.make()
let replayedTimeline = TimelineView<Int>.make()

let stack = UIStackView.makeVertical([
    UILabel.makeTitle("replay"),
    UILabel.make("Emit \(elementsPerSecond) per second:"),
    sourceTimeline,
    UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
    replayedTimeline])

// 订阅sourceTimeline发射的元素
_ = sourceObservable.subscribe(sourceTimeline)

// 延时订阅replayedTimeline发射的元素
DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
    _ = sourceObservable.subscribe(replayedTimeline)
}

_ = sourceObservable.connect()

let hostView = setupHostView()
hostView.addSubview(stack)
hostView


// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
    static func make() -> TimelineView<E> {
        return TimelineView(width: 400, height: 100)
    }
    public func on(_ event: Event<E>) {
        switch event {
        case .next(let value):
            add(.Next(String(describing: value)))
        case .completed:
            add(.Completed())
        case .error(_):
            add(.Error())
        }
    }
}
