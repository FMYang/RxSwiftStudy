//: Please build the scheme 'RxSwiftPlayground' first

import UIKit
import RxSwift
import RxCocoa

// 每秒发射的元素数量
let elementsPerSecond = 1
let delayInSeconds = 1.5

let sourceObservable = PublishSubject<Int>()

// 可视化replay的效果，创建一组TilelineViews，定义在文件的底部
let sourceTimeline = TimelineView<Int>.make()
let delayedTimeline = TimelineView<Int>.make()

// 方便起见，使用UIStackView显示
let stack = UIStackView.makeVertical([
    UILabel.makeTitle("delay"),
    UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
    sourceTimeline,
    UILabel.make("Delayed elements (with a \(delayInSeconds)s delay):"),
    delayedTimeline])

var current = 1
let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
    sourceObservable.onNext(current)
    current = current + 1
}

// 创建一个当前订阅者，显示它接收到的元素到TimelineView顶部
// TimelineView实现了ObserverType协议（实现了onNext、onCompleted、onError事件），因此可以订阅它，它将接收序列发出的事件。每次有新的事件发生（发射元素、序列完成或错误退出），TimelineView就在时间线上显示它。发射元素显示为绿色、完成显示为黑色、错误显示为红色。
_ = sourceObservable.subscribe(sourceTimeline)

// Setup the delayed subscription
// ADD CODE HERE

// delay
_ = Observable<Int>
    .timer(3, scheduler: MainScheduler.instance) // 3秒后开始订阅序列
    .flatMap { _ in
        // sourceObservable使用delay延时1.5s后订阅
        sourceObservable
            .delay(RxTimeInterval(delayInSeconds),
                   scheduler: MainScheduler.instance)
    }
    .subscribe(delayedTimeline)

// delaySubscription
//_ = sourceObservable
//    .delaySubscription(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
//    .subscribe(delayedTimeline)


// 将TimelineView添加到playgroundPage上显示
let hostView = setupHostView()
hostView.addSubview(stack)
hostView


// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
    static func make() -> TimelineView<E> {
        let view = TimelineView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        view.setup()
        return view
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
/*:
 Copyright (c) 2014-2017 Razeware LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

