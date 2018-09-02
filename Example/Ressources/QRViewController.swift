//
//  QRViewController.swift
//  ShapeQRCode Example
//
//  Created by Gero Embser on 01.09.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import UIKit
import ShapeQRCode

class QRViewController: UIViewController {
    //MARK: - outlets
    @IBOutlet var qrImageView: UIImageView!
    @IBOutlet var textTextfield: UITextField!
    @IBOutlet var errorCorrectionLevelSegmentedControl: UISegmentedControl!
    @IBOutlet var moduleSpacingSlider: UISlider!
    @IBOutlet var moduleSpacingLabel: UILabel!
    @IBOutlet var shapeSegmentedControl: UISegmentedControl!
    
    @IBOutlet var containedImageImageView: UIImageView!
    @IBOutlet var selectContainedImageButton: UIButton!
    @IBOutlet var containedImageWidthSlider: UISlider!
    @IBOutlet var containedImageWidthLabel: UILabel!
    @IBOutlet var containedImageHeightSlider: UISlider!
    @IBOutlet var containedImageHeightLabel: UILabel!
    @IBOutlet var squareContainedImageSwitch: UISwitch!
    
    //MARK: - actions
    @IBAction func valueChanged(_ sender: Any) {
        updateQRAndQRImage()
    }
    
    //MARK: - variables
    private var qr: ShapeQRCode!
}

//MARK: - view lifecycle
extension QRViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        updateQRAndQRImage()
    }
    private func setupView() {
        updateSwitchUI()
        updateModuleSpacingUI()
    }
}


//MARK: - qr update
extension QRViewController {
    private func updateQR() {
        let text = self.textTextfield.text ?? ""
        
        let image: ShapeQRCode.Image?
        if let uiimage = self.containedImageImageView.image {
            image = try? ShapeQRCode.Image(withUIImage: uiimage,
                                        width: CGFloat(containedImageWidthSlider.value),
                                        height: CGFloat(containedImageHeightSlider.value))
        }
        else {
            image = nil
        }
        
        let shape = ShapeQRCode.Shape.allCases[shapeSegmentedControl.selectedSegmentIndex]
        let moduleSpacing = moduleSpacingSlider.value
        
        let color: UIColor = .black
        
        let errorCorrectionLevel = ShapeQRCode.ErrorCorrectionLevel.allCases[errorCorrectionLevelSegmentedControl.selectedSegmentIndex]
        
        self.qr = ShapeQRCode(withText: text,
                              andImage: image,
                              shape: shape,
                              moduleSpacingPercent: CGFloat(moduleSpacing),
                              color: color,
                              errorCorrectionLevel: errorCorrectionLevel)
        
        //need to re-compute the maximum possible module spacing in percent
        computeMaximumPossibleModuleSpacingInPercent()
    }
    
    private func updateQRImage() {
        do {
            qrImageView.image = try self.qr.image(withLength: qrImageView.frame.size.height,
                                                  withIntegrityCheck: false,
                                                  errorCorrectionOptimization: false)
        }
        catch {
            //show an error
            let alert = UIAlertController(title: "Error",
                                          message: "The QR code with the specified properties is unreadable for devices! Consider other properties!",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))

            //present...
            present(alert, animated: true, completion: nil)
            
            //TODO: maybe reset?!
        }
    }
    private func updateQRAndQRImage() {
        updateQR()
        updateQRImage()
    }
}


//MARK: - contained image settings
extension QRViewController {
    @IBAction func squaredSwitchValueChanged(_ sender: UISwitch) {
        updateSwitchUI()
        
        updateQRAndQRImage()
    }
    private var squareContainedImage: Bool {
        return squareContainedImageSwitch.isOn
    }
    private func updateSwitchUI() {
        if squareContainedImage {
            containedImageHeightSlider.isEnabled = false
            containedImageHeightLabel.textColor = .gray
            containedImageHeightSlider.value = containedImageWidthSlider.value
        }
        else {
            containedImageHeightSlider.isEnabled = true
            containedImageHeightLabel.textColor = .black
        }
    }
    
    @IBAction func containedImageSizeSliderValueChanged(_ sender: UISlider) {
        if squareContainedImage {
            containedImageHeightSlider.value = containedImageWidthSlider.value
        }
        
        containedImageWidthLabel.text = String(format: "width: %.1f %% (of QR width)", containedImageWidthSlider.value*100)
        containedImageHeightLabel.text = String(format: "height: %.1f %% (of QR height)", containedImageHeightSlider.value*100)
    }
}
extension QRViewController {
    @IBAction func selectContainedImageButtonTapped(_ sender: UIButton) {
        showContainedImagePicker()
    }
    
    private func showContainedImagePicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
}
extension QRViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        self.containedImageImageView.image = pickedImage
        
        //update QR code
        updateQRAndQRImage()
        
        //dismiss
        picker.dismiss(animated: true, completion: nil)
    }
}


//MARK: - module spacing settings
extension QRViewController {
    @IBAction func moduleSpacingSliderValueChanged(_ sender: UISlider) {
        updateModuleSpacingUI()
    }
    
    private func updateModuleSpacingUI() {
        //update the module spacing label
        let currentSpacingInPercent = moduleSpacingSlider.value*100
        
        moduleSpacingLabel.text = String(format: "%.3f%%", currentSpacingInPercent)
    }
    
    private func computeMaximumPossibleModuleSpacingInPercent() {
        self.moduleSpacingSlider.maximumValue = Float(self.qr.maximumModuleSpacingInPercent-0.00001)
        
        updateModuleSpacingUI() //so that label gets refreshed appropriately
    }
}


//MARK: - qr text textfield
extension QRViewController {
    @IBAction func returnButtonTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
}
