//
//  SecondViewController.swift
//  Books I Read App
//
//  Created by Mahmut Şenbek on 26.09.2022.
//

import UIKit
import CoreData

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bookNameLabel: UITextField!
    @IBOutlet weak var writerNameLabel: UITextField!
    @IBOutlet weak var pageNumberLabel: UITextField!
    @IBOutlet weak var saveButtonHidden: UIButton!
    
    var choosenName = ""
    var choosenNameId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if choosenName != "" {
            
            saveButtonHidden.isHidden = true
            
         
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Books")
            let idString = choosenNameId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)

            fetchRequest.returnsObjectsAsFaults = false
           
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            bookNameLabel.text = name
                        }
                        if let writer = result.value(forKey: "writer") as? String {
                            writerNameLabel.text = writer
                        }
                        if let page = result.value(forKey: "page") as? Int {
                            pageNumberLabel.text = String(page)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch {
                print("error")
            }
        } else {
            
            saveButtonHidden.isHidden = false
            saveButtonHidden.isEnabled = false
        }
         
        //Recognizers
        //Keyboard Recog.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeybord))
        view.addGestureRecognizer(gestureRecognizer)
        //image Recog.
        imageView.isUserInteractionEnabled = true
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(imageTapGesture)

    }
    
    @objc func imageTapped() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary // we can choose also camera etc.
        picker.allowsEditing = true // edit func.
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage  // we cant do ! cause we dont know users what will use.
        saveButtonHidden.isEnabled = true
        self.dismiss(animated: true, completion: nil) // dismiss
    }
    
    @objc func hideKeybord() {
        
        view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newBook = NSEntityDescription.insertNewObject(forEntityName: "Books", into: context)
        
        //Attributes
        
        newBook.setValue(bookNameLabel.text!, forKey: "name")
        newBook.setValue(writerNameLabel.text!, forKey: "writer")
        
        if let page = Int(pageNumberLabel.text!) {
            newBook.setValue(page, forKey: "page")
        }
        newBook.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        newBook.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("Saved")
        } catch {
            print("Error")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
   

}
