# SwiftMulticastDelegate
[English](README.md) | [中文版](README_zh.md)

[![Build Status](https://github.com/chenmingbiao/SwiftMulticastDelegate/actions/workflows/swift.yml/badge.svg)](https://github.com/chenmingbiao/SwiftMulticastDelegate/actions)
![Swift 6.0+](https://img.shields.io/badge/Swift-6.0%2B-orange.svg) 
![iOS 12+](http://img.shields.io/badge/iOS-12.0%2B-blue.svg)
![License](https://img.shields.io/cocoapods/l/SwiftKVO.svg?style=flat)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)

在 Swift 中实现的多播委托（Multicast Delegate），采用纯 Swift 原生写法，全面支持 Swift 6 严格并发检查（Strict Concurrency）与多平台。

### 安装方式

#### 1. 手动安装:

直接将 `Source/SwiftMulticastDelegate.swift` 复制到您的项目中。

#### 2. CocoaPods:

```ruby
pod 'SwiftMulticastDelegate', :git => 'https://github.com/chenmingbiao/SwiftMulticastDelegate.git'
```

#### 3. Swift Package Manager:

您可以使用 [Swift Package Manager](https://swift.org/package-manager/) 并在您的 `Package.swift` 中添加为依赖：
```swift
dependencies: [
    .package(url: "https://github.com/chenmingbiao/SwiftMulticastDelegate.git", from: "1.0.0")
]
```

### 使用方法

导入模块
```swift
import SwiftMulticastDelegate
```

1. 在你的类中添加：`let delegates = SwiftMulticastDelegate<MyProtocol>()`
2. 其他模块或类添加自身为委托对象：`obj.delegates.add(self)`
3. 当你需要触发回调通知委托列表时：`delegates.invoke { delegate in delegate.func() }`

更简便的操作符写法：

1. 添加属性：`let delegates = SwiftMulticastDelegate<MyProtocol>()`
2. 添加委托对象：`obj.delegates += self`
3. 触发回调通知：`delegates => { $0.func() }`


### 代码示例

```swift
// MARK: - Delegate Protocol (注意使用 Sendable 即可保证 Swift 6 跨界并发安全)
protocol ServiceStateDelegate: AnyObject, Sendable {
    func didUpdateState(to state: String)
}

// MARK: - Service
class NetworkService {
    var delegates = SwiftMulticastDelegate<ServiceStateDelegate>()

    func changeState() {
        // ... 一些业务逻辑 ...
        delegates => {
            $0.didUpdateState(to: "Connected")
        }
    }
}

// MARK: - Observer
final class ViewModel: ServiceStateDelegate, @unchecked Sendable {
    func didUpdateState(to state: String) {
        print("ViewModel 接收到状态更新: \(state)")
    }
}

let service = NetworkService()
let viewModel1 = ViewModel()
let viewModel2 = ViewModel()

// 添加委托
service.delegates += viewModel1
service.delegates += viewModel2

// 触发所有的委托回调
service.changeState()

// 移除指定的委托
service.delegates -= viewModel1
```

### 操作符说明

简化多播委托的代码使用体验：

`+=` 等同于调用 `add(_ delegate: T)` 或是 `add(_ delegates: [T])`

`-=` 等同于调用 `remove(_ delegate: T)` 或是 `remove(_ delegates: [T])`

`=>` 等同于调用 `invoke(_ invocation: @escaping @Sendable (T) -> ())`

### 许可证

`SwiftMulticastDelegate` 采用 MIT 许可证开放源代码。
