[![Build](https://github.com/swhitty/IdentifiableContinuation/actions/workflows/build.yml/badge.svg)](https://github.com/swhitty/IdentifiableContinuation/actions/workflows/build.yml)
[![Codecov](https://codecov.io/gh/swhitty/IdentifiableContinuation/graphs/badge.svg)](https://codecov.io/gh/swhitty/IdentifiableContinuation)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20|%20Mac%20|%20tvOS%20|%20Linux%20|%20Windows-lightgray.svg)](https://github.com/swhitty/IdentifiableContinuation/blob/main/Package.swift)
[![Swift 5.8](https://img.shields.io/badge/swift-5.7%20–%205.8-red.svg?style=flat)](https://developer.apple.com/swift)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Twitter](https://img.shields.io/badge/twitter-@simonwhitty-blue.svg)](http://twitter.com/simonwhitty)

# Introduction

**IdentifiableContinuation** is a lightweight wrapper around [`CheckedContinuation`](https://developer.apple.com/documentation/swift/checkedcontinuation) and [`UnsafeContinuation`](https://developer.apple.com/documentation/swift/unsafecontinuation) that conforms to [`Identifiable`](https://developer.apple.com/documentation/swift/identifiable) and includes an easy to use cancellation handler with the id.

# Installation

IdentifiableContinuation can be installed by using Swift Package Manager.

 **Note:** IdentifiableContinuation requires Swift 5.7 on Xcode 14+. It runs on iOS 13+, tvOS 13+, macOS 10.15+, Linux and Windows.
To install using Swift Package Manager, add this to the `dependencies:` section in your Package.swift file:

```swift
.package(url: "https://github.com/swhitty/IdentifiableContinuation.git", .upToNextMajor(from: "0.0.1"))
```

# Usage

Usage is similar to existing continuations:

```swift
let val: String = await withIdentifiableContinuation { 
    $0.resume(returning: "bar")
}
```

The continuation includes an `id` that can be attached to an asynchronous task enabling the `onCancel` handler to cancel it.  

```swift
let val: String? = await withIdentifiableContinuation { continuation in
  foo.startTask(for: continuation.id) { result
     continuation.resume(returning: result)
  }
} onCancel: { id in
  foo.cancelTask(for: id)
}
```

`async` closures can be used making it easy to store the continuations within an actor:

```swift
let val: String? = await withIdentifiableContinuation {
  await someActor.insertContinuation($0)
} onCancel: {
  await someActor.cancelContinuation(for: $0)
}
```

> Note: The `onCancel:` handler is guaranteed to be called after the continuation body even if the task is already cancelled. Manually check `Task.isCancelled` before creating the continuation to prevent performing unrequired work.

## Checked/UnsafeContinuation

`IdentifiableContinuation` internally stores either a checked or unsafe continuation.

[`CheckedContinuation`](https://developer.apple.com/documentation/swift/checkedcontinuation) is used by the default methods:

- `withIdentifiableContinuation`
- `withThrowingIdentifiableContinuation`


[`UnsafeContinuation`](https://developer.apple.com/documentation/swift/unsafecontinuation) is used by the unsafe methods:

- `withIdentifiableUnsafeContinuation`
- `withThrowingIdentifiableUnsafeContinuation`

# Credits

IdentifiableContinuation is primarily the work of [Simon Whitty](https://github.com/swhitty).

([Full list of contributors](https://github.com/swhitty/IdentifiableContinuation/graphs/contributors))
