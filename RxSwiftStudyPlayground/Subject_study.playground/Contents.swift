import UIKit
import RxSwift

/*
 1、什么是subject（主题）？
 subject既是"observable（可观察序列）"也是"observer（观察者）"，它能发射事件，也能订阅事件
 
 2、Rx中的几个不同类型subject
 
 PublishSubject与它的名字一样，就像报纸出版商，它接收信息，然后发布给订阅者
 
 不同类型subject的区别：
 * PublishSubject：开始为空，仅向订阅者发射新元素
 * BehaviorSubject：以初始值开始，重复发射初始值或者最新的元素给订阅者
 * ReplaySubject：使用一定大小的缓冲区初始化（缓存区保存在内存中），并将元素保存在缓冲区，重复发射给订阅者
 * Variable：包装了一个BehaviorSubject，保留它的状态，仅重复发射最新或者初始值给订阅者
 */

/*
 1、使用PublishSubject工作
 订阅者从他们订阅的点开始接受PublishSubject发出的新事件，直到他们取消订阅，或者subject调用.completed或者.error事件终止
 
 如果订阅者需要接受订阅之前发射的事件，请使用Observable的create方法来创建Observable或者使用ReplaySubject
 */
example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    
    // 发射onNext事件，但是没有打印任何东西，因为还没有观察者
    subject.onNext("Is anyone listening?")
    
    // 创建订阅者one，仍然没有打印，因为在订阅之前发射的事件无法获取到
    let subscriptionOne = subject.subscribe(onNext: { (string) in
        print(string)
    })
    
    // 再次发射一个事件，上面将打印这次发射的元素，订阅之后的事件可以接收到
    subject.on(.next("1"))
    
    // 注意：subject.on(.next())与subject.onNext()这两种写法等价
    subject.onNext("2")
    
    // 创建订阅者two
    let subscriptionTwo = subject.subscribe({ (event) in
        print("2)", event.element ?? event)
    })
    
    subject.onNext("3")
    
    // 销毁订阅者one
    subscriptionOne.dispose()
    
    // subscriptionOne被销毁，所以不在接受新的事件
    subject.onNext("4")
    
    // 调用.onCompleted终止subject
    subject.onCompleted()
    
    // subject被终止，不在接受新的事件
    subject.onNext("5")
    
    // 销毁订阅者two
    subscriptionTwo.dispose()
    
    let disposeBag = DisposeBag()
    
    // subject完成后，还是会重复发送完成事件给新的订阅者，可以看到控制台打印 3) completed
    subject.subscribe({
        print("3)", $0.element ?? $0)
    }).disposed(by: disposeBag)
    
    // subject完成后，不在接受next事件
    subject.onNext("?")
}

enum MyError: Error {
    case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    if let e = event.element {
        print(label, e)
    } else if let error = event.error {
        print(label, error)
    } else {
        print(label, event)
    }
}

/*
 2、使用BehaviorSubjects工作
 
 初始化BehaviorSubjects必须包含一个初始值，如果不是你可能需要的是PublishSubject
 
 BehaviorSubjects的工作方式与PublishSubject类似，不同的是它会重复发送最近发射的.next事件给最新的订阅者，
 
 但是，如果你想要显示之前发射的更多的值，例如，搜索的时候，你想要显示最近的搜索历史的5个值，这时候你就需要使用ReplaySubjects，因为BehaviorSubjects只包含最近发射的的值
 */
example(of: "BehaviorSubject") {
    // 使用初始值创建BehaviorSubject实例
    let subject = BehaviorSubject(value: "Initial value")
    
    let bag = DisposeBag()
    
    subject.subscribe({
        print(label: "1)", event: $0)
    }).disposed(by: bag)
    
    subject.subscribe({
        print(label: "2)", event: $0)
    })
    
    subject.onNext("1")
    
    subject.onNext("2")
    
    // 第3个订阅者收不到第一次发射的“1”的值，只能收到最近发射的2的值
    subject.subscribe({
        print(label: "3)", event: $0)
    })
    
    subject.onNext("3")
    
    subject.onError(MyError.anError)
}

/*
 3、使用ReplaySubject
 
 ReplaySubject重复发射缓存在缓冲区的元素，如下例所示，初始化缓存区为2的ReplaySubject实例，发射3个元素，然后创建两个订阅者，由于缓存区的大小为2，所以1将不会发射，缓冲区被后面发射的2和3填充，在3发射之后，创建的订阅者，只能接受到2和3这两个事件
 */
example(of: "ReplaySubject") {
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    
    let bag = DisposeBag()
    
    subject.onNext("1")
    
    subject.onNext("2")
    
    subject.onNext("3")
    
    subject.subscribe({
        print(label: "1)", event: $0)
    })
    .disposed(by: bag)
    
    subject.subscribe({
        print(label: "2)", event: $0)
    })
    .disposed(by: bag)
    
    subject.onNext("4")
    
    // 打开下面的注释，你会看到一些不一样的事发生
    // 使用onError终止了subject，但是新的订阅者依然能接受到终止之前的事件，因为之前发射的事件缓存在内存了
//    subject.onError(MyError.anError)
//
//    subject.dispose() // 手动情况缓存，下面的订阅者只接收了错误事件，与预期一致。因为使用DisposeBag管理内存，很少手动释放，所以要注意这种情况（边界情况，需要注意）
    
    subject.subscribe({
        print(label: "3)", event: $0)
    })
    .disposed(by: bag)
    
}

/*
 4、Variables
 
 Variable包装了一个BehaviorSubject，要访问它下面的BehaviorSubject，需要使用asObservable转一下
 
 Variable释放的时候自动调用完成事件，不要使用Variable发射错误或者完成事件，这些操作都会导致编译错误
 */
example(of: "Variable") {
    // 使用类型推断，也可以使用显示类型声明
    let subject = Variable("Initial value")
    
    let bag = DisposeBag()
    
    subject.value = "New initial value"
    
    subject.asObservable().subscribe({
        print(label: "1)", event: $0)
    })
    .disposed(by: bag)
    
    subject.value = "1"
    
    subject.asObservable().subscribe({
        print(label: "2)", event: $0)
    })
    .disposed(by: bag)
    
    subject.value = "2"
}
