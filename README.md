[![Build Status](https://travis-ci.org/chenmingbiao/SwiftMulticastDelegate.svg?branch=master)](https://travis-ci.org/chenmingbiao/SwiftMulticastDelegate)
![Swift 4.0.x](https://img.shields.io/badge/Swift-4.0.x-orange.svg) 
![iOS 8+](http://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)
[![License](https://img.shields.io/cocoapods/l/SwiftKVO.svg?style=flat)](http://cocoapods.org/pods/SwiftKVO)

# SwiftMulticastDelegate

Implementing multi cast of delegate in Swift.

### Installation

#### Manual

Copy `SwiftMulticastDelegate.swift` to your project

#### CocoaPods

```ruby
pod 'SwiftMulticastDelegate', :git => 'https://github.com/chenmingbiao/SwiftMulticastDelegate.git'
```

#### Swift Package Manager

You can use [Swift Package Manager](https://swift.org/package-manager/) and specify a dependency in `Package.swift` by adding this:
```swift
.Package(url: "https://github.com/chenmingbiao/SwiftMulticastDelegate.git", majorVersion: 1)
```

### Usage

Import the module
```swift
import SwiftMulticastDelegate
```

1. Add to your class: `let delegate = SwiftMulticastDelegate<MyProtocol>()`
2. Other classes must add as a delegate: `obj.delegate.add(self)`
3. When you need to notify your delegates: `multicastDelegate.invoke { delegate in delegate.func() }`

Alternative version:

1. Add to your class: `let delegate = SwiftMulticastDelegate<MyProtocol>()`
2. Other classes must add as a delegate: `obj.delegate += self`
3. When you need to notify your delegates: `multicastDelegate => { $0.func() }`


### Example

```swift
// MARK: - MyButtonDelegate
protocol MyButtonDelegate: class {
    func didTap()
}

// MARK: - MyButton
class MyButton: UIButton {

    var delegate = SwiftMulticastDelegate<MyButtonDelegate>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTitle("Action", for: .normal)
        self.setTitleColor(UIColor.blue, for: .normal)
        self.addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didTap() {
        delegate => {
            $0.didTap()
        }
    }

}
```

```swift
// MARK: - SubView
class SubView: UIView {
    var name = ""
}

extension SubView: MyButtonDelegate {
    func didTap() {
        print("\(name) did tap")
    }
}
```

```swift
// MARK: - ViewController
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let button = MyButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        button.center = self.view.center
        self.view.addSubview(button)

        let subview1 = SubView()
        subview1.name = "subview@1"
        button.delegate += subview1
        self.view.addSubview(subview1)

        let subview2 = SubView()
        subview2.name = "subview@2"
        button.delegate += subview2
        self.view.addSubview(subview2)

        /* Add Array */
        // button.delegate += [subview1, subview2]

        /* Rmove Array */
        // button.delegate -= [subview1, subview2]
    }

}
```

### Operators

Simplify multicast usage

`+=` calls `add(_ delegate: T)` or `add(_ delegate: [T])`

`-=` calls `remove(_ delegate: T)` or `remove(_ delegate: [T])`

`=>` calls `invoke(_ invocation: (T) -> ())`
