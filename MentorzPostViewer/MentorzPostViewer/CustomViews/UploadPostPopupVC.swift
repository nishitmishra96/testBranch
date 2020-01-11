//
//  UploadPostVC.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 27/12/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import UIKit

class UploadPostPopupVC: UIViewController {
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var descriptionImage: UIImageView!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    var delegate : UploadPostDelegate?
    @IBOutlet weak var constraintWithImageVisible: NSLayoutConstraint!
    @IBOutlet weak var popUpHeight: NSLayoutConstraint!
    @IBOutlet weak var popUpWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintWithImageInvisible: NSLayoutConstraint!
    var uploadAction : UIAlertAction?

    @IBAction func GalleryButtonPressed(_ sender: Any) {
        delegate?.openGallery(isVideo: false)
    }
    @IBAction func MakeVideo(_ sender: Any) {
        delegate?.openGallery(isVideo: true)
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
