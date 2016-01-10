# ASAudioPlayer

[![Version](https://img.shields.io/cocoapods/v/ASAudioPlayer.svg?style=flat)](http://cocoapods.org/pods/ASAudioPlayer)
[![License](https://img.shields.io/cocoapods/l/ASAudioPlayer.svg?style=flat)](http://cocoapods.org/pods/ASAudioPlayer)
[![Platform](https://img.shields.io/cocoapods/p/ASAudioPlayer.svg?style=flat)](http://cocoapods.org/pods/ASAudioPlayer)

## Overview

ASAudioPlayer is a simple audio player which can play audio file from remote or local links provided a NSURL.

## Usage

```Swift
import ASAudioPlayer

let audioPlayer = ASAudioPlayer(frame: CGRectMake(0, 50, 300, 100))
audioPlayer.setUrl(url)
self.view.addSubview(audioPlayer)
```

## Requirements
* ARC
* iOS7 or above

## Installation

ASAudioPlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ASAudioPlayer"
```

## Example Project

An example project is included with this repo.  To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Ankit Shah, shahankit2313@gmail.com

## License

ASAudioPlayer is available under the MIT license. See the LICENSE file for more info.
