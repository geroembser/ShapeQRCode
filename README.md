#  ShapeQRCode

## Installation

Preferred installation is using [CocoaPods](https://cocoapods.org).

To Integrate the `ShapeQRCode` into your project using CocoaPods, specify it in your  `Podfile`:
```
pod 'ShapeQRCode'
```
After that, continue using the following command:
```
$ pod install
```

## Usage
Basically there're a ton of different customizations ShapeQRCode supports. I will explain the different possibilities here in a more detailled documentation soon. But for now, it may be very interesting to look at the example project and its code. The [example project](Example) demonstrates most of the different capabilities of ShapeQRCode.

But for completeness, here's a short comprehension of how to generate a QR code in Swift.
```
import ShapeQRCode

//use an emoji as the image in the middle
let 🦒 = "🦒".image()!

//create the image that should be contained in the qr code
let img = try? ShapeQRCode.Image(withUIImage: 🦒,
                                 width: 0.7,
                                 height: 0.7,
                                 transparencyDetectionEnabled: true)

//the actual struct that encapsulates the QR code data
let qr = ShapeQRCode(withText: "https://en.wikipedia.org/wiki/Giraffe",
                     andImage: img,
                     shape: .circle,
                     moduleSpacingPercent: 0.002,
                     color: .black,
                     errorCorrectionLevel: .high)

//Render the qr code represented by the qr as an UIImage with 500px width/height
let renderedQRImage = qr.image(withLength: 500)                  

```
The final result looks like this: 
![QR code with giraffe and rounded dots as modules](.github/QR%20Code%20examples/giraffeQR.png)

_You can find this code in the [playground](Examples.playground) in this repo. Clone/Download the repo and open the [workspace](ShapeQRCode.xcworkspace). Then build using "ShapeQRCode" scheme (important!) and run the playground._

## Example
For an example, where you can play around with the QR Code as well, see the [sample project](Example) included in this repo.
The code used there may also help you to integrate the appropriate solution of a ShapeQRCode into your project.


## Contributing
Do you like that repo? Are there any issues? _(obviously there's a lot...)_ Submit a pull request, open an issue...
And: I'm always happy to hear your feedback! If you have any questions or suggestions, I'm glad to help you!

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments
This library uses the great 🎉 QR Code generator library from [Nayuki](https://github.com/nayuki). Check it out! ➡️ [https://github.com/nayuki/QR-Code-generator](https://github.com/nayuki/QR-Code-generator)
