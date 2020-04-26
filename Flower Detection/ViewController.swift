//
//  ViewController.swift
//  Flower Detection
//
//  Created by Pranjal Bhardwaj on 26/04/20.
//  Copyright © 2020 Pranjal Bhardwaj. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = true
        
        imagePicker.sourceType = .camera
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            guard let ciimage = CIImage(image: userPickedImage) else {fatalError("cannot convert to CIImage")}
            
            detect(image: ciimage)
            
            imageView.image = userPickedImage
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {fatalError("Cannot import model")}
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            let classification = request.results?.first as? VNClassificationObservation
            
            self.navigationItem.title = classification?.identifier.capitalized
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
        
            try handler.perform([request])
            
        } catch {
            
            print(error)
        }
        
        
    }
    
}

