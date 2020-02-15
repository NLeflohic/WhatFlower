//
//  ViewController.swift
//  WhatFlower
//
//  Created by nicolas le flohic on 14/02/2020.
//  Copyright © 2020 nicolas le flohic. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    var flowerManager = FlowerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        flowerManager.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageFromCamera = info[.originalImage] as? UIImage {
            //imageView.image = imageFromCamera
            if let imageToDetect = CIImage (image: imageFromCamera) {
                detect(image: imageToDetect)
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func detect (image: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Error while converting the model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Error while getting results")
            }
            
            if let result = results.first {
                let flower = result.identifier
                DispatchQueue.main.async {
                  self.flowerManager.fetchData(flowerToFind: flower)
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }catch {
            print (error.localizedDescription)
        }
    }
    
}

extension ViewController: FlowerManagerDelegate {
    func didSearchFinishing(data: FlowerQuery) {
        self.navigationItem.title = data.title.capitalized
        self.descriptionLabel.text = data.description
        if let url = URL(string: data.urlImage) {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    self.imageView.image = image
                }
            }
        } else {
            self.imageView.image = UIImage(named: "no-image-icon")
        }
    }
}

