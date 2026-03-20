import XCTest
@testable import SwiftMulticastDelegate

final class MockDelegate: @unchecked Sendable {
    private let lock = NSLock()
    private var _callCount = 0
    
    var callCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _callCount
    }
    
    func trigger() {
        lock.lock()
        defer { lock.unlock() }
        _callCount += 1
    }
}

final class SwiftMulticastDelegateTests: XCTestCase {
    
    func testAddAndInvoke() {
        let multicast = SwiftMulticastDelegate<MockDelegate>()
        let delegate1 = MockDelegate()
        let delegate2 = MockDelegate()
        
        multicast += delegate1
        multicast.add(delegate2)
        
        XCTAssertEqual(multicast.count(), 2)
        
        let expectation = XCTestExpectation(description: "invoked")
        expectation.expectedFulfillmentCount = 2
        
        multicast => { delegate in
            delegate.trigger()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(delegate1.callCount, 1)
        XCTAssertEqual(delegate2.callCount, 1)
    }
    
    func testRemove() {
        let multicast = SwiftMulticastDelegate<MockDelegate>()
        let delegate1 = MockDelegate()
        
        multicast += delegate1
        XCTAssertEqual(multicast.count(), 1)
        
        multicast -= delegate1
        XCTAssertEqual(multicast.count(), 0)
    }
    
    func testWeakReferences() {
        let multicast = SwiftMulticastDelegate<MockDelegate>()
        var delegate1: MockDelegate? = MockDelegate()
        
        multicast += delegate1!
        XCTAssertEqual(multicast.count(), 1)
        
        delegate1 = nil
        // The count should automatically be 0 after cleanup
        XCTAssertEqual(multicast.count(), 0)
    }
    
    func testConcurrency() {
        let multicast = SwiftMulticastDelegate<MockDelegate>()
        
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        let group = DispatchGroup()
        
        // Add thousands of delegates concurrently
        for _ in 0..<1000 {
            group.enter()
            queue.async {
                multicast += MockDelegate()
                group.leave()
            }
        }
        
        // Concurrently invoke while adding
        for _ in 0..<100 {
            group.enter()
            queue.async {
                multicast => { $0.trigger() }
                group.leave()
            }
        }
        
        group.wait()
        
        // We expect some delegates might have been cleaned up if they were released, 
        // but since we don't hold them strongly array count might vary based on ARC timing.
        // What we care about is that it didn't crash.
        // Actually, let's keep references if we want to confirm count:
        var strongReferences = [MockDelegate]()
        let lock = NSLock()
        
        for _ in 0..<1000 {
            let del = MockDelegate()
            lock.lock()
            strongReferences.append(del)
            lock.unlock()
            
            group.enter()
            queue.async {
                multicast += del
                group.leave()
            }
        }
        group.wait()
        
        XCTAssertEqual(multicast.count(), 1000)
        multicast.removeAll()
        XCTAssertEqual(multicast.count(), 0)
    }
}
