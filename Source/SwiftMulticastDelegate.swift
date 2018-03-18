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
    left.add(right as AnyObject)
}

/// Use this operator to remove a delegate.
///
/// This is a convenience operator for calling `remove(delegate: AnyObject!)`.
///
/// - Parameters:
///   - left: The multicast delegate
///   - right: The delegate to be removed
public func -=<T>(left: SwiftMulticastDelegate<T>, right: T) {
    left.remove(right as AnyObject)
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
public func =><T>(left: SwiftMulticastDelegate<T>, right: @escaping (T) -> ()) {
    left.invoke(right)
}

//-------------------------------------------------------------
// MARK: - SwiftMulticastDelegateNode
//-------------------------------------------------------------
private class SwiftMulticastDelegateNode {
    
    /// The Object of Delegate
    weak var delegate: AnyObject!
    
    /// The Queue of Delegate
    private(set) var delegateQueue: DispatchQueue!
    
    /// Init
    ///
    /// - Parameters:
    ///   - delegate: The Object of Delegate
    ///   - delegateQueue: The Queue of Delegate
    init(delegate: AnyObject!, delegateQueue: DispatchQueue!) {
        self.delegate = delegate
        self.delegateQueue = delegateQueue
    }
    
}

//-------------------------------------------------------------
// MARK: - SwiftMulticastDelegate
//-------------------------------------------------------------
public class SwiftMulticastDelegate<T> {
    
    /// Delegate Node Array
    private var delegateNodes: [SwiftMulticastDelegateNode] = []
    
    /// Add Delegate
    ///
    /// - Parameters:
    ///   - delegate: The Callback Object
    ///   - delegateQueue: The Callback Queue
    public func add(_ delegate: AnyObject!, queue delegateQueue: DispatchQueue = DispatchQueue.main) {
        
        guard let delegate = delegate else {
            return
        }
        
        let node = SwiftMulticastDelegateNode(delegate: delegate, delegateQueue: delegateQueue)
        
        synchronized(lock: delegateNodes as AnyObject!) {
            delegateNodes.append(node)
        }
        
    }
    
    /// Remove Delegate
    ///
    /// - Parameters:
    ///   - delegate: The Callback Object
    ///   - delegateQueue: The Callback Queue
    public func remove(_ delegate: AnyObject!, queue delegateQueue: DispatchQueue = DispatchQueue.main) {
        
        guard let delegate = delegate else {
            return
        }
        
        synchronized(lock: delegateNodes as AnyObject!) {
            
            for i in (0..<delegateNodes.count).reversed() {
                
                let delegateNode: SwiftMulticastDelegateNode = delegateNodes[i]
                
                if delegateNode.delegate.isEqual(delegate) {
                    if delegateQueue.isEqual(delegateNode.delegateQueue) {
                        delegateNodes.remove(at: i)
                    }
                }
                
            }
            
        }
        
    }
    
    /// Remove All The Delegates
    public func removeAll() {
        
        synchronized(lock: delegateNodes as AnyObject!) {
            delegateNodes.removeAll()
        }
        
    }
    
    /// Invoke Callback
    ///
    /// - Parameter invocation: The Callback Action
    public func invoke(_ invocation: @escaping (T) -> ()) {
        
        for i in (0..<delegateNodes.count).reversed() {
            let delegateNode: SwiftMulticastDelegateNode = delegateNodes[i]
            
            if delegateNode.delegate == nil {
                delegateNodes.remove(at: i)
            } else {
                delegateNode.delegateQueue.async {
                    guard let delegate = delegateNode.delegate as? T else {
                        return
                    }
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
    
    /// Delegate Nodes Count
    ///
    /// - Returns: Count
    public func count() -> Int {
        return delegateNodes.count
    }
    
    /// Delegate Nodes Count
    ///
    /// - Parameter cl: The Class of DelegateNode
    /// - Returns: Count
    public func count(class cl: AnyClass) -> Int {
        
        var count: Int = 0
        
        for delegateNode in delegateNodes {
            if delegateNode.delegate.isKind(of: cl) {
                count += 1
            }
        }
        
        return count
        
    }
    
    /// Delegate Nodes Count
    ///
    /// - Parameter sel: The Selector of DelegateNode
    /// - Returns: Count
    public func count(selector sel: Selector) -> Int {
        
        var count: Int = 0
        
        for delegateNode in delegateNodes {
            if delegateNode.delegate.responds(to: sel) {
                count += 1
            }
        }
        
        return count
        
    }
    
}

// MARK: - SwiftMulticastDelegate Synchronized Lock
extension SwiftMulticastDelegate {
    
    /// Synchronized Lock
    ///
    /// - Parameters:
    ///   - lock: The Object of Lock
    ///   - closure: Callback
    private func synchronized(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
}

