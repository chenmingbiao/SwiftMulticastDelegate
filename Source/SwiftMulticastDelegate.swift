//
//  SwiftMulticastDelegate.swift
//  SwiftMulticastDelegate
//
//  Created by BillChan on 04/03/2018.
//  Copyright © 2018 BillChan. All rights reserved.
//

import Foundation

public func += <T> (left: inout SwiftMulticastDelegate<T>?, right: T) {
    
    if left != nil {
        left!.add(delegate: right as AnyObject)
    } else {
        left = SwiftMulticastDelegate(delegate: right as AnyObject)
    }
}

public func -= <T> (left: inout SwiftMulticastDelegate<T>?, right: T) {
    if left != nil {
        left!.remove(delegate: right as AnyObject)
    }
}

private class SwiftMulticastDelegateNode {
    
    weak var delegate: AnyObject!
    
    private(set) var delegateQueue: DispatchQueue!
    
    init(delegate del: AnyObject!, delegateQueue queue: DispatchQueue!) {
        delegate = del
        delegateQueue = queue
    }
    
}

public class SwiftMulticastDelegate<T> {
    
    /** Node Array */
    private var delegateNodes: [SwiftMulticastDelegateNode] = []
    
    /** Init */
    init(delegate: AnyObject) {
        let delegateNode = SwiftMulticastDelegateNode(delegate: delegate, delegateQueue: DispatchQueue.main)
        self.delegateNodes = [delegateNode]
    }
    
    /** Add */
    public func add(delegate: AnyObject!, queue delegateQueue: DispatchQueue = DispatchQueue.main) {
        
        guard let delegate = delegate else {
            return
        }
        
        let node = SwiftMulticastDelegateNode(delegate: delegate, delegateQueue: delegateQueue)
        
        synchronized(lock: delegateNodes as AnyObject!) {
            delegateNodes.append(node)
        }
        
    }
    
    /** Remove */
    public func remove(delegate: AnyObject!, queue delegateQueue: DispatchQueue = DispatchQueue.main) {
        
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
    
    /** Remove All */
    public func removeAll() {
        
        synchronized(lock: delegateNodes as AnyObject!) {
            delegateNodes.removeAll()
        }
        
    }
    
    /** Invoke */
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
    
    deinit {
        removeAll()
    }
    
}

/** Count */
extension SwiftMulticastDelegate {
    
    public func count() -> Int {
        return delegateNodes.count
    }
    
    public func count(class cl: AnyClass) -> Int {
        
        var count: Int = 0
        for delegateNode in delegateNodes {
            if delegateNode.delegate.isKind(of: cl) {
                count += 1
            }
        }
        return count
        
    }
    
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

/** Synchronized */
extension SwiftMulticastDelegate {
    
    private func synchronized(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
}

