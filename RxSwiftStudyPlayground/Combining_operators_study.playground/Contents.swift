import UIKit
import RxSwift

enum MyError: Error {
    case anError
}

// Combining组合操作
// 注意：Observable sequences是强类型的，你只能结合相同类型的序列，不同类型序列的结合将产生编译错误，例如Observable<String>结合Observable<Int>会产生编译错误

/*
 concat 操作符将多个 Observables 按顺序串联起来，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素。
 
 concat 将等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。如果后一个是“热” Observable ，在它前一个 Observable 产生完成事件前，所产生的元素将不会被发送出来。
 */
example(of: "concat") {
    // 1
    let first = Observable.of(1, 2, 3)
    let second = Observable.of(4, 5, 6)
    
    // 2
    let observable = Observable.concat([first, second])
    
    observable.subscribe(onNext: {
        print($0)
    })
}

example(of: "concat on element") {
    let numbers = Observable.of(2, 3, 4)
    
    let observable = Observable
        .just(1)
        .concat(numbers)
    
    observable.subscribe(onNext: {
        print($0)
    })
}

/*
 比较concat与zip模拟网络请求中的应用
 concat序列集合中，有一个序列发射错误并不会马上终止concat的新序列，zip是一旦一个序列发射错误事件，立马终止zip的新序列
 */
example(of: "concat 与 zip比较 - network") {
    let first = PublishSubject<String>()
    let second = PublishSubject<String>()
    
    Observable.zip([first, second])
        .subscribe(onNext: {
            print($0)
        }, onError: {
            print($0)
        }, onCompleted: {
            print("onCompleted")
        }, onDisposed: {
            print("onDisposed")
        })
    
//    first.onNext("1")
//    first.onCompleted()
    first.onError(MyError.anError)
    second.onNext("2")
//    second.onError(MyError.anError)
}

/*
 使用merge合并两个序列
 
 merge和concat十分相似。区别是，merge并不是将多个Observables按顺序串联起来，而是将他们合并到一起，不需要Observables按先后顺序发出元素。
 
 merge什么时候完成？
 当源序列以及所有内部序列完成时，merge完成。内部序列完成的顺序无关紧要。任何序列发送错误，merge立即转发错误事件，然后终止。
 */
example(of: "merge") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let source = Observable.of(left.asObservable(), right.asObservable())
    
    let observable = source.merge()
    let disposable = observable.subscribe(onNext: {
        print($0)
    })
    
    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    
    // 每次运行代码，都会有不同的结果
    repeat {
        if arc4random_uniform(2) == 0 {
            if !leftValues.isEmpty {
                left.onNext("Left: " + leftValues.removeFirst())
            }
        } else if !rightValues.isEmpty {
            right.onNext("Right: " + rightValues.removeFirst())
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty
    
    disposable.dispose()
}

/*
 combineLatest结合Observables
 
 combineLatest 操作符将多个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。这些源 Observables 中任何一个发出一个元素，他都会发出一个元素（前提是，这些 Observables 曾经发出过元素）。
 */
example(of: "combineLatest") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = Observable.combineLatest(left, right, resultSelector: { (lastLeft, lastRight) in
        "\(lastLeft) \(lastRight)"
    })
    let disposable = observable.subscribe(onNext: {
        print($0)
    })
    
    print("> Sending a value to Left")
    left.onNext("Hello, ")
    print("> Sending a value to Right")
    right.onNext("world")
    print("> Sending another value to Right")
    right.onNext("RxSwift")
    print("> Sending another value to Left")
    left.onNext("Have a good day,")
    
    disposable.dispose()
}

/*
 zip 操作符将多个(最多不超过8个) Observables 的元素通过一个函数组合起来，然后将这个组合的结果发出来。它会严格的按照序列的索引数进行组合。例如，返回的 Observable 的第一个元素，是由每一个源 Observables 的第一个元素组合出来的。它的第二个元素 ，是由每一个源 Observables 的第二个元素组合出来的。它的第三个元素 ，是由每一个源 Observables 的第三个元素组合出来的，以此类推。它的元素数量等于源 Observables 中元素数量最少的那个。
 
     // test1
     一旦源序列中的一个发射错误事件，整个zip序列转发错误事件并终止
 
     // test2
     zip严格按照序列的索引进行组合，并且它的元素数量等于源序列集合中元素数量最少的那个，多出的事件将不会发射
 
     // 疑问：zip序列何时完成？
     源序列集合中元素数量最少的那个完成了，zip序列完成，否则zip序列永远不会完成（这个结论有些疑问，讨论：https://github.com/ReactiveX/RxSwift/issues/1666）
 */
example(of: "zip") {
    
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let disposable = Observable.zip(left, right)
        .subscribe(onNext: {
            print($0+$1)
        }, onError: {
            print($0)
        }, onCompleted: {
            print("completed")
        }, onDisposed: {
            print("disposed")
        })
    
    // test1
//    left.onNext("1")
//    right.onError(MyError.anError)

    // test2
    left.onNext("1")
    left.onNext("2")
    left.onNext("3")
//    left.onCompleted()
    
    right.onNext("A")
    right.onNext("B")
    right.onNext("C")
    right.onCompleted()
//    right.onNext("D")
    
    disposable.dispose()
}

