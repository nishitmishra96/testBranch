//
//  GalleryImagePicker.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 18/12/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import Photos
class GalleryImagePicker:NSObject{
    var delegate : UploadPostDelegate?
    func openAlbums(currentlyPresentedVC:UIViewController?,isVideo:Bool = false){
        let authorisationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorisationStatus{
            case .authorized:
                self.presentImagePicker(currentlyPresentedVC:currentlyPresentedVC,isVideo: isVideo)
            case .notDetermined,.denied,.restricted:
                self.checkAuthorisation(currentlyPresentedVC:currentlyPresentedVC)
            @unknown default:
                print("Unknown error")
            }
    }
    
    func checkAuthorisation(currentlyPresentedVC:UIViewController?,isVideo:Bool = false){
        PHPhotoLibrary.requestAuthorization { (authorisation) in
            if authorisation == .authorized{
                self.presentImagePicker(currentlyPresentedVC:currentlyPresentedVC,isVideo: isVideo)
            }else{
                print("Not authorised")
            }
        }
    }
    
    func presentImagePicker(currentlyPresentedVC:UIViewController?,isVideo:Bool = false){
        let imagePickerController = UIImagePickerController()
        if /isVideo{
            imagePickerController.sourceType = .camera
        }else{
            imagePickerController.sourceType = .photoLibrary

        }
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeMovie as String,kUTTypeImage as String]
        imagePickerController.delegate = self
        currentlyPresentedVC?.present(imagePickerController, animated: true, completion: nil)
        }
}

extension GalleryImagePicker : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        delegate?.imagePickerDissmissed()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print("Hey this is info : ",info)
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString

        switch mediaType {
        case kUTTypeImage:
            delegate?.imageSelected(info: info)
        case kUTTypeMovie:
            delegate?.videoSelected(info: info)
        default:
            break
        }
    }
}
