//
//  IdentifiableContinuationTests.swift
//  IdentifiableContinuation
//
//  Created by Simon Whitty on 20/05/2023.
//  Copyright 2023 Simon Whitty
//
//  Distributed under the permissive MIT license
//  Get the latest version from here:
//
//  https://github.com/swhitty/IdentifiableContinuation
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import IdentifiableContinuation
import XCTest

final class IdentifiableContinuationAsyncTests: XCTestCase {

    func testCancels_After_Created() async {
        let waiter = Waiter<String?, Never>()

        let task = Task<String?, Never> {
            await withIdentifiableContinuation {
                await waiter.addContinuation($0)
            } onCancel: {
                await waiter.resumeID($0, returning: nil)
            }
        }

        await Task.sleep(seconds: 0.1)
        var isEmpty = await waiter.isEmpty
        XCTAssertFalse(isEmpty)
        task.cancel()

        let val = await task.value
        XCTAssertNil(val)

        isEmpty = await waiter.isEmpty
        XCTAssertTrue(isEmpty)
    }

    func testCancelsBody() async {
        let waiter = Waiter<String?, Never>()

        let task = Task<String?, Never> {
            await withIdentifiableContinuation {
                await Task.sleep(seconds: 1)
                await waiter.addContinuation($0)
            } onCancel: {
                await waiter.resumeID($0, returning: nil)
            }
        }

        task.cancel()

        let val = await task.value
        XCTAssertNil(val)
    }

    func testCancels_Before_Created() async {
        let waiter = Waiter<String?, Never>()

        let task = Task<String?, Never> {
            await Task.sleep(seconds: 0.1)
            return await withIdentifiableContinuation {
                await waiter.addContinuation($0)
            } onCancel: {
                await waiter.resumeID($0, returning: nil)
            }
        }

        let isEmpty = await waiter.isEmpty
        XCTAssertTrue(isEmpty)
        task.cancel()

        let val = await task.value
        XCTAssertNil(val)
    }

    func testThrowingCancels_After_Created() async {
        let waiter = Waiter<String, Error>()

        let task = Task<String?, Error> {
            try await withThrowingIdentifiableContinuation {
                await waiter.addContinuation($0)
            } onCancel: {
                await waiter.resumeID($0, throwing: CancellationError())
            }
        }

        await Task.sleep(seconds: 0.1)
        let isEmpty = await waiter.isEmpty
        XCTAssertFalse(isEmpty)
        task.cancel()

        let val = await task.result
        XCTAssertThrowsError(try val.get())
    }

    func testThrowingCancels_Before_Created() async {
        let waiter = Waiter<String, Error>()

        let task = Task<String?, Error> {
            await Task.sleep(seconds: 0.1)
            return try await withThrowingIdentifiableContinuation {
                await waiter.addContinuation($0)
            } onCancel: {
                await waiter.resumeID($0, throwing: CancellationError())
            }
        }

        let isEmpty = await waiter.isEmpty
        XCTAssertTrue(isEmpty)
        task.cancel()

        let val = await task.result
        XCTAssertThrowsError(try val.get())
    }

    func testUnsafeCancels_After_Created() async {
        let waiter = Waiter<String?, Never>()

        let task = Task<String?, Never> {
            await withIdentifiableUnsafeContinuation {
                await waiter.addContinuation($0)
            } onCancel: {
                await waiter.resumeID($0, returning: nil)
            }
        }

        await Task.sleep(seconds: 0.1)
        let isEmpty = await waiter.isEmpty
        XCTAssertFalse(isEmpty)
        task.cancel()

        let val = await task.value
        XCTAssertNil(val)
    }

    func testUnsafeCancels_Before_Created() async {
        let waiter = Waiter<String?, Never>()

        let task = Task<String?, Never> {
            await Task.sleep(seconds: 0.1)
            return await withIdentifiableUnsafeContinuation {
                await waiter.addContinuation($0)
            } onCancel: {
                await waiter.resumeID($0, returning: nil)
            }
        }

        let isEmpty = await waiter.isEmpty
        XCTAssertTrue(isEmpty)
        task.cancel()

        let val = await task.value
        XCTAssertNil(val)
    }

    func testUnsafeThrowingCancels_After_Created() async {
        let waiter = Waiter<String, Error>()

        let task = Task<String?, Error> {
            try await withThrowingIdentifiableUnsafeContinuation {
                await waiter.addContinuation($0)
            } onCancel: {
                await waiter.resumeID($0, throwing: CancellationError())
            }
        }

        await Task.sleep(seconds: 0.1)
        let isEmpty = await waiter.isEmpty
        XCTAssertFalse(isEmpty)
        task.cancel()

        let val = await task.result
        XCTAssertThrowsError(try val.get())
    }

    func testUnsafeThrowingCancels_Before_Created() async {
        let waiter = Waiter<String, Error>()

        let task = Task<String?, Error> {
            await Task.sleep(seconds: 0.1)
            return try await withThrowingIdentifiableUnsafeContinuation {
                await waiter.addContinuation($0)
            } onCancel: {
                await waiter.resumeID($0, throwing: CancellationError())
            }
        }

        let isEmpty = await waiter.isEmpty
        XCTAssertTrue(isEmpty)
        task.cancel()

        let val = await task.result
        XCTAssertThrowsError(try val.get())
    }
}

private actor Waiter<T, E: Error> {
    typealias Continuation = IdentifiableContinuation<T, E>

    private var waiting = [Continuation.ID: Continuation]()

    var isEmpty: Bool {
        waiting.isEmpty
    }

    func addContinuation(_ continuation: Continuation) {
        waiting[continuation.id] = continuation
    }

    func resumeID(_ id: Continuation.ID, returning value: T) {
        if let continuation = waiting.removeValue(forKey: id) {
            continuation.resume(returning: value)
        }
    }

    func resumeID(_ id: Continuation.ID, throwing error: E) {
        if let continuation = waiting.removeValue(forKey: id) {
            continuation.resume(throwing: error)
        }
    }
}

private extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: TimeInterval) async {
        try? await sleep(nanoseconds: UInt64(1_000_000_000 * seconds))
    }
}
