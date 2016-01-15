# Lingonberry

Custom UISlider with nodes to show discrete values. Each node is clickable so user can select a value easily. The slider will also snap to the nearest node once sliding stop.

![screenshot](https://github.com/tflhyl/Lingonberry/blob/master/screenshot.png)

## Caveats

No test! This is used in my production app though, and no issue so far.

Since the nodes are just CALayer drawn on top of the slider, they may look out of place if Apple decide to change the UISlider appearance.

I don't use IB, so no support for IBDesignable or IBInspectable.

## Installation

Using Cocoapods:

`pod 'Lingonberry', :git => 'https://github.com/tflhyl/Lingonberry.git'`

## License

Released under the [MIT License](https://github.com/tflhyl/Lingonberry/blob/master/LICENSE.md)
