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
public func withIdentifiableContinuation<T>(
    function: String = #function,
    body: (IdentifiableContinuation<T, Never>) -> Void,
    onCancel: (IdentifiableContinuation<T, Never>.ID) -> Void
) async -> T {
    let id = IdentifiableContinuation<T, Never>.ID()
    let state = LockedState(state: (isStarted: false, isCancelled: false))
    return await withTaskCancellationHandler {
        await withCheckedContinuation(function: function) {
            body(IdentifiableContinuation(id: id, storage: .checked($0)))
            let isCancelled = state.withCriticalRegion {
                $0.isStarted = true
                return $0.isCancelled
            }
            if isCancelled {
                onCancel(id)
            }
        }
    } onCancel: {
        let isStarted = state.withCriticalRegion {
            $0.isCancelled = true
            return $0.isStarted
        }
        if isStarted {
            onCancel(id)
        }
    }
}

@inlinable
public func withThrowingIdentifiableContinuation<T>(
    function: String = #function,
    body: (IdentifiableContinuation<T, Error>) -> Void,
    onCancel: (IdentifiableContinuation<T, Error>.ID) -> Void
) async throws -> T {
    let id = IdentifiableContinuation<T, Error>.ID()
    let state = LockedState(state: (isStarted: false, isCancelled: false))
    return try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation(function: function) {
            body(IdentifiableContinuation(id: id, storage: .checked($0)))
            let isCancelled = state.withCriticalRegion {
                $0.isStarted = true
                return $0.isCancelled
            }
            if isCancelled {
                onCancel(id)
            }
        }
    } onCancel: {
        let isStarted = state.withCriticalRegion {
            $0.isCancelled = true
            return $0.isStarted
        }
        if isStarted {
            onCancel(id)
        }
    }
}

public struct IdentifiableContinuation<T, E>: Sendable, Identifiable where E : Error {

    public let id: ID

    public struct ID: Hashable, Sendable {
        private let uuid: UUID

        @usableFromInline
        init() {
            self.uuid = UUID()
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

    @usableFromInline
    enum Storage: Sendable {
        case checked(CheckedContinuation<T, E>)
        case unsafe(UnsafeContinuation<T, E>)
    }
}

@usableFromInline
final class LockedState<State> {
    private let lock = NSLock()
    private var state: State

    @usableFromInline
    init(state: State) {
        self.state = state
    }

    @usableFromInline
    func withCriticalRegion<R>(_ critical: (inout State) throws -> R) rethrows -> R {
        lock.lock()
        defer { lock.unlock() }
        return try critical(&state)
    }
}

extension LockedState: @unchecked Sendable where State: Sendable { }
