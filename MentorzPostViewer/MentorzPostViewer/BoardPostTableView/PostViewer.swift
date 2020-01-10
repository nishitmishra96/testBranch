//
//  Testing.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 12/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import UIKit
import SVProgressHUD
import PagingTableView
import ExpandableLabel
import Alamofire
import Photos
import MobileCoreServices
open class PostViewer:BaseTableView {
    var dataSourceTableView : TableViewDataSource?
    var imagePicker : GalleryImagePicker?
    var currentlyPresentedVC:UIViewController?
    var localPost : LocalPost?
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setUp()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc override func didPullToRefresh(){
        self.refreshControl?.beginRefreshing()
        dataSourceTableView?.getPostsWith(for: self, pageNumber: 0)
    }
    
    
    public func getPostsFor(userId: String){
        self.dataSourceTableView = TableViewDataSource(userId: userId)
        dataSourceTableView?.delegate = self
        pagingDelegate = dataSourceTableView
        self.dataSource = dataSourceTableView
        self.delegate = dataSourceTableView
    }
    open func reload() {
        (self.dataSourceTableView as? TableViewDataSource)?.uploadingNewPost = localPost?.isUploading ?? false
        self.reloadData()
    }
    
}

extension PostViewer:DataForBoard{
    func newCommentAppended(oldList: [CompleteComment], newList: [CompleteComment]) {
        self.beginUpdates()
        var indexes = [IndexPath]()
        for count in 0..<(newList.count - oldList.count){
            let indexpath = IndexPath(row: (oldList.count - 1) + count, section: 0)
            indexes.append(indexpath)
        }
        self.insertRows(at: indexes, with: .none)
        self.endUpdates()
    }
    
    func newPostsAppended(oldList: [CompletePost], newList: [CompletePost]) {
        self.beginUpdates()
        var indexes = [IndexPath]()
        for count in 0..<(newList.count - oldList.count){
            let indexpath = IndexPath(row: (oldList.count - 1) + count, section: 0)
            indexes.append(indexpath)
        }
        self.insertRows(at: indexes, with: .none)
        self.endUpdates()
    }
    
   @objc func reloadTableView() {
        self.reload()
    }

    func removeCell(){
        
    }
}

extension PostViewer: UserActivities{
    func reloadTableView(forPost: CompletePost?) {
        if let post = forPost?.post{
            let requiredCompletePost = self.dataSourceTableView?.getObjectOfCompletePostWith(post: post)
             if let completePost = requiredCompletePost{
                 let index = self.dataSourceTableView?.completePosts.firstIndex(of: completePost)
                 let indexPath = IndexPath(row: /index, section: 0)
                 self.beginUpdates()
                 self.reloadRows(at: [indexPath], with: .automatic)
                 self.endUpdates()
             }
        }
    }
    
    func userPressedReadMore(post:CompletePost?) {
        if let post = post?.post{
            let requiredCompletePost = self.dataSourceTableView?.getObjectOfCompletePostWith(post: post)
             if let completePost = requiredCompletePost{
                 let index = self.dataSourceTableView?.completePosts.firstIndex(of: completePost)
                 let indexPath = IndexPath(row: /index, section: 0)
                 self.beginUpdates()
                    self.cellForRow(at: indexPath)?.layoutIfNeeded()
                 self.endUpdates()
             }
        }
    }
    
    func userPressedReadLess(post:CompletePost?) {
        if let post = post?.post{
            let requiredCompletePost = self.dataSourceTableView?.getObjectOfCompletePostWith(post: post)
             if let completePost = requiredCompletePost{
                 let index = self.dataSourceTableView?.completePosts.firstIndex(of: completePost)
                 let indexPath = IndexPath(row: /index, section: 0)
                 self.beginUpdates()
                self.cellForRow(at: indexPath)?.layoutIfNeeded()
                 self.endUpdates()
             }
        }
    }
    
    func userDeletedComment(completeComment:CompleteComment) {
    }

