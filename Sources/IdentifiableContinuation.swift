//
//  IdentifiableContinuation.swift
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

import Foundation

@inlinable
public func withIdentifiableContinuation<T>(
    function: String = #function,
    body: (IdentifiableContinuation<T, Never>) -> Void
) async -> T {
    await withCheckedContinuation(function: function) {
        body(IdentifiableContinuation(storage: .checked($0)))
    }
}

@inlinable
public func withThrowingIdentifiableContinuation<T>(
    function: String = #function,
    body: (IdentifiableContinuation<T, Error>) -> Void
) async throws -> T {
    try await withCheckedThrowingContinuation(function: function) {
        body(IdentifiableContinuation(storage: .checked($0)))
    }
}

@inlinable
public func withIdentifiableUnsafeContinuation<T>(
    body: (IdentifiableContinuation<T, Never>) -> Void
) async -> T {
    await withUnsafeContinuation {
        body(IdentifiableContinuation(storage: .unsafe($0)))
    }
}

@inlinable
public func withThrowingIdentifiableUnsafeContinuation<T>(
    body: (IdentifiableContinuation<T, Error>) -> Void
) async throws -> T {
    try await withUnsafeThrowingContinuation {
        body(IdentifiableContinuation(storage: .unsafe($0)))
    }
}

@inlinable
public func withIdentifiableContinuation<T>(
    function: String = #function,
    body: (IdentifiableContinuation<T, Never>) -> Void,
    onCancel: (IdentifiableContinuation<T, Never>.ID) -> Void
) async -> T {
    let id = IdentifiableContinuation<T, Never>.ID()
    return await withoutActuallyEscaping(body, onCancel, result: T.self) {
        let state = LockedState(body: $0, onCancel: $1)
        return await withTaskCancellationHandler {
            await withCheckedContinuation(function: function) {
                let continuation = IdentifiableContinuation(id: id, storage: .checked($0))
                state.start(with: continuation)
            }
        } onCancel: {
            state.cancel(withID: id)
        }
    }
}

@inlinable
public func withIdentifiableContinuation<T>(
    function: String = #function,
    body: (IdentifiableContinuation<T, Never>) async -> Void,
    onCancel: (IdentifiableContinuation<T, Never>.ID) async -> Void
) async -> T {
    return await withoutActuallyEscaping(body, onCancel, result: T.self) {
        let state = AsyncLockedState(body: $0, onCancel: $1)
        return await state.startCheckedContinuation(function: function)
    }
}

@inlinable
public func withThrowingIdentifiableContinuation<T>(
    function: String = #function,
    body: (IdentifiableContinuation<T, Error>) -> Void,
    onCancel: (IdentifiableContinuation<T, Error>.ID) -> Void
) async throws -> T {
    let id = IdentifiableContinuation<T, Error>.ID()
    return try await withoutActuallyEscaping(body, onCancel, result: T.self) {
        let state = LockedState(body: $0, onCancel: $1)
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation(function: function) {
                let continuation = IdentifiableContinuation(id: id, storage: .checked($0))
                state.start(with: continuation)
            }
        } onCancel: {
            state.cancel(withID: id)
        }
    }
}

@inlinable
public func withThrowingIdentifiableContinuation<T>(
    function: String = #function,
    body: (IdentifiableContinuation<T, Error>) async -> Void,
    onCancel: (IdentifiableContinuation<T, Error>.ID) async -> Void
) async throws -> T {
    try await withoutActuallyEscaping(body, onCancel, result: T.self) {
        let state = AsyncLockedState(body: $0, onCancel: $1)
        return try await state.startCheckedThrowingContinuation(function: function)
    }
}

@inlinable
public func withIdentifiableUnsafeContinuation<T>(
    body: (IdentifiableContinuation<T, Never>) -> Void,
    onCancel: (IdentifiableContinuation<T, Never>.ID) -> Void
) async -> T {
    let id = IdentifiableContinuation<T, Never>.ID()
    return await withoutActuallyEscaping(body, onCancel, result: T.self) {
        let state = LockedState(body: $0, onCancel: $1)
        return await withTaskCancellationHandler {
            await withUnsafeContinuation {
                let continuation = IdentifiableContinuation(id: id, storage: .unsafe($0))
                state.start(with: continuation)
            }
        } onCancel: {
            state.cancel(withID: id)
        }
    }
}

@inlinable
public func withIdentifiableUnsafeContinuation<T>(
    body: (IdentifiableContinuation<T, Never>) async -> Void,
    onCancel: (IdentifiableContinuation<T, Never>.ID) async -> Void
) async -> T {
    await withoutActuallyEscaping(body, onCancel, result: T.self) {
        let state = AsyncLockedState(body: $0, onCancel: $1)
        return await state.startUnsafeContinuation()
    }
}

