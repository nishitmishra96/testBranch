//
//  BoardPostUITableView.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 11/01/20.
//  Copyright © 2020 Nishit Mishra. All rights reserved.
//

import UIKit
import Alamofire
public class BoardPostUITableView: BaseTableView {
    var controller:PostController?
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc override func didPullToRefresh(){
        self.refreshControl?.beginRefreshing()
        self.controller?.getPost(forPage: 0)
    }
    public func filterLocalPost(string:String){
        self.controller?.filterPostString = string
        self.reloadData()
    }
    public func setupTableViewForProfile(user id:String){
        self.controller = PostController(foruserProfile: id, base: self)
    }
    public func setupTableViewForBoardPost(user id:String){
        self.controller = PostController(userid: id, base: self)
    }
    public func setupTableViewForBoardPostBasedOnInterestList(user id:String,interesetList:[Int]){
        self.controller = PostController(userid: id, base: self, interestList: interesetList)
    }
    func uploadPostPopup(info: [UIImagePickerController.InfoKey : Any],descriptionText:String,selectedImage:UIImage?,isVideo:Bool = false,videoFileUrl:NSURL? = nil){
        let imageURL = info[.imageURL]
        var imageName = ""
        var mimeType = ""
        var imageDataToBeUploaded = Data()
        if let asset = info[.phAsset]{
            imageName = ("\((Date().timeIntervalSince1970 * 1000))").replacingOccurrences(of: ".", with: "")
        }
        
        if let image = (imageURL as? URL){
            mimeType = image.pathExtension.lowercased()
        }
        
        if mimeType == "png" {
            imageDataToBeUploaded = (selectedImage?.pngData()!)!;
        } else {
            imageDataToBeUploaded = (selectedImage?.jpegData(compressionQuality: 1)!)!;
        }
        UploadPostManager.shared.request = upload(Data(), to: URL.init(string: "https://www.google.com")!)
        self.reloadSections(IndexSet(integersIn: 0...0), with: UITableView.RowAnimation.top)
        if !isVideo{
            UploadPostManager.shared.uploadImagePost(imageName: imageName, imageDataToBeUploaded: imageDataToBeUploaded, mimeType: mimeType, descriptionFieldText: /descriptionText) { (newPost, statusCode) in
                UploadPostManager.shared.request = nil
                if statusCode == HttpResponseCodes.success.rawValue{
                    if let newPostToShow = newPost{
                        self.controller?.InsertNewRow(withPost:newPostToShow)
                    }else{
                        MentorzPostViewer.shared.delegate?.handleErrorMessage(error: "Something Went Wrong")
                    }
                }
            }
        }else{
            UploadPostManager.shared.uploadVideoPost(imageName: imageName, videoFileURL: videoFileUrl, mimeType: mimeType, descriptionFieldText: descriptionText) { (newPost, statusCode) in
                UploadPostManager.shared.request = nil
                if statusCode == HttpResponseCodes.success.rawValue{
                    if let newPostToShow = newPost{
                        self.controller?.InsertNewRow(withPost:newPostToShow)
                    }else{
                        MentorzPostViewer.shared.delegate?.handleErrorMessage(error: "Something Went Wrong")
                    }
                }
            }
        }
    }
}

extension BoardPostUITableView:AddPost{
    public func addPostbuttonClicked() {
        let uploadPostVC = Storyboard.home.instanceOf(viewController: UploadPostPopupVC.self)!
        let uploadPopUp = UIAlertController(title: "Add Post", message: "", preferredStyle: .alert)
        let uploadAction = UIAlertAction(title: "Upload", style: .default) { (uploadAction) in
            if !uploadPostVC.isVideo{
                self.uploadPostPopup(info: uploadPostVC.info, descriptionText: /uploadPostVC.descriptionField.text, selectedImage: uploadPostVC.descriptionImage.image)
            }else{
                self.uploadPostPopup(info: uploadPostVC.info, descriptionText: /uploadPostVC.descriptionField.text, selectedImage: uploadPostVC.descriptionImage.image, isVideo: uploadPostVC.isVideo, videoFileUrl: (uploadPostVC.info[UIImagePickerController.InfoKey.mediaURL] as! NSURL))
            }
        }
        uploadAction.isEnabled = false
        uploadPostVC.uploadAction = uploadAction
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive){ _ in
            
        }
        uploadPopUp.addAction(uploadAction)
        uploadPopUp.addAction(cancelAction)
        uploadPopUp.preferredContentSize = UIApplication.shared.keyWindow?.frame.offsetBy(dx: 50, dy: 50).size ?? CGSize.zero
        uploadPopUp.setValue(uploadPostVC, forKey: "contentViewController")
        let height:NSLayoutConstraint = NSLayoutConstraint(item: uploadPopUp.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 300)
        uploadPopUp.view.addConstraint(height)
        uploadPopUp.modalPresentationStyle = .overFullScreen
        UIApplication.shared.keyWindow?.rootViewController?.present(uploadPopUp, animated: true, completion: nil)
    }
}
