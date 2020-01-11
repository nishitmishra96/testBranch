//
//  Testing.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 12/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import UIKit
import PagingTableView
import ExpandableLabel
import Alamofire
import Photos
import MobileCoreServices
public class BoardPostTableView:BaseTableView {
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
//        (self.dataSourceTableView)?.uploadingNewPost = localPost?.isUploading ?? false
        self.reloadData()
    }
    
}

extension BoardPostTableView:DataForBoard{
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
    
   func reloadTableView() {
        self.reload()
    }

    func removeCell(){
        
    }
}

extension BoardPostTableView: UserActivities{
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
                    MentorzPostViewer.shared.delegate?.handleErrorMessage(error: "Something Went Wrong \(statusCode!)")
                }
            }else{
                MentorzPostViewer.shared.delegate?.handleErrorMessage(error: "Something Went Wrong \(statusCode!)")
            }

        }
    }
    
    func userUnLiked(postId: Int, handler: @escaping ((Bool) -> ())) {
        self.dataSourceTableView?.userUnlikedLiked(postId: postId){ (done) in
            handler(done)
        }
    }
    
    func userLiked(postId: Int, handler: @escaping ((Bool) -> ())) {
        self.dataSourceTableView?.userLikedOn(postId: postId){ (done) in
            handler(done)
        }
    }
    
    func userCommented(postId: Int) {
    }
    
    @objc open func getImageFromGallery(){
        let uploadPostVC = Storyboard.home.instanceOf(viewController: UploadPostPopupVC.self)!
        UIApplication.shared.keyWindow?.rootViewController?.present(uploadPostVC, animated: true, completion: nil)
    }
}


extension BoardPostTableView:AddPost{
    public func addPostbuttonClicked() {
        self.localPost = TextTypeLocalPost()
        let uploadPostVC = Storyboard.home.instanceOf(viewController: UploadPostPopupVC.self)!
        uploadPostVC.delegate = self
        self.currentlyPresentedVC = uploadPostVC
        let uploadPopUp = UIAlertController(title: "Add Post", message: "", preferredStyle: .alert)
        let uploadAction = UIAlertAction(title: "Upload", style: .default) { (uploadAction) in
                self.currentlyPresentedVC?.dismiss(animated: true, completion: nil)
                self.uploadContent()
        }
        uploadAction.isEnabled = false
        uploadPostVC.uploadAction = uploadAction
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive){ _ in
            self.currentlyPresentedVC?.dismiss(animated: true, completion: nil)
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

extension BoardPostTableView:UploadPostDelegate{
    func imagePickerDissmissed() {
        self.localPost = nil
        (self.currentlyPresentedVC as? UploadPostPopupVC)?.constraintWithImageInvisible.constant = 4.0
    }
    
    func uploadContent() {
        self.dataSourceTableView?.uploadingNewPost = true
        self.reloadSections(IndexSet(integersIn: 0...0), with: UITableView.RowAnimation.top)
        localPost?.delegate = self.cellForRow(at: IndexPath(row: 0, section: 0)) as! UploadProgressCell
        localPost?.descriptionFieldText = "\(/(self.currentlyPresentedVC as! UploadPostPopupVC).descriptionField.text)"
        let uploader = UploadTaskManager()
        (self.cellForRow(at: IndexPath(row: 0, section: 0)) as! UploadProgressCell).delegate = uploader
        uploader.uploadContent(localPost: self.localPost){(newPost,statusCode) in
            (self.dataSourceTableView)?.uploadingNewPost = false
            if statusCode == HttpResponseCodes.success.rawValue{
                if let newPostToShow = newPost{
                    self.dataSourceTableView?.uploadingNewPost = false
                    self.reloadSections(IndexSet(integersIn: 0...0), with: UITableView.RowAnimation.top)
                    (self.dataSourceTableView)?.completePosts.insert(CompletePost(post: newPostToShow), at: 0)
                    (self.dataSourceTableView)?.completePostsWithFilter.insert(CompletePost(post: newPostToShow), at: 0)
                    self.beginUpdates()
                    self.insertRows(at: [IndexPath(row: 0, section: 1)], with: .bottom)
                    self.endUpdates()
//                    (self.cellForRow(at: IndexPath(row: 0, section: 0)) as? PostTableViewCell)?.setData(cellPost: CompletePost(post: newPostToShow))
                }
                
            }else{
                self.uploadCancelled()
                MentorzPostViewer.shared.delegate?.handleErrorMessage(error: "Something Went Wrong")
            }
        }
        (self.cellForRow(at: IndexPath(row: 0, section: 0)) as! UploadProgressCell).uploadCancelled = {
            self.uploadCancelled()
        }
    }
    
    func donePressed(info: [UIImagePickerController.InfoKey : Any]) {
        (self.currentlyPresentedVC as? UploadPostPopupVC)?.constraintWithImageInvisible.constant = ((self.currentlyPresentedVC as? UploadPostPopupVC)?.descriptionImage.frame.width ?? 0) + 8
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            localPost?.selectedImage = editedImage

        }else{
            localPost?.selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        (self.currentlyPresentedVC as? UploadPostPopupVC)?.descriptionImage.isHidden = false
        (self.currentlyPresentedVC as? UploadPostPopupVC)?.descriptionImage.image = localPost?.selectedImage
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
            (self.currentlyPresentedVC as? UploadPostPopupVC)?.constraintWithImageInvisible.constant = ((self.currentlyPresentedVC as? UploadPostPopupVC)?.descriptionImage.frame.width ?? 0) + 8
            
            if let videoFileURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
                self.localPost?.videoFileURL = videoFileURL
                localPost?.imageDataToBeUploaded = try NSData(contentsOf: videoFileURL as URL, options: .uncachedRead) as Data
                if let asset = info[.phAsset]{
                    let assetResources = PHAssetResource.assetResources(for: (asset as! PHAsset))

                localPost?.imageName = "\((Date().timeIntervalSince1970 * 1000))".replacingOccurrences(of: ".", with: "") + ".mov"
                    
                    print(assetResources.first!.originalFilename)
                }
                    localPost?.mimeType = (videoFileURL as URL).pathExtension.lowercased()
            }
        }catch{
            print("Exception occured")
        }

    }
}

extension BoardPostTableView : PostUploadCancelled{
    func uploadCancelled() {
        self.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
}

extension BoardPostTableView {
    public func localSearchinPosts(using string:String){
        (self.dataSourceTableView)?.filterPostString = string
        reloadTableView()
    }
}