@inlinable
public func withThrowingIdentifiableUnsafeContinuation<T>(
    body: (IdentifiableContinuation<T, Error>) -> Void,
    onCancel: (IdentifiableContinuation<T, Error>.ID) -> Void
) async throws -> T {
    let id = IdentifiableContinuation<T, Error>.ID()
    return try await withoutActuallyEscaping(body, onCancel, result: T.self) {
        let state = LockedState(body: $0, onCancel: $1)
        return try await withTaskCancellationHandler {
            try await withUnsafeThrowingContinuation {
                let continuation = IdentifiableContinuation(id: id, storage: .unsafe($0))
                state.start(with: continuation)
            }
        } onCancel: {
            state.cancel(withID: id)
        }
    }
}

@inlinable
public func withThrowingIdentifiableUnsafeContinuation<T>(
    body: (IdentifiableContinuation<T, Error>) async -> Void,
    onCancel: (IdentifiableContinuation<T, Error>.ID) async -> Void
) async throws -> T {
    try await withoutActuallyEscaping(body, onCancel, result: T.self) {
        let state = AsyncLockedState(body: $0, onCancel: $1)
        return try await state.startUnsafeThrowingContinuation()
    }
}

public struct IdentifiableContinuation<T, E>: Sendable, Identifiable where E : Error {

    public let id: ID

    public final class ID: Hashable, Sendable {

        @usableFromInline
        init() { }

        public func hash(into hasher: inout Hasher) {
            ObjectIdentifier(self).hash(into: &hasher)
        }

        public static func == (lhs: IdentifiableContinuation<T, E>.ID, rhs: IdentifiableContinuation<T, E>.ID) -> Bool {
            lhs === rhs
        }
    }

    @usableFromInline
    init(id: ID = .init(), storage: Storage) {
        self.id = id
        self.storage = storage
    }

    private let storage: Storage

    public func resume(returning value: T) {
        switch storage {
        case .checked(let continuation):
            continuation.resume(returning: value)
        case .unsafe(let continuation):
            continuation.resume(returning: value)
        }
    }

    public func resume(throwing error: E) {
        switch storage {
        case .checked(let continuation):
            continuation.resume(throwing: error)
        case .unsafe(let continuation):
            continuation.resume(throwing: error)
        }
    }

    public func resume(with result: Result<T, E>) {
        switch storage {
        case .checked(let continuation):
            continuation.resume(with: result)
        case .unsafe(let continuation):
            continuation.resume(with: result)
        }
    }

    @usableFromInline
    enum Storage: Sendable {
        case checked(CheckedContinuation<T, E>)
        case unsafe(UnsafeContinuation<T, E>)
    }
}

@usableFromInline
final class LockedState<T, Failure: Error>: @unchecked Sendable {
    private let lock = NSLock()
    private var state: State
    private let body: (IdentifiableContinuation<T, Failure>) -> Void
    private let onCancel: (IdentifiableContinuation<T, Failure>.ID) -> Void

    @usableFromInline
    struct State {
        @usableFromInline
        var isStarted: Bool = false
        @usableFromInline
        var isCancelled: Bool = false
    }

    @usableFromInline
    init(body: @escaping (IdentifiableContinuation<T, Failure>) -> Void,
         onCancel: @escaping (IdentifiableContinuation<T, Failure>.ID) -> Void) {
        self.state = State()
        self.body = body
        self.onCancel = onCancel
    }

    @usableFromInline
    func start(with continuation: IdentifiableContinuation<T, Failure>) {
        body(continuation)
        let isCancelled = withCriticalRegion {
            $0.isStarted = true
            return $0.isCancelled
        }
        if isCancelled {
            onCancel(continuation.id)
        }
    }

    @usableFromInline
    func cancel(withID id: IdentifiableContinuation<T, Failure>.ID) {
        let isStarted = withCriticalRegion {
            $0.isCancelled = true
            return $0.isStarted
        }
        if isStarted {
            onCancel(id)
        }
    }

    @usableFromInline
    func withCriticalRegion<R>(_ critical: (inout State) throws -> R) rethrows -> R {
        lock.lock()
        defer { lock.unlock() }
        return try critical(&state)
    }
}

@usableFromInline
final class AsyncLockedState<T, Failure: Error>: @unchecked Sendable {
    private let lock = NSLock()
    private var state: State
    private let body: (IdentifiableContinuation<T, Failure>) async -> Void
    private let onCancel: (IdentifiableContinuation<T, Failure>.ID) async -> Void

    @usableFromInline
    struct State {
        @usableFromInline
        var bodyTask: Task<Void, Never>?
        @usableFromInline
        var cancelTask: Task<Void, Never>?
        @usableFromInline
        var didCompleteBody: Bool = false
        @usableFromInline
        var isCancelled: Bool = false
        @usableFromInline
        var didCancel: Bool = false
    }

    @usableFromInline
    init(body: @escaping (IdentifiableContinuation<T, Failure>) async -> Void,
         onCancel: @escaping (IdentifiableContinuation<T, Failure>.ID) async -> Void) {
        self.state = State()
        self.body = body
        self.onCancel = onCancel
    }

