# FloationgActionSheetController
![Platform](http://img.shields.io/badge/platform-iOS-blue.svg?style=flat)
[![Language](https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/ra1028/FloatingActionSheetController/blob/master/LICENSE)

FloatingActionSheetController is a cool design ActionSheetController library written in Swift2.  

## Overview
<img src="http://i.imgur.com/sFyY1nQ.gif" width="320">
<img src="http://i.imgur.com/0InaZwn.gif" width="320">
<img src="http://i.imgur.com/bzKxfyx.png" width="240">

## Requirements  
- Xcode 7+
- iOS 8.0+  
- Swift2  

## Installation

### CocoaPods
```ruby
# Podfile
use_frameworks!
pod "FloatingActionSheetController"
```

## Usage

__Import FloationgActionSheetController at first.__
```swift
import FloatingActionSheetController
```

### example
```swift
let action1 = FloatingAction(title: "title") { action in
    // Do something.
}
let action2 = FloatingAction(title: "title") { action in
    // Do something.
}
let action3 = FloatingAction(title: "title", handleImmediately: true) { action in
    // Do something.
    // If set to 'true' the handleImmediately, handler will be execute soon when Action was select.
}
let group1 = FloatingActionGroup(action: action1)
let group2 = FloatingActionGroup(action: action2, action3)
FloatingActionSheetController(actionGroup: group1, group2)
    .present(self)
```
We have prepared a rich initializer to each Class. Please refer to the demo app and source code.

### animations
Custom animation styles.
Please check the overview or demo app for animation details
```swift
public enum AnimationStyle {
    case SlideUp
    case SlideDown
    case SlideLeft
    case SlideRight
    case Pop
}
```
How to use
```swift
FloatingActionSheetController(actionGroup: group, animationStyle: .SlideLeft)
```
```swift
let actionSheet = FloatingActionSheetController(actionGroup: group)
actionSheet.animationStyle = .SlideLeft
```

### appearance customization
```swift
let actionSheet = FloatingActionSheetController(actionGroup: group1)
// Color of action sheet
actionSheet.itemTintColor = .whiteColor()
// Color of title texts
actionSheet.textColor = .blackColor()
// Font of title texts
actionSheet.font = .boldSystemFontOfSize(15)
// background dimming color
actionSheet.dimmingColor = UIColor(white: 1, alpha: 0.7)
```
If you wants to customize FloatingAction individually.
```swift
var action = FloatingAction(title: "title") { action in
    // Do something.
}
action.customTintColor = .whiteColor()
action.customTextColor = .blackColor()
action.customFont = .boldSystemFontOfSize(15)
```

## License
FloatingActionSheetController is available under the MIT license. See the LICENSE file for more info.
