//
//  UploadPostVC.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 27/12/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

class UploadPostPopupVC: UIViewController {
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var descriptionImage: UIImageView!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var constraintWithImageVisible: NSLayoutConstraint!
    @IBOutlet weak var popUpHeight: NSLayoutConstraint!
    @IBOutlet weak var popUpWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintWithImageInvisible: NSLayoutConstraint!
    var uploadAction : UIAlertAction?
    var info : [UIImagePickerController.InfoKey : Any] = [:]
    var isVideo = false
    
    @IBAction func GalleryButtonPressed(_ sender: Any) {
        GalleryImagePicker().openAlbums(currentlyPresentedVC:self)
    }
    @IBAction func MakeVideo(_ sender: Any) {
        GalleryImagePicker().openAlbums(currentlyPresentedVC:self,isVideo: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionImage.isHidden = true
        self.errorLabel.isHidden = true
        self.contentView.alpha = 0.2
        self.descriptionField.delegate = self
        self.descriptionField.addTarget(self, action: #selector(validations), for: .allEvents)
    }
    
    @objc func validations(){
        self.textCount.text = "Count :  \(/descriptionField.text?.count)" + "/140"
        if /descriptionField.text?.count > 0{
            self.errorLabel.isHidden = true
            uploadAction?.isEnabled = true
        }else{
            self.errorLabel.isHidden = false
            self.errorLabel.text = "Please Enter Description"
            uploadAction?.isEnabled = false
        }
    }
    
    func imageSelected() {
        let imageViewer = Storyboard.home.instanceOf(viewController: ImageViewerVC.self)!
        imageViewer.delegate = self
        imageViewer.modalPresentationStyle = .fullScreen
        self.isVideo = false
        self.present(imageViewer, animated: true){
            if let editedImage = self.info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
                imageViewer.imageView.image = editedImage
            }else{
                imageViewer.imageView.image = self.info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            }
        }
    }
    
    func videoSelected() {
        let imageViewer = Storyboard.home.instanceOf(viewController: ImageViewerVC.self)!
        imageViewer.delegate = self
        imageViewer.modalPresentationStyle = .fullScreen
        self.isVideo = true
        self.present(imageViewer, animated: true){
            imageViewer.imageView.image = UploadPostManager.shared.getVideoThumbnail(filePathLocal: (self.info[UIImagePickerController.InfoKey.mediaURL] as! URL).absoluteString)
            }
    }
}


extension UploadPostPopupVC:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 140
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}

extension UploadPostPopupVC:ImagePickerDelegate{
    func donePressed() {
        self.descriptionImage.isHidden = false
        self.constraintWithImageInvisible.constant = /self.descriptionImage.frame.width + 8
        if isVideo{
            self.descriptionImage.image = UploadPostManager.shared.getVideoThumbnail(filePathLocal: (self.info[UIImagePickerController.InfoKey.mediaURL] as! URL).absoluteString)
        }else{
            if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
                self.descriptionImage.image = editedImage
            }else{
                self.descriptionImage.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            }
        }

    }
    
    func imagePickerDissmissed() {
        
    }
    
}

extension UploadPostPopupVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print("Hey this is info : ",info)
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        self.info = info
        
        switch mediaType {
        case kUTTypeImage: print("ImageSelected")
        self.imageSelected()
        case kUTTypeMovie: print("VideoSelected")
        self.videoSelected()
        default:
            break
        }
    }
}
