//
//  ViewController.swift
//  WhatzDCar
//
//  Created by Manas Ashwin on 24/05/19.
//  Copyright © 2019 Manas Producers. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    
    //MARK: Variables
    var imagePicker : UIImagePickerController!
    var currentImage = CIImage()

    // MARK: -  Outlets
    
    @IBOutlet weak var carView: UIImageView!
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    
    // MARK: - Actions
    @IBAction func takePhoto(_ sender: Any)
    {
        imagePicker.sourceType = .camera
        
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) else{
            carLabel.text = "No Camera Found"
            return
        }
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func getPhoto(_ sender: Any)
    {
        imagePicker.sourceType = .photoLibrary
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) else{
            fatalError("you Dont Have library")
        }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK:- Functions
    
    func predict(){
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: self.currentImage, orientation: .up)
            do {
                try handler.perform([self.createRequest()])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
        
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = ["public.image"]
        
    }


}

extension ViewController : UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            guard let theImage = CIImage(image: image) else{
                fatalError()
            }
            currentImage = theImage
            predict()
            picker.dismiss(animated: true, completion: nil)
        }
    }
}






extension ViewController{
    
    
    // MARK: - Handling
    func createRequest() -> VNCoreMLRequest
    {
        let model = try! VNCoreMLModel(for: CarRecognition().model)
        
        let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
            self?.processClassifications(for: request, error: error)
        })
        request.imageCropAndScaleOption = .centerCrop
        return request
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.carLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            self.carLabel.text = "This Car is A(n) \(classifications.first!.identifier)"
            self.percentLabel.text = "Im \(String(describing: classifications.first?.confidence))"
            self.carView.image = UIImage(ciImage: self.currentImage)
        }
    }
//    DispatchQueue.global(qos: .userInitiated).async {
//    let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
//    do {
//    try handler.perform([self.classificationRequest])
//    } catch {
//    /*
//     This handler catches general image processing errors. The `classificationRequest`'s
//     completion handler `processClassifications(_:error:)` catches errors specific
//     to processing that request.
//     */
//    print("Failed to perform classification.\n\(error.localizedDescription)")
//    }
//    }
    
}
