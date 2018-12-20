import UIKit
import RxSwift
/*
 1、Observable是什么？
 Observable是RX的核心。下面你将学习什么是Observable，如何创建它，如何使用它。
 
 在RX中，你会看到"Observable"、"Observable sequence"、“sequence”，他们都是一样的，甚至，有时也会叫做"流"，特别是从其他响应式环境过来的开发者。但是在RxSwift，很酷的孩子，都叫它"序列"而不是"流"。在RxSwift中，所有的东西都是序列。Observable就是一个序列，很重要的一点是，他是异步的。Observables生产事件，某一时刻生产事件的这个过程叫做发射（emitting），事件可以携带一些值。
 
 2、什么是cold和hot的Observable，如何区分？（https://medium.com/@DianQK/hot-observable%E5%92%8Ccold-observable-c3ba8d07867b）
 如果新的订阅者，总是能收到完整的事件流，那么就是冷的Observable
 如果新的订阅者，不能收到完整的事件流，只能收到订阅之后的事件流，那么就是热的Observable
 
 例如，按钮点击Observable，只有订阅了按钮点击的Observable后才能收到按钮的点击事件流，所以按钮点击Observable是热的。再如，网络请求的Observable，每次新的订阅者都能收到完整的网络请求的结果、失败或者错误的事件，所以网络请求的Observable是冷的。
 
 3、创建observables，Rx提供了很多创建Observable的操作符，如just、of、from、empty、never、range、create等，create是最灵活的一个
 
 */

/*
 just仅发射唯一一个元素
 */
example(of: "just") {
    let observable = Observable.just("1")
    
    //
    observable.subscribe({
        print($0)
    })
}

/*
 of和from都是将其他类型转换为Observable，不同的是from只支持数组
 */
example(of: "of") {
    let observable = Observable.of(1, 2, 3)
    observable.subscribe({
        print($0)
    })
    
    let observable1 = Observable.of([1, 2, 3])
    observable1.subscribe({
        print($0)
    })
}

/*
 from将其他类型或者数据结构转换为Observable，例如将一个数组[1,2,3]转成Observable，
 Observable.from([1,2,3])，Observable将连续发射数组的3个元素
 */
example(of: "from") {
    let observable = Observable.from(["1", "2", "3"])
    observable.subscribe({
        print($0)
    })
}

/*
 empty不发射.next事件，仅发射一个completed事件
 */
example(of: "empty") {
    let observable = Observable<Void>.empty()
    
    observable.subscribe({ event in
        print(event)
    })
}

/*
 never不发射任何事件
 */
example(of: "never") {
    let observable = Observable<Void>.never()
    
    observable.subscribe({ event in
        print(event)
    })
}

example(of: "range") {
    let observable = Observable<Int>.range(start: 1, count: 10)
    
    observable.subscribe(onNext: { i in
        print(i)
    })
}

/*
 dispose立即销毁
 */
example(of: "dispose") {
    // 1
    let observable = Observable.of("A", "B", "C")
    
    // 2
    let subscription = observable.subscribe({ event in
        // 3
        print(event)
    })
    
    subscription.dispose()
}

/*
 disposeBag释放池，bag销毁的时候里面的所有Observable销毁
 */
example(of: "DisposeBag") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C")
        .subscribe({
            print($0)
        })
        .disposed(by: disposeBag)
}

/*
 create是最灵活的创建Observable的操作符
 */
example(of: "create") {
    let bag = DisposeBag()
    
    Observable<String>.create({ observer in
        observer.onNext("1")
        
        observer.onCompleted()
        
        observer.onNext("?")
        
        return Disposables.create()
    })
    .subscribe(onNext: {
        print($0)
    }, onError: {
        print($0)
    }, onCompleted: {
        print("onCompleted")
    }, onDisposed: {
        print("onDisposed")
    })
    .disposed(by: bag)
}

/*
 just、of、from和create的区别，create不会自动发射完成事件，除非手动调用，其他几个会自动发射完成事件
 
 例如下面的例子，如果create不手动调用onCompleted事件，不会自动发射
 */
example(of: "different between of and create") {
    Observable.of("1", "2").subscribe(onCompleted: {
        print("of completed")
    })
    
    Observable<String>.create { observer in
        observer.onNext("1")
        observer.onNext("2")
//        observer.onCompleted()
        return Disposables.create()
        }
        .subscribe(onCompleted: {
            print("create completed")
        })
}
