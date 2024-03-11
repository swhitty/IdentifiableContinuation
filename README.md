[![Build](https://github.com/swhitty/IdentifiableContinuation/actions/workflows/build.yml/badge.svg)](https://github.com/swhitty/IdentifiableContinuation/actions/workflows/build.yml)
[![Codecov](https://codecov.io/gh/swhitty/IdentifiableContinuation/graphs/badge.svg)](https://codecov.io/gh/swhitty/IdentifiableContinuation)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20|%20Mac%20|%20tvOS%20|%20Linux%20|%20Windows-lightgray.svg)](https://github.com/swhitty/IdentifiableContinuation/blob/main/Package.swift)
[![Swift 5.10](https://img.shields.io/badge/swift-5.7%20–%205.10-red.svg?style=flat)](https://developer.apple.com/swift)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Twitter](https://img.shields.io/badge/twitter-@simonwhitty-blue.svg)](http://twitter.com/simonwhitty)

# Introduction

**IdentifiableContinuation** is a lightweight wrapper around [`CheckedContinuation`](https://developer.apple.com/documentation/swift/checkedcontinuation) that conforms to [`Identifiable`](https://developer.apple.com/documentation/swift/identifiable) and includes an easy to use cancellation handler with the id.

# Installation

IdentifiableContinuation can be installed by using Swift Package Manager.

 **Note:** IdentifiableContinuation requires Swift 5.7 on Xcode 14+. It runs on iOS 13+, tvOS 13+, macOS 10.15+, Linux and Windows.
To install using Swift Package Manager, add this to the `dependencies:` section in your Package.swift file:

```swift
.package(url: "https://github.com/swhitty/IdentifiableContinuation.git", .upToNextMajor(from: "0.1.0"))
```

# Usage

Usage is similar to existing continuations, but requires an `Actor` to ensure the closure is executed within the actors isolation:

```swift
let val: String = await withIdentifiableContinuation(isolation: self) { 
    $0.resume(returning: "bar")
}
```

This allows actors to synchronously start continuations and mutate their isolated state _before_ suspension occurs. The `onCancel:` handler is `@Sendable` and can be called at any time _after_ the body has completed. Manually check `Task.isCancelled` before creating the continuation to prevent performing unrequired work.

```swift
let val: String = await withIdentifiableContinuation(isolation: self) {
  // exectured within actor isolation so can immediatley mutate actor state
  continuations[$0.id] = $0
} onCancel: { id in
  // @Sendable closure executed outside of actor isolation requires `await` to mutate actor state
  Task { await self.cancelContinuation(with: id) }
}
```

# Credits

IdentifiableContinuation is primarily the work of [Simon Whitty](https://github.com/swhitty).

([Full list of contributors](https://github.com/swhitty/IdentifiableContinuation/graphs/contributors))
