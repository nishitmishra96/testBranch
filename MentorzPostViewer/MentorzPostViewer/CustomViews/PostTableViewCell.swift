//
//  PostTableViewself.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 14/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SDWebImage
import LinkPreviewKit
import TTTAttributedLabel
let RATING_ROUNDUP_MIN_VALUE = 0.2
let RATING_ROUNDUP_MAX_VALUE = 0.7
class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var postText: TTTAttributedLabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var timeOfPost: UILabel!
    @IBOutlet weak var mainPostImage: UIImageView!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var viewCount: UILabel!
    @IBOutlet weak var shareCount: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var abuseButton: UIButton!
    @IBOutlet weak var abusePostImage: UIView!
    @IBOutlet weak var firstStar: UIImageView!
    @IBOutlet weak var secondStar: UIImageView!
    @IBOutlet weak var thirdStar: UIImageView!
    @IBOutlet weak var fourthStar: UIImageView!
    @IBOutlet weak var fifthStar: UIImageView!
    var images : [UIImageView] = []
    
    var didTapOnImageView:((_ imageurl:String)->())?
    var didTapOnVideoPlay:((_ videoUrl:String)->())?
    var delegate : UserActivities?
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    weak var post:Post?
    var url : URL?
    
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.postText.delegate = self
        self.postText.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        self.abusePostImage.layer.borderColor = UIColor.gray.cgColor
        self.abusePostImage.layer.borderWidth = 1.0
        self.abusePostImage.layer.cornerRadius = 5
        images.append(firstStar)
        images.append(secondStar)
        images.append(thirdStar)
        images.append(fourthStar)
        images.append(fifthStar)
        profileImage.layer.cornerRadius = 25
        self.mainPostImage.image = UIImage(named:"loading_data_logo")
    }
    
    func setData(cellPost:CompletePost?){
        guard let completePost = cellPost?.post else{ return }
        self.post = completePost
        self.setProfieImage(completePost: cellPost!)
        self.setRatingwith(completePost:cellPost!)
//        self.postText.setLessLinkWith(lessLink: "Read Less", attributes: [NSAttributedString.Key.foregroundColor:UIColor.gray], position: .left)
//        self.layoutIfNeeded()
//        self.postText.shouldCollapse = true
//        var postxt = NSString(string: post?.content?.descriptionField)
//        let descText = "\((post?.content?.descriptionField?.removingPercentEncoding as NSString?)?.substring(to: 20) ?? "")... \(NSLocalizedString("read more", comment: ""))"

        self.postText.text = post?.content?.descriptionField
//        self.postText.collapsedAttributedLink = NSAttributedString(string: "Read More", attributes: [NSAttributedString.Key.font: UIFont(name: "MyriadPro-Regular", size: 12.0),NSAttributedString.Key.foregroundColor:UIColor.gray]);
//        self.postText.ellipsis = NSAttributedString(string: "...")
//        self.postText.collapsed = true
        self.name.text = post?.name?.removingPercentEncoding
        
        if let likeCount = post?.likeCount{
            self.likeCount.text = (likeCount > 1) ? "\(likeCount) likes":"\(likeCount) like"
        }
        if post?.liked ?? false{
            self.likeButton.setImage(UIImage(named: "selected_like", in: Bundle.init(identifier: "com.craterzone.MentorzPostViewer"), compatibleWith: UITraitCollection(displayScale: 1.0)), for: .normal)

        }else{
            self.likeButton.setImage(UIImage(named: "like", in: Bundle.init(identifier: "com.craterzone.MentorzPostViewer"), compatibleWith: UITraitCollection(displayScale: 1.0)), for: .normal)
        }
        self.commentCount.text = (/post?.commentCount > 1) ? "\(/post?.commentCount) comments " : "\(/post?.commentCount) comment"
        self.viewCount.text = (/post?.viewCount > 1) ? "\(/post?.viewCount) views " : "\(/post?.viewCount) view"
        self.shareCount.text = (/post?.shareCount > 1) ? "\(/post?.shareCount) shares":"\(/post?.shareCount) share"
        self.mainPostImage?.sd_setImage(with: URL(string: /post?.content?.lresId)){(image,error,cache,url) in
            self.mainPostImage.image = image
        }

        if self.post?.content?.mediaType == "IMAGE"{
            self.playButton.setImage(nil, for: .normal)
        }else if self.post?.content?.mediaType == "VIDEO"{
            self.playButton.setImage(UIImage(named:"play"), for: .normal)
        }else if self.post?.content?.mediaType == "TEXT"{

            if let firstUrl = self.getFirstUrl(){
                    self.url = firstUrl.url
                    LKLinkPreviewReader.linkPreview(from: firstUrl.url) { (preview,error) in
                        if preview != nil{
                        if ((preview?.first as! LKLinkPreview).imageURL != nil){
                            self.mainPostImage.sd_setImage(with: (preview?.first as! LKLinkPreview).imageURL) { (image, error, cache, url) in
                                            self.mainPostImage.image = image
                            }
                        }
                        }else{
    //                        self.playButton.isHidden = true
    //                        self.mainPostImage.isHidden = true
//                            self.mainPostImage.image = UIImage(named:"loading_data_logo")

                        }
                    }
                }
        }
        self.timeOfPost.text = dateTimeUtil.getTimeDutation(forPost:"\(/post?.shareTime)")
    }
    func setProfieImage(completePost:CompletePost){
        completePost.getProfileImage { (statusCode) in
            if statusCode == HttpResponseCodes.success.rawValue{
                self.profileImage?.sd_setImage(with: URL(string: /completePost.profileImage?.hresId)) { (image, error, cache, url) in
                    if let profileImage = image{
                        self.profileImage.image = image
                    }else{
                        self.profileImage.image = UIImage(named:"default_avt_square")
                    }
                }
            }else{
                self.profileImage.image = UIImage(named:"default_avt_square")
            }
        }
    }
    
    func getFirstUrl()-> NSTextCheckingResult?{
        do{
            let dataDetector = try NSDataDetector.init(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let firstMatch = dataDetector.firstMatch(in: /post?.content?.descriptionField, options: [], range: NSRange(location: 0, length: /post?.content!.descriptionField?.utf16.count))
            return firstMatch
        }
        catch {
            print("No Links")
        }
        return nil
    }
    func setRatingwith(completePost:CompletePost){
        completePost.getRating() { (statusCode) in
            if statusCode == HttpResponseCodes.success.rawValue{
            if let rating = completePost.rating{
                for rating in 0..<Int(/rating.rating){
                    self.images[rating].image = UIImage(named: "selected_rate")
                }
                let rate = /rating.rating! - Double(Int(/rating.rating))

                if (rate > RATING_ROUNDUP_MIN_VALUE && rate < RATING_ROUNDUP_MAX_VALUE){
                    self.images[Int(/rating.rating) + 1].image = UIImage(named: "selected_halfRate")
                }
                if rate > RATING_ROUNDUP_MAX_VALUE{
                    self.images[Int(/rating.rating) + 1].image = UIImage(named: "selected_rate")
                }
                }
            }else{
                for rating in 0..<5{
                   self.images[rating].image = UIImage(named: "unselected_rate")
                }
            }
        }
    }

    @IBAction func abuseButtonPressed(_ sender: Any) {
        let alertController = UIAlertController.init(title: "Report Abuse?", message: nil, preferredStyle: .actionSheet)

        let inappropriateContent = UIAlertAction(title: "Inappropriate Content", style: .destructive) { (action) in
            self.delegate?.userReportedAPostWith(post: self.post!, type: "InAppropriateContent")
        }
        let spam = UIAlertAction(title: "Spam", style: .destructive) { (action) in
            self.delegate?.userReportedAPostWith(post: self.post!, type: "Spam")
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(inappropriateContent)
        alertController.addAction(spam)
        alertController.addAction(cancel)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    @IBAction func didTapOnImage(_ sender: UIButton) {
        if self.post?.content?.mediaType == "IMAGE"{
//            self.didTapOnImageView?(/self.post?.content?.hresId)
            let storyboard = UIStoryboard(name : "home", bundle:  Bundle.init(identifier: "com.craterzone.MentorzPostViewer"))
            if #available(iOS 13.0, *) {
                let imageViewer = storyboard.instantiateViewController(identifier: "ImageViewerVC") as! ImageViewerVC
                imageViewer.url = URL(string: post?.content?.hresId ?? "")
                imageViewer.modalPresentationStyle = .fullScreen
                UIApplication.shared.keyWindow?.rootViewController?.present(imageViewer, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                let storyboard = UIStoryboard(name : "home", bundle:  Bundle.init(identifier: "com.craterzone.MentorzPostViewer"))
                if #available(iOS 13.0, *) {
                    let imageViewer = storyboard.instantiateViewController(identifier: "ImageViewerVC") as! ImageViewerVC
                    imageViewer.url = URL(string: post?.content?.hresId ?? "")
                    imageViewer.modalPresentationStyle = .fullScreen
                    UIApplication.shared.keyWindow?.rootViewController?.present(imageViewer, animated: true, completion: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
        }else if self.post?.content?.mediaType == "TEXT" {
            
        }else if self.post?.content?.mediaType == "VIDEO"{
//            self.didTapOnVideoPlay?(/self.post?.content?.hresId)
            let videoURL = URL(string: post?.content?.hresId ?? "")
            let player = AVPlayer(url: videoURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            UIApplication.shared.keyWindow?.rootViewController?.present(playerViewController, animated: true, completion: {
                playerViewController.player!.play()
            })
        }
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        notificationFeedbackGenerator.prepare()
            if post?.liked ?? false{
                self.clickedLikeWhenAlreadyLiked()
                notificationFeedbackGenerator.notificationOccurred(.success)
                delegate?.userUnLiked(postId: self.post?.postId ?? 0){ (statusCode) in
                    if statusCode == 204{
                        
                    }else{
                        self.notificationFeedbackGenerator.notificationOccurred(.error)
                        self.clickedLikeWhenAleadyDisliked()
                    }
                }
            }else{
                self.clickedLikeWhenAleadyDisliked()
                notificationFeedbackGenerator.notificationOccurred(.success)
                delegate?.userLiked(postId: post?.postId ?? 0){ (statusCode) in
                    if statusCode == 204{
                        
                    }else{
                        self.clickedLikeWhenAlreadyLiked()
                        self.notificationFeedbackGenerator.notificationOccurred(.error)
                    }
                }
                }

    }
    
    func clickedLikeWhenAlreadyLiked(){
        if (post?.likeCount)! > 0{
            post?.likeCount! -= 1
        }
        if let likeCount = post?.likeCount{
            self.likeCount.text = (likeCount > 1) ? "\(likeCount) likes":"\(likeCount) like"
        }
        post?.liked = false
        self.likeButton.setImage(UIImage(named: "like", in: Bundle.init(identifier: "com.craterzone.MentorzPostViewer"), compatibleWith: UITraitCollection(displayScale: 1.0)), for: .normal)
    }
    
    func clickedLikeWhenAleadyDisliked(){
        post?.likeCount! += 1
        if let likeCount = post?.likeCount{
           self.likeCount.text = (likeCount > 1) ? "\(likeCount) likes":"\(likeCount) like"
        }
        post?.liked = true
           self.likeButton.setImage(UIImage(named: "selected_like", in: Bundle.init(identifier: "com.craterzone.MentorzPostViewer"), compatibleWith: UITraitCollection(displayScale: 1.0)), for: .normal)
    }
    
    @IBAction func commentButtonPressed(_ sender: Any) {
        var commentVC = Storyboard.home.instanceOf(viewController: CommentViewVC.self)!
        UIApplication.shared.keyWindow?.rootViewController?.present(commentVC, animated: true, completion: nil)
        
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
    }
    
    func sharePost(){
        let caption:NSString = "Himanshu Singh"
        let url = NSURL(string: "google.com")!
        let objectstoshare = [caption,url]
        let controller = UIActivityViewController(activityItems: objectstoshare, applicationActivities: nil)
        controller.setValue(caption, forKey: "Subject")
        // Exclude all activities except AirDrop.
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }
}

