import UIKit
import RxSwift

// 变换操作符

/*
 1、使用toArray转换元素到一个数组
 */
example(of: "toArray") {
    let bag = DisposeBag()
    
    Observable.of("A", "B", "C")
        .toArray()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: bag)
}

/*
 2、使用map对元素进行变换，与swift标准库的用法一致
 */
example(of: "map") {
    let bag = DisposeBag()
    
    Observable<Int>.of(1, 2, 3)
        .map {
            $0 * 2
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: bag)
}

/*
 3、使用mapWithIndex(方法已废弃，请使用enumerated().map())转换，对符合条件的下标变换
 */
example(of: "mapWithIndex") {
    let bag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
        .mapWithIndex({ integer, index in
            index > 2 ? integer * 2 : integer
        })
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: bag)
}

struct Student {
    var score: Variable<Int>
}

/*
 flatMap 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。 然后将这些 Observables 的元素合并之后再发送出来。
 
 这个操作符是非常有用的，例如，当 Observable 的元素本身拥有其他的 Observable 时，你可以将所有子 Observables 的元素发送出来。
 */
example(of: "flatMap") {
    let bag = DisposeBag()
    
    // 1
    let ryan = Student(score: Variable(80))
    let charlotte = Student(score: Variable(90))
    
    // 2
    let student = PublishSubject<Student>()
    
    student.asObservable()
        .flatMap({
            $0.score.asObservable()
        })
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: bag)
    
    student.onNext(ryan)
    ryan.score.value = 85
    
    student.onNext(charlotte)
    
    ryan.score.value = 95
    
    charlotte.score.value = 100
}
