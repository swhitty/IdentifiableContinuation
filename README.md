[![Build](https://github.com/swhitty/IdentifiableContinuation/actions/workflows/build.yml/badge.svg)](https://github.com/swhitty/IdentifiableContinuation/actions/workflows/build.yml)
[![Codecov](https://codecov.io/gh/swhitty/IdentifiableContinuation/graphs/badge.svg)](https://codecov.io/gh/swhitty/IdentifiableContinuation)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20|%20Mac%20|%20tvOS%20|%20Linux%20|%20Windows-lightgray.svg)](https://github.com/swhitty/IdentifiableContinuation/blob/main/Package.swift)
[![Swift 6.0](https://img.shields.io/badge/swift-5.10%20–%206.0-red.svg?style=flat)](https://developer.apple.com/swift)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Twitter](https://img.shields.io/badge/twitter-@simonwhitty-blue.svg)](http://twitter.com/simonwhitty)

# Introduction

**IdentifiableContinuation** is a lightweight wrapper around [`CheckedContinuation`](https://developer.apple.com/documentation/swift/checkedcontinuation) that conforms to [`Identifiable`](https://developer.apple.com/documentation/swift/identifiable) and includes an easy to use cancellation handler with the id.

# Installation

IdentifiableContinuation can be installed by using Swift Package Manager.

 **Note:** IdentifiableContinuation requires Swift 5.10 on Xcode 15.4+. It runs on iOS 13+, tvOS 13+, macOS 10.15+, Linux and Windows.
To install using Swift Package Manager, add this to the `dependencies:` section in your Package.swift file:

```swift
.package(url: "https://github.com/swhitty/IdentifiableContinuation.git", .upToNextMajor(from: "0.4.0"))
```

# Usage

With Swift 6, usage is similar to existing continuations.

```swift
let val: String = await withIdentifiableContinuation { 
  continuations[$0.id] = $0
}
```

The body closure is executed syncronously within the current isolation allowing actors to mutate their isolated state.

An optional cancellation handler is called when the task is cancelled.  The handler is `@Sendable` and can be called at any time _after_ the body has completed.

```swift
let val: String = await withIdentifiableContinuation { 
  continuations[$0.id] = $0
} onCancel: { id in
  // @Sendable closure executed outside of actor isolation requires `await` to mutate actor state
  Task { await self.cancelContinuation(with: id) }
}
```

> The above is also compatible in Swift 5 language mode using a Swift 6 compiler e.g. Xcode 16

## Swift 5

 While behaviour is identical, Swift 5 compilers (Xcode 15) are unable to inherit actor isolation through the new `#isolation` keyword ([SE-420](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0420-inheritance-of-actor-isolation.md)) so an `isolated` reference to the current actor must always be passed.

```swift
let val: String = await withIdentifiableContinuation(isolation: self) { 
  continuations[$0.id] = $0
}
```

# Credits

IdentifiableContinuation is primarily the work of [Simon Whitty](https://github.com/swhitty).

([Full list of contributors](https://github.com/swhitty/IdentifiableContinuation/graphs/contributors))
