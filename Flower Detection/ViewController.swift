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
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
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
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {fatalError("Cannot import model")}
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let classification = request.results?.first as? VNClassificationObservation else {fatalError("Could not classify image")}
        
            self.navigationItem.title = classification.identifier.capitalized
            
            self.requestInfo(flowerName: classification.identifier)
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
        
            try handler.perform([request])
            
        } catch {
            
            print(error)
        }
    }
    
    func requestInfo(flowerName: String) {
        
        let parameters : [String:String] = ["format" : "json","action" : "query","prop" : "extracts|pageimages","exintro" : "","explaintext" : "","titles" : flowerName,"indexpageids" : "","redirects" : "1","pithumbsize": "500"]

        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in

            let dataResponse = response.result

            let flowerJSON: JSON = JSON(dataResponse)

            let pageid = flowerJSON["query"]["pageids"][0].stringValue
            
            let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
            
            let flowerImageURL = flowerJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
            
            self.imageView.sd_setImage(with: URL(string: flowerImageURL))
            
            self.label.text = flowerDescription
        }
    }
}