example(of: "zip") {
    let left = Observable.of("1", "2", "3")
    let right = Observable.of("A", "B", "C", "D")
    
    let disposable = Observable
        .zip(left, right) {
            return $0+$1
        }
        .subscribe(onNext: {
            print($0)
        }, onError: {
            print($0)
        }, onCompleted: {
            print("completed")
        }, onDisposed: {
            print("disposed")
        })
    
    disposable.dispose()
}

/*
 withLatestFrom 操作符将两个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。当第一个 Observable 发出一个元素时，就立即取出第二个 Observable 中最新的元素，通过一个组合函数将两个最新的元素合并后发送出去。
 */
example(of: "withLatestFrom") {
    let button = PublishSubject<String>()
    let textfield = PublishSubject<String>()
    
    let observable = button.withLatestFrom(textfield) { (first, second) in
            return second
        }
    let dispose = observable.subscribe(onNext: {
        print($0)
    })
    
    textfield.onNext("lu")
    textfield.onNext("luc")
    textfield.onNext("lucy")
    button.onNext("")
    button.onNext("")
    
    dispose.dispose()
}

/*
 开关，RxSwift提供了两个主要的切换操作符，amb和switchLatest，允许订阅者在运行时决定接收那个序列的的事件
 
 amb：amb组合两个序列，其中一个序列发出一个元素，就取消对另一个序列的订阅。之后，只会接收发出第一个元素的序列。如图它的名字一样，模棱两可的，因为不知道那个序列先发出元素。它有一些实际应用，比如有备用服务器的时候，使用优先响应的那台服务器（ip主副切换）。
 */
example(of: "amb") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = left.amb(right)
    let disposable = observable.subscribe(onNext: {
        print($0)
    })
    
    // left先发出元素，right序列将被取消订阅
    left.onNext("lisbon")
    right.onNext("Coponhagen")
    left.onNext("London")
    left.onNext("Madrid")
    right.onNext("Vienna")
    
    disposable.dispose()
}

/*
switchLastest只观察最新的Observable发出的元素，与另外一个操作符flatMapLatest很相似，flatMapLatest是将最新的值转换为Observable，然后订阅它，只保留最新的订阅有效
 */
example(of: "switchLatest") {
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()
    
    let source = PublishSubject<Observable<String>>()
    
    let observable = source.switchLatest()
    let disposable = observable.subscribe(onNext: {
        print($0)
    })
    
    source.onNext(one)
    one.onNext("Some text from sequence one")
    two.onNext("Some text from sequence two")
    
    source.onNext(two)
    two.onNext("More text from sequence two")
    one.onNext("More text from sequence one")
    
    source.onNext(three)
    one.onNext("and also from sequence one")
    source.onNext(three)
    two.onNext("Why don't you seem me?")
    one.onNext("I'm alone, help me")
    three.onNext("Hey it's three. I win.")
    source.onNext(one)
    one.onNext("Nope. It's me, one!")
    
    disposable.dispose()
}

/*
 reduce操作符将对第一个元素应用一个函数。然后，将结果作为参数填入到第二个元素的应用函数中。以此类推，直到遍历完全部的元素后发出最终结果。
 */
example(of: "reduce") {
    // 应用累加函数对数组求和，类似（0 + 10 + 100 + 1000）
    Observable.of(10, 100, 1000)
        .reduce(0, accumulator: +)
        .subscribe(onNext: { print($0) })
        .dispose()
    
    // 上面的方法是简写，下面的写法是自我解释的写法更易懂
    Observable.of(10, 100, 1000)
        .reduce(0, accumulator: { sum, newValue in
            print("sum = \(sum) new = \(newValue)")
            return sum + newValue
        })
        .subscribe(onNext: { print($0) })
        .dispose()
}
/*
 scan操作符将对第一个元素应用一个函数，将结果作为第一个元素发出。然后，将结果作为参数填入到第二个元素的应用函数中，创建第二个元素。以此类推，直到遍历完全部的元素。
 
 思考下与reduce的不同？（参考弹珠图）
 reduce只会发射最后的结果，scan会发射每一次函数调用的结果
  */
example(of: "scan") {
    // 打印三角形数（https://zh.wikipedia.org/wiki/%E4%B8%89%E8%A7%92%E5%BD%A2%E6%95%B8）
    Observable.of(1, 2, 3, 4, 5, 6)
        .scan(0, accumulator: +)
        .subscribe(onNext: { print($0) })
        .dispose()
}

/*
 测试并行执行异步任务，按顺序返回
 结论：实际上异步任务还是串行执行的
 */
//example(of: "concat async work") {
//    func asyncWork(_ label: String) -> Observable<String> {
//        return Observable.create({ observer -> Disposable in
//            DispatchQueue.global().async {
//                print(Thread.current.description + " start!")
//                sleep(arc4random_uniform(10))
//                for _ in 0...10 {
//                    observer.onNext("==== \(label) =====")
//                }
//                observer.onCompleted()
//            }
//            return Disposables.create()
//        })
//    }
//
//    let observable1 = asyncWork("1")
//    let observable2 = asyncWork("2")
//    let observable3 = asyncWork("3")
//    let observable4 = asyncWork("4")
//
//    Observable.concat([observable1, observable2, observable3, observable4])
//        .subscribe(onNext: {
//            print($0)
//        })
//}