    func userReportedAPostWith(post:Post, type: String) {
        PostsRestManager.shared.reportPost(userId: /self.dataSourceTableView?.userId, postId: "\(/post.postId)", type: type){ (statusCode) in
            if statusCode == HttpResponseCodes.NoContent.rawValue{
                let requiredCompletePost = self.dataSourceTableView?.getObjectOfCompletePostWith(post: post)
                if let completePost = requiredCompletePost{
                    let index = self.dataSourceTableView?.completePosts.firstIndex(of: completePost)
                    self.dataSourceTableView?.completePosts.remove(at: index!)
                    let indexPath = IndexPath(row: /index, section: 0)
                    self.beginUpdates()
                    self.deleteRows(at: [indexPath], with: .automatic)
                    self.endUpdates()
                }else{
                    SVProgressHUD.showError(withStatus: "Something Went Wrong \(statusCode!)")
                }
            }else{
                SVProgressHUD.showError(withStatus: "Something Went Wrong \(statusCode!)")
            }

        }
    }
    
    func userUnLiked(postId: Int, handler: @escaping ((Int) -> ())) {
        self.dataSourceTableView?.userUnlikedLiked(postId: postId){ (statusCode) in
            if statusCode == 204{
                handler(statusCode)
            }
            else{
                handler(-1000)
            }
        }
    }
    
    func userLiked(postId: Int, handler: @escaping ((Int) -> ())) {
        self.dataSourceTableView?.userLikedOn(postId: postId){ (statusCode) in
            if statusCode == 204{
                handler(statusCode)
            }
            else{
                handler(-1000)
            }
        }
    }
    
    func userCommented(postId: Int) {
//        self.userCommented(postId: postId)
    }
    
    @objc open func getImageFromGallery(){
        let uploadPostVC = Storyboard.home.instanceOf(viewController: UploadPostVC.self)!
        UIApplication.shared.keyWindow?.rootViewController?.present(uploadPostVC, animated: true, completion: nil)
    }
}


extension PostViewer:AddPost{
    public func addPostbuttonClicked() {
        self.localPost = TextTypeLocalPost()
        let uploadPostVC = Storyboard.home.instanceOf(viewController: UploadPostVC.self)!
        uploadPostVC.delegate = self
        self.currentlyPresentedVC = uploadPostVC
        let addToPlaylistAlert = UIAlertController(title: "Add Post", message: "", preferredStyle: .alert)
        let uploadAction = UIAlertAction(title: "Upload", style: .default) { (uploadAction) in
                self.currentlyPresentedVC?.dismiss(animated: true, completion: nil)
                self.uploadContent()
        }
        uploadAction.isEnabled = false
        uploadPostVC.uploadAction = uploadAction
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive){ _ in
            self.currentlyPresentedVC?.dismiss(animated: true, completion: nil)
        }
        addToPlaylistAlert.addAction(uploadAction)
        addToPlaylistAlert.addAction(cancelAction)
        addToPlaylistAlert.preferredContentSize = UIApplication.shared.keyWindow?.frame.offsetBy(dx: 50, dy: 50).size ?? CGSize.zero
        addToPlaylistAlert.setValue(uploadPostVC, forKey: "contentViewController")
        let height:NSLayoutConstraint = NSLayoutConstraint(item: addToPlaylistAlert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 300)
        addToPlaylistAlert.view.addConstraint(height)
        UIApplication.shared.keyWindow?.rootViewController?.present(addToPlaylistAlert, animated: true, completion: nil)
    }
}

extension PostViewer:UploadPostDelegate{
    func imagePickerDissmissed() {
        self.localPost = nil
        (self.currentlyPresentedVC as? UploadPostVC)?.constraintWithImageInvisible.constant = 4.0
    }
    
    func uploadContent() {
        self.localPost?.isUploading = true
        (self.dataSourceTableView as? TableViewDataSource)?.uploadingNewPost = true
        self.beginUpdates()
        self.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        self.endUpdates()
        localPost?.delegate = self.cellForRow(at: IndexPath(row: 0, section: 0)) as! UploadProgressCell
        localPost?.descriptionFieldText = "\(/(self.currentlyPresentedVC as! UploadPostVC).descriptionField.text)"
        
        UploadTaskManager.shared.uploadContent(localPost: self.localPost){(newPost,statusCode) in
            self.localPost?.isUploading = false
            (self.dataSourceTableView as? TableViewDataSource)?.uploadingNewPost = false
            if statusCode == HttpResponseCodes.success.rawValue{
                if let newPostToShow = newPost{
                    self.beginUpdates()
                    self.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    self.endUpdates()
                    self.beginUpdates()
                    (self.dataSourceTableView as? TableViewDataSource)?.completePosts.insert(CompletePost(post: newPostToShow), at: 0)
                    self.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                    self.endUpdates()
                    newPostToShow.content = newPostToShow.contents?.first
                    (self.cellForRow(at: IndexPath(row: 0, section: 0)) as? PostTableViewCell)?.setData(cellPost: CompletePost(post: newPostToShow))
                }
                
            }else{
                self.uploadCancelled()
                SVProgressHUD.showError(withStatus: "Something Went Wrong")
            }
        }
    }
    
