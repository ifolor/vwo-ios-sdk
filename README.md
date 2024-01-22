# VWO

VWO SDK, with changes from ifolor.

## Ifolor Changes

There were a couple of problems with the original SDK with the main one
providing no Mac support. So fixed some of the following issues:

    - Only iOS support, not for macOS.
    - Many Objective C class names are not prefixed (Group, Pair, …).
    - Naïve extensions on common classes, like NSDictionary.toString.
    - Wrong objc error handling.
    - Unit Tests do not even compile. Many Fail.
    - Package support is very recent. No unit test support.
    - Package name clashes with contained type name.
    - Issues wait unanswered for ages in the queue.
    - Commit history looks flaky.
    - Github releases are not maintained properly.

## Installation

[![Version](https://img.shields.io/cocoapods/v/VWO.svg?style=flat)](http://cocoapods.org/pods/VWO)
[![License](https://img.shields.io/cocoapods/l/VWO.svg?style=flat)](http://cocoapods.org/pods/VWO)
[![Platform](https://img.shields.io/cocoapods/p/VWO.svg?style=flat)](http://cocoapods.org/pods/VWO)

VWO is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod 'VWO'
```

## iOS Version Support

This library supports iOS version 9.0 and above.

## Setting up VWO Account

Sign Up for VWO account at https://vwo.com

## Getting Started Documentation
* [Installation Instructions](http://developers.vwo.com/reference#ios-sdk-installation)
* [Creating and Running Campaign](https://vwo.com/knowledge/folder-creating-mobile-app-campaigns/)

## Author

Wingify, info@wingify.com

## License

By using this SDK, you agree to abide by the [VWO Terms & Conditions](https://vwo.com/terms-conditions).
