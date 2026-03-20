//
//  SwiftMulticastDelegate.swift
//  SwiftMulticastDelegate
//
//  Created by BillChan on 04/03/2018.
//  Copyright © 2018 BillChan. All rights reserved.
//

import Foundation

//-------------------------------------------------------------
// MARK: - Define Operators
//-------------------------------------------------------------

/// Use this operator to add a delegate.
///
/// This is a convenience operator for calling `add(delegate: AnyObject!)`.
///
/// - Parameters:
///   - left: The multicast delegate
///   - right: The delegate to be added
public func +=<T>(left: SwiftMulticastDelegate<T>, right: T) {
    left.add(right)
}

/// Use this operator to add delegates.
///
/// - Parameters:
///   - left: The multicast delegate
///   - rights: The delegate Array to be added
public func +=<T>(left: SwiftMulticastDelegate<T>, rights: [T]) {
    left.add(rights)
}

/// Use this operator to remove a delegate.
///
/// This is a convenience operator for calling `remove(delegate: AnyObject!)`.
///
/// - Parameters:
///   - left: The multicast delegate
///   - right: The delegate to be removed
public func -=<T>(left: SwiftMulticastDelegate<T>, right: T) {
    left.remove(right)
}

/// Use this operator to remove delegates.
///
/// - Parameters:
///   - left: The multicast delegate
///   - rights: The delegate Array to be removed
public func -=<T>(left: SwiftMulticastDelegate<T>, rights: [T]) {
    left.remove(rights)
}

/// Use this operator invoke a closure on each delegate.
///
/// This is a convenience operator for calling `invoke(_ invocation: @escaping (T) -> ())`.
///
///  - parameter left: The multicast delegate
///  - parameter right: The closure to be invoked on each delegate
///
///  - returns: The `SwiftMulticastDelegate` after all its delegates have been invoked
precedencegroup SwiftMulticastDelegatePrecedence {
    associativity: left
    higherThan: TernaryPrecedence
}
infix operator => : SwiftMulticastDelegatePrecedence
public func =><T>(left: SwiftMulticastDelegate<T>, right: @escaping @Sendable (T) -> ()) {
    left.invoke(right)
}

//-------------------------------------------------------------
// MARK: - SwiftMulticastDelegateNode
//-------------------------------------------------------------
private struct SwiftMulticastDelegateNode {
    
    /// The Object of Delegate
    weak var delegate: AnyObject?
    
    /// The Queue of Delegate
    private(set) var delegateQueue: DispatchQueue
    
    /// Init
    ///
    /// - Parameters:
    ///   - delegate: The Object of Delegate
    ///   - delegateQueue: The Queue of Delegate
    init(delegate: AnyObject, delegateQueue: DispatchQueue) {
        self.delegate = delegate
        self.delegateQueue = delegateQueue
    }
    
}

//-------------------------------------------------------------
// MARK: - SwiftMulticastDelegate
//-------------------------------------------------------------
public class SwiftMulticastDelegate<T: Sendable>: @unchecked Sendable {
    
    /// Delegate Node Array
    private var delegateNodes: [SwiftMulticastDelegateNode] = []
    
    /// Lock for Thread Safety
    private let lock = NSLock()
    
    public init() {}
    
    /// Add Delegate
    ///
    /// - Parameters:
    ///   - delegate: The Callback Object
    ///   - delegateQueue: The Callback Queue
    public func add(_ delegate: T, queue delegateQueue: DispatchQueue = DispatchQueue.main) {
        let node = SwiftMulticastDelegateNode(delegate: delegate as AnyObject, delegateQueue: delegateQueue)
        
        lock.lock()
        defer { lock.unlock() }
        delegateNodes.append(node)
    }
    
    /// Add Delegates
    ///
    /// - Parameters:
    ///   - delegate: The Callback Object
    ///   - delegateQueue: The Callback Queue
    public func add(_ delegates: [T], queue delegateQueue: DispatchQueue = DispatchQueue.main) {
        for delegate in delegates {
            add(delegate, queue: delegateQueue)
        }
    }
    
    /// Remove Delegate
    ///
    /// - Parameters:
    ///   - delegate: The Callback Object Array
    ///   - delegateQueue: The Callback Queue
    public func remove(_ delegate: T, queue delegateQueue: DispatchQueue = DispatchQueue.main) {
        let delegateAnyObject = delegate as AnyObject
        
        lock.lock()
        defer { lock.unlock() }
        
        delegateNodes.removeAll { node in
            guard let nodeDelegate = node.delegate else {
                return true // Clean up nil nodes
            }
            return nodeDelegate === delegateAnyObject && node.delegateQueue == delegateQueue
        }
    }
    
    /// Remove Delegates
    ///
    /// - Parameters:
    ///   - delegate: The Callback Object Array
    ///   - delegateQueue: The Callback Queue
    public func remove(_ delegates: [T], queue delegateQueue: DispatchQueue = DispatchQueue.main) {
        for delegate in delegates {
            remove(delegate, queue: delegateQueue)
        }
    }
    
    /// Remove All The Delegates
    public func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        delegateNodes.removeAll()
    }
    
    /// Use this method to determine if the multicast delegate contains a given delegate.
    ///
    /// - Parameter delegate: The given delegate to check if it's contained
    /// - Returns: `true` if the delegate is found or `false` otherwise
    public func contain(_ delegate: T) -> Bool {
        let delegateAnyObject = delegate as AnyObject
        
        lock.lock()
        defer { lock.unlock() }
        
        return delegateNodes.contains { node in
            node.delegate === delegateAnyObject
        }
    }
    
    /// Invoke Callback
    ///
    /// - Parameter invocation: The Callback Action
    public func invoke(_ invocation: @escaping @Sendable (T) -> ()) {
        lock.lock()
        // Capture current snapshot of valid nodes safely inside lock
        let currentNodes = delegateNodes
        // Clean up nil delegates while processing
        delegateNodes.removeAll { $0.delegate == nil }
        lock.unlock()
        
        for delegateNode in currentNodes {
            if let delegate = delegateNode.delegate as? T {
                delegateNode.delegateQueue.async {
                    invocation(delegate)
                }
            }
        }
    }
    
    /// Deinit
    deinit {
        removeAll()
    }
    
}

// MARK: - SwiftMulticastDelegate Count
extension SwiftMulticastDelegate {
    
    /// Delegate Nodes Count. Safe for concurrent reading.
    ///
    /// - Returns: Valid delegate count
    public func count() -> Int {
        lock.lock()
        defer { lock.unlock() }
        // Clean up nil delegates to return an accurate count
        delegateNodes.removeAll { $0.delegate == nil }
        return delegateNodes.count
    }
}
