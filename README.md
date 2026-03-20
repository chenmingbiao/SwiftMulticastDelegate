# SwiftMulticastDelegate
[English](README.md) | [中文版](README_zh.md)

[![Build Status](https://github.com/chenmingbiao/SwiftMulticastDelegate/actions/workflows/swift.yml/badge.svg)](https://github.com/chenmingbiao/SwiftMulticastDelegate/actions)
![Swift 6.0+](https://img.shields.io/badge/Swift-6.0%2B-orange.svg) 
![iOS 12+](http://img.shields.io/badge/iOS-12.0%2B-blue.svg)
![License](https://img.shields.io/cocoapods/l/SwiftKVO.svg?style=flat)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)

Implementing multi cast of delegate in Swift. Fully compatible with Swift 6 Strict Concurrency.

### Installation

#### 1. Manual:

Copy `SwiftMulticastDelegate.swift` to your project

#### 2. CocoaPods:

```ruby
pod 'SwiftMulticastDelegate', :git => 'https://github.com/chenmingbiao/SwiftMulticastDelegate.git'
```

#### 3. Swift Package Manager:

You can use [Swift Package Manager](https://swift.org/package-manager/) and specify a dependency in `Package.swift` by adding this:
dependencies: [
    .package(url: "https://github.com/chenmingbiao/SwiftMulticastDelegate.git", from: "1.0.0")
]

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
// MARK: - Delegate Protocol
protocol ServiceStateDelegate: AnyObject {
    func didUpdateState(to state: String)
}

// MARK: - Service
class NetworkService {
    var delegates = SwiftMulticastDelegate<ServiceStateDelegate>()

    func changeState() {
        // ... some logic ...
        delegates => {
            $0.didUpdateState(to: "Connected")
        }
    }
}

// MARK: - Observer
class ViewModel: ServiceStateDelegate {
    func didUpdateState(to state: String) {
        print("ViewModel received state: \(state)")
    }
}

let service = NetworkService()
let viewModel1 = ViewModel()
let viewModel2 = ViewModel()

// Add delegates
service.delegates += viewModel1
service.delegates += viewModel2

// Trigger invocation
service.changeState()

// Remove delegates
service.delegates -= viewModel1
```

### Operators

Simplify multicast usage

`+=` calls `add(_ delegate: T)` or `add(_ delegate: [T])`

`-=` calls `remove(_ delegate: T)` or `remove(_ delegate: [T])`

`=>` calls `invoke(_ invocation: (T) -> ())`

### License

`SwiftMulticastDelegate` is available under the MIT license.
