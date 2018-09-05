import PlaygroundSupport
import UIKit
import ShapeQRCode //if module cannot be found, in Xcode: select the "ShapeQRCode" target and build, then run again

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


///////////Swift Playgrounds stuff...///////////

//show it in the live view
let imageView = UIImageView(image: renderedQRImage)
imageView.backgroundColor = .white
PlaygroundPage.current.liveView = imageView
PlaygroundPage.current.needsIndefiniteExecution = false

/*
//save png
let folder = playgroundSharedDataDirectory
try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
let destination = folder.appendingPathComponent("QRCode \(UUID().uuidString).png")
try renderedQRImage.pngData()?.write(to: destination)

print("File written to ✏️: \(destination)")
*/
