//
//  ViewController.swift
//  Image Classification
//
//  Created by Jeremy on 7/26/20.
//  Copyright © 2020 Jeremy. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var confidenceLabel: UILabel!
    
    let resnetModel = Resnet50()
    var imagePicker = UIImagePickerController()

    @IBAction func photosTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = selectedImage
            processImage(image: selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func processImage(image: UIImage) {
        if let model = try? VNCoreMLModel(for: self.resnetModel.model) {
            let request = VNCoreMLRequest(model: model) { (request, error) in
                if let results = request.results as? [VNClassificationObservation] {
                    for classification in results {
                        print("ID: \(classification.identifier) Confidence: \(classification.confidence)")
                    }
                    self.descriptionLabel.text = results.first?.identifier
                    if let confidence = results.first?.confidence{
                        self.confidenceLabel.text = "\(confidence * 100.0)%"
                    }
                }
            }
            
            if let imageData = image.pngData() {
                let handler = VNImageRequestHandler.init(data: imageData, options: [:])
                try? handler.perform([request])
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        if let image = imageView.image {
            processImage(image: image)
        }
    }
}

