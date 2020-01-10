//
//  PreviewImage.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 18/12/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import UIKit

class PreviewImage: UIViewController {

    @IBOutlet weak var image: UIImageView!
    var imageToDisplay:UIImage?
    var info: [UIImagePickerController.InfoKey : Any]?
    var originalImage : UIImage?
    var delegate : UploadPostDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.image.image = imageToDisplay
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func doneButtonPressed(_ sender: Any) {
        delegate?.donePressed(info: info ?? [:])
        self.dismiss(animated: true, completion: nil)
    }
}