    @usableFromInline
    func startCheckedContinuation(function: String) async -> T where Failure == Never {
        let id = IdentifiableContinuation<T, Failure>.ID()
        return await withTaskCancellationHandler {
            let result = await withCheckedContinuation(function: function) {
                let continuation = IdentifiableContinuation(id: id, storage: .checked($0))
                start(with: continuation)
            }
            await waitForTasks()
            return result
        } onCancel: {
            cancel(withID: id)
        }
    }

    @usableFromInline
    func startCheckedThrowingContinuation(function: String) async throws -> T where Failure == Error {
        let id = IdentifiableContinuation<T, Failure>.ID()
        return try await withTaskCancellationHandler {
            do {
                let result = try await withCheckedThrowingContinuation(function: function) {
                    let continuation = IdentifiableContinuation(id: id, storage: .checked($0))
                    start(with: continuation)
                }
                await waitForTasks()
                return result
            } catch {
                await waitForTasks()
                throw error
            }
        } onCancel: {
            cancel(withID: id)
        }
    }

    @usableFromInline
    func startUnsafeContinuation() async -> T where Failure == Never {
        let id = IdentifiableContinuation<T, Failure>.ID()
        return await withTaskCancellationHandler {
            let result = await withUnsafeContinuation {
                let continuation = IdentifiableContinuation(id: id, storage: .unsafe($0))
                start(with: continuation)
            }
            await waitForTasks()
            return result
        } onCancel: {
            cancel(withID: id)
        }
    }

    @usableFromInline
    func startUnsafeThrowingContinuation() async throws -> T where Failure == Error {
        let id = IdentifiableContinuation<T, Failure>.ID()
        return try await withTaskCancellationHandler {
            do {
                let result = try await withUnsafeThrowingContinuation {
                    let continuation = IdentifiableContinuation(id: id, storage: .unsafe($0))
                    start(with: continuation)
                }
                await waitForTasks()
                return result
            } catch {
                await waitForTasks()
                throw error
            }
        } onCancel: {
            cancel(withID: id)
        }
    }

    @usableFromInline
    func start(with continuation: IdentifiableContinuation<T, Failure>) {
        let task = Task {
            await body(continuation)
            let performCancel = withCriticalRegion {
                $0.didCompleteBody = true
                if $0.isCancelled && !$0.didCancel {
                    $0.didCancel = true
                    return true
                } else {
                    return false
                }
            }
            if performCancel {
                await onCancel(continuation.id)
            }
        }
        withCriticalRegion {
            $0.bodyTask = task
        }
    }

    @usableFromInline
    func cancel(withID id: IdentifiableContinuation<T, Failure>.ID) {
        let task = Task {
            let performCancel = withCriticalRegion {
                $0.isCancelled = true
                $0.bodyTask?.cancel()
                if $0.didCompleteBody && !$0.didCancel {
                    $0.didCancel = true
                    return true
                } else {
                    return false
                }
            }
            if performCancel {
                await onCancel(id)
            }
        }
        withCriticalRegion {
            $0.cancelTask = task
        }
    }

    @usableFromInline
    func waitForTasks() async {
        let (bodyTask, cancelTask) = withCriticalRegion {
            ($0.bodyTask, $0.cancelTask)
        }
        _ = await (bodyTask?.value, cancelTask?.value)
    }

    @usableFromInline
    func withCriticalRegion<R>(_ critical: (inout State) throws -> R) rethrows -> R {
        lock.lock()
        defer { lock.unlock() }
        return try critical(&state)
    }
}

@usableFromInline
func withoutActuallyEscaping<T, Failure: Error, U>(
    _ c1: (IdentifiableContinuation<T, Failure>) -> Void,
    _ c2: (IdentifiableContinuation<T, Failure>.ID) -> Void,
    result: U.Type,
    do body: (@escaping (IdentifiableContinuation<T, Failure>) -> Void, @escaping (IdentifiableContinuation<T, Failure>.ID) -> Void) async throws -> U) async rethrows -> U {
    try await withoutActuallyEscaping(c1) { (escapingC1) -> U in
        try await withoutActuallyEscaping(c2) { (escapingC2) -> U in
            try await body(escapingC1, escapingC2)
        }
    }
}

@usableFromInline
func withoutActuallyEscaping<T, Failure: Error, U>(
    _ c1: (IdentifiableContinuation<T, Failure>) async -> Void,
    _ c2: (IdentifiableContinuation<T, Failure>.ID) async -> Void,
    result: U.Type,
    do body: (@escaping (IdentifiableContinuation<T, Failure>) async -> Void, @escaping (IdentifiableContinuation<T, Failure>.ID) async -> Void) async throws -> U) async rethrows -> U {
    try await withoutActuallyEscaping(c1) { (escapingC1) -> U in
        try await withoutActuallyEscaping(c2) { (escapingC2) -> U in
            try await body(escapingC1, escapingC2)
        }
    }
}
