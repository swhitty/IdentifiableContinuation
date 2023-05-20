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

final class IdentifiableContinuationTests: XCTestCase {

    func testResumesWithValue() async {
        let val = await withIdentifiableContinuation {
            $0.resume(returning: "Fish")
        }
        XCTAssertEqual(val, "Fish")
    }

    func testCancels_After_Created() async {
        let waiter = Waiter<String?, Never>()

        let task = Task<String?, Never> {
            await withIdentifiableContinuation {
                waiter.addContinuation($0)
            } onCancel: {
                waiter.resumeID($0, returning: nil)
            }
        }

        await Task.sleep(seconds: 0.1)
        XCTAssertFalse(waiter.isEmpty)
        task.cancel()

        let val = await task.value
        XCTAssertNil(val)
    }

    func testCancels_Before_Created() async {
        let waiter = Waiter<String?, Never>()

        let task = Task<String?, Never> {
            await Task.sleep(seconds: 0.1)
            return await withIdentifiableContinuation {
                waiter.addContinuation($0)
            } onCancel: {
                waiter.resumeID($0, returning: nil)
            }
        }

        XCTAssertTrue(waiter.isEmpty)
        task.cancel()

        let val = await task.value
        XCTAssertNil(val)
    }

    func testThrowingResumesWithError() async {
        do {
            let _: Int = try await withThrowingIdentifiableContinuation {
                $0.resume(throwing: CancellationError())
            }
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
    }


    func testThrowingCancels_After_Created() async {
        let waiter = Waiter<String, Error>()

        let task = Task<String?, Error> {
            try await withThrowingIdentifiableContinuation {
                waiter.addContinuation($0)
            } onCancel: {
                waiter.resumeID($0, throwing: CancellationError())
            }
        }

        await Task.sleep(seconds: 0.1)
        XCTAssertFalse(waiter.isEmpty)
        task.cancel()

        let val = await task.result
        XCTAssertThrowsError(try val.get())
    }

    func testThrowingCancels_Before_Created() async {
        let waiter = Waiter<String, Error>()

        let task = Task<String?, Error> {
            await Task.sleep(seconds: 0.1)
            return try await withThrowingIdentifiableContinuation {
                waiter.addContinuation($0)
            } onCancel: {
                waiter.resumeID($0, throwing: CancellationError())
            }
        }

        XCTAssertTrue(waiter.isEmpty)
        task.cancel()

        let val = await task.result
        XCTAssertThrowsError(try val.get())
    }

    func testUnsafeResumesWithValue() async {
        let val = await withIdentifiableUnsafeContinuation {
            $0.resume(returning: "Fish")
        }
        XCTAssertEqual(val, "Fish")
    }

    func testUnsafeCancels_After_Created() async {
        let waiter = Waiter<String?, Never>()

        let task = Task<String?, Never> {
            await withIdentifiableUnsafeContinuation {
                waiter.addContinuation($0)
            } onCancel: {
                waiter.resumeID($0, returning: nil)
            }
        }

        await Task.sleep(seconds: 0.1)
        XCTAssertFalse(waiter.isEmpty)
        task.cancel()

        let val = await task.value
        XCTAssertNil(val)
    }

    func testUnsafeCancels_Before_Created() async {
        let waiter = Waiter<String?, Never>()

        let task = Task<String?, Never> {
            await Task.sleep(seconds: 0.1)
            return await withIdentifiableUnsafeContinuation {
                waiter.addContinuation($0)
            } onCancel: {
                waiter.resumeID($0, returning: nil)
            }
        }

        XCTAssertTrue(waiter.isEmpty)
        task.cancel()

        let val = await task.value
        XCTAssertNil(val)
    }

    func testUnsafeThrowingResumesWithError() async {
        do {
            let _: Int = try await withThrowingIdentifiableUnsafeContinuation {
                $0.resume(throwing: CancellationError())
            }
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
    }


    func testUnsafeThrowingCancels_After_Created() async {
        let waiter = Waiter<String, Error>()

        let task = Task<String?, Error> {
            try await withThrowingIdentifiableUnsafeContinuation {
                waiter.addContinuation($0)
            } onCancel: {
                waiter.resumeID($0, throwing: CancellationError())
            }
        }

        await Task.sleep(seconds: 0.1)
        XCTAssertFalse(waiter.isEmpty)
        task.cancel()

        let val = await task.result
        XCTAssertThrowsError(try val.get())
    }

    func testUnsafeThrowingCancels_Before_Created() async {
        let waiter = Waiter<String, Error>()

        let task = Task<String?, Error> {
            await Task.sleep(seconds: 0.1)
            return try await withThrowingIdentifiableUnsafeContinuation {
                waiter.addContinuation($0)
            } onCancel: {
                waiter.resumeID($0, throwing: CancellationError())
            }
        }

        XCTAssertTrue(waiter.isEmpty)
        task.cancel()

        let val = await task.result
        XCTAssertThrowsError(try val.get())
    }
}

final class Waiter<T, E: Error> {
    typealias Continuation = IdentifiableContinuation<T, E>

    private var waiting = [Continuation.ID: Continuation]()
    private let lock = NSLock()

    var isEmpty: Bool {
        lock.lock()
        defer { lock.unlock() }
        return waiting.isEmpty
    }

    func addContinuation(_ continuation: Continuation) {
        lock.lock()
        waiting[continuation.id] = continuation
        lock.unlock()
    }

    func resumeID(_ id: Continuation.ID, returning value: T) {
        lock.lock()
        waiting[id]!.resume(returning: value)
        lock.unlock()
    }

    func resumeID(_ id: Continuation.ID, throwing error: E) {
        lock.lock()
        waiting[id]!.resume(throwing: error)
        lock.unlock()
    }
}

private extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: TimeInterval) async {
        try? await sleep(nanoseconds: UInt64(1_000_000_000 * seconds))
    }
}