    func donePressed(info: [UIImagePickerController.InfoKey : Any]) {
        (self.currentlyPresentedVC as? UploadPostVC)?.constraintWithImageInvisible.constant = ((self.currentlyPresentedVC as? UploadPostVC)?.descriptionImage.frame.width ?? 0) + 8
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            localPost?.selectedImage = editedImage

        }else{
            localPost?.selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        (self.currentlyPresentedVC as? UploadPostVC)?.descriptionImage.isHidden = false
        (self.currentlyPresentedVC as? UploadPostVC)?.descriptionImage.image = localPost?.selectedImage
          let imageURL = info[.imageURL]
          if let asset = info[.phAsset]{
              let assetResources = PHAssetResource.assetResources(for: (asset as! PHAsset))
              localPost?.imageName = ("\((Date().timeIntervalSince1970 * 1000))").replacingOccurrences(of: ".", with: "")
              print(assetResources.first!.originalFilename)
          }
          
          if let image = (imageURL as? URL){
              localPost?.mimeType = image.pathExtension.lowercased()
          }
          
          if /localPost?.mimeType == "png" {
            localPost?.imageDataToBeUploaded = (localPost?.selectedImage!)?.pngData()!;
          } else {
            localPost?.imageDataToBeUploaded = (localPost?.selectedImage!)?.jpegData(compressionQuality: 1)!;
          }
    }
    
    func openGallery(isVideo:Bool) {
        self.imagePicker = GalleryImagePicker()
        imagePicker?.delegate = self
        if !isVideo{
            imagePicker?.presentImagePicker(currentlyPresentedVC:self.currentlyPresentedVC)
        }else{
            imagePicker?.presentImagePicker(currentlyPresentedVC:self.currentlyPresentedVC,isVideo: isVideo)
        }
    }
    
    func imageSelected(info: [UIImagePickerController.InfoKey:Any]) {
        self.localPost = ImageTypeLocalPost()
        localPost?.isImage = true
        let imagePreview = Storyboard.home.instanceOf(viewController: PreviewImage.self)
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            imagePreview?.imageToDisplay = editedImage
        }else{
            imagePreview?.imageToDisplay = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        
        imagePreview?.info = info
        imagePreview?.delegate = self
        imagePreview?.modalPresentationStyle = .fullScreen
    UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(imagePreview!, animated: true, completion: nil)
    }
    func videoSelected(info: [UIImagePickerController.InfoKey : Any]) {
        self.localPost = VideoTypeLocalPost()
        localPost?.isImage = false
         do{
            (self.currentlyPresentedVC as? UploadPostVC)?.constraintWithImageInvisible.constant = ((self.currentlyPresentedVC as? UploadPostVC)?.descriptionImage.frame.width ?? 0) + 8
            
            if let videoFileURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
                self.localPost?.videoFileURL = videoFileURL
                localPost?.imageDataToBeUploaded = try NSData(contentsOf: videoFileURL as URL, options: .uncachedRead) as Data
                if let asset = info[.phAsset]{
                    let assetResources = PHAssetResource.assetResources(for: (asset as! PHAsset))

                localPost?.imageName = "\((Date().timeIntervalSince1970 * 1000))".replacingOccurrences(of: ".", with: "") + ".mov"
                    
                    print(assetResources.first!.originalFilename)
                }
                
                if let image = (videoFileURL as? URL){
                    localPost?.mimeType = image.pathExtension.lowercased()
                }
            }
        }catch{
            print("Exception occured")
        }

    }
}

extension PostViewer : PostUploadCancelled{
    func uploadCancelled() {
        self.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
}

extension PostViewer : UISearchBarDelegate{
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        (self.dataSourceTableView as? TableViewDataSource)?.filterPostString = searchBar.text
        reloadTableView()
    }
}
