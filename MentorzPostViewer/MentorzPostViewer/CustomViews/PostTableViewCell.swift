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
import moa
let RATING_ROUNDUP_MIN_VALUE = 0.2
let RATING_ROUNDUP_MAX_VALUE = 0.7
class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var viewWithProfileImage: UIView!
    @IBOutlet weak var userActivitiesView: UIView!
    
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
    @IBOutlet weak var readMore : UIButton!
    @IBOutlet weak var containerView:UIView!
    var images : [UIImageView] = []
    @IBOutlet weak var userActivitiesStackView: UIStackView!
    @IBOutlet weak var viewWithImageAndButton: UIView!
    @IBOutlet weak var viewWithImageAndButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var didTapOnImageView:((_ imageurl:String)->())?
    var didTapOnVideoPlay:((_ videoUrl:String)->())?
    var delegate : UserActivities?
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    weak var completePost:CompletePost?
    var url : URL?
    var userId : String?
    var readMorePressed = false
    @IBAction func readMorePressed(_ sender: Any) {
        if !(self.readMorePressed){
            self.postText.numberOfLines = 0
            self.postText.lineBreakMode = .byWordWrapping
//            self.postText.text = self.completePost?.post?.content?.descriptionField
            self.readMore.setTitle("Read Less", for: .normal)
            delegate?.userPressedReadMore(post:self.completePost)
        }else{
            self.postText.numberOfLines = 2
            self.postText.lineBreakMode = .byTruncatingTail
            self.readMore.setTitle("Read More", for: .normal)
            delegate?.userPressedReadLess(post:self.completePost)
        }
        self.layoutIfNeeded()
        self.readMorePressed = !self.readMorePressed
    }
    
    func setUpCell(){
        self.baseView.backgroundColor = UIColor.appColor
        self.containerView.layer.borderWidth = 1
        self.containerView.layer.borderColor = UIColor.borderColor
        self.containerView.layer.cornerRadius = 5
        self.likeButton.layer.borderWidth = 0.5
        self.likeButton.layer.borderColor = UIColor.borderColor
        self.commentButton.layer.borderWidth = 0.5
        self.commentButton.layer.borderColor = UIColor.borderColor
        self.shareButton.layer.borderWidth = 0.5
        self.shareButton.layer.borderColor = UIColor.borderColor
        self.userActivitiesView.layer.cornerRadius = 1
        self.mainPostImage.layer.borderWidth = 0.5
        self.mainPostImage.layer.borderColor = UIColor.borderColor
        self.postText.textColor = UIColor.postTextColor
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpCell()
        self.postText.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        self.abusePostImage.layer.borderColor = UIColor.gray.cgColor
        self.abusePostImage.layer.borderWidth = 1.0
        self.abusePostImage.layer.cornerRadius = 5
        images.append(firstStar)
        images.append(secondStar)
        images.append(thirdStar)
        images.append(fourthStar)
        images.append(fifthStar)
        self.postText.delegate = self
        profileImage.layer.cornerRadius = 25
        self.mainPostImage.image = UIImage(named:"loading_data_logo")
//        self.profileImage.image = UIImage(named: "default_avt_square")
        self.postText.numberOfLines = 2
        self.postText.lineSpacing = 5
    }
    
    override func prepareForReuse() {
//        profileImage.image = nil
//        timeOfPost.text = ""
//        postText.text = nil
//        name.text = ""
//        mainPostImage.image = nil
//        likeCount.text = ""
//        commentCount.text = ""
//        shareCount.text = ""
//        viewCount.text = ""
//        self.profileImage.image = UIImage(named: "default_avt_square")
//        self.mainPostImage.image = UIImage(named:"loading_data_logo")
//        for rating in 0..<5{
//           self.images[rating].image = UIImage(named: "unselected_rate")
//        }
    }
    func setData(cellPost:CompletePost?){
        guard let newPost = cellPost else { return }
        self.completePost = newPost
        self.setProfieImage(completePost: cellPost!)
        self.setRatingwith(completePost:cellPost!)
        self.postText.text = completePost?.post?.content?.descriptionField
        self.name.text = completePost?.post?.name?.removingPercentEncoding
        self.readMore.setTitle("Read More", for: .normal)
        if let likeCount = completePost?.post?.likeCount{
            self.likeCount.text = (likeCount > 1) ? "\(likeCount) likes":"\(likeCount) like"
        }
        if completePost?.post?.liked ?? false{
            self.likeButton.setImage(UIImage(named: "selected_like", in: Bundle.init(identifier: "com.craterzone.MentorzPostViewer"), compatibleWith: UITraitCollection(displayScale: 1.0)), for: .normal)
        }else{
            self.likeButton.setImage(UIImage(named: "like", in: Bundle.init(identifier: "com.craterzone.MentorzPostViewer"), compatibleWith: UITraitCollection(displayScale: 1.0)), for: .normal)
        }
        self.commentCount.text = (/completePost?.post?.commentCount > 1) ? "\(/completePost?.post?.commentCount) comments " : "\(/completePost?.post?.commentCount) comment"
        self.viewCount.text = (/completePost?.post?.viewCount > 1) ? "\(/completePost?.post?.viewCount) views " : "\(/completePost?.post?.viewCount) view"
        self.shareCount.text = (/completePost?.post?.shareCount > 1) ? "\(/completePost?.post?.shareCount) shares":"\(/completePost?.post?.shareCount) share"
        if /completePost?.post?.content?.lresId?.count >= 2{
            self.mainPostImage.isHidden = false
            self.playButton.isHidden = false
            self.mainPostImage.image = UIImage(named:"loading_data_logo")
            self.mainPostImage.moa.url = /completePost?.post?.content?.lresId
            viewWithImageAndButtonHeight.constant = self.viewWithImageAndButton.frame.width
        }else{
            viewWithImageAndButtonHeight.constant = 0
            self.mainPostImage.isHidden = true
            self.playButton.isHidden = true
        }
        if self.completePost?.post?.content?.mediaType == "IMAGE"{
            self.playButton.setImage(nil, for: .normal)
        }else if self.completePost?.post?.content?.mediaType == "VIDEO"{
            self.playButton.setImage(UIImage(named:"play"), for: .normal)
        }else if self.completePost?.post?.content?.mediaType == "TEXT"{

        }
        self.timeOfPost.text = dateTimeUtil.getTimeDutation(forPost:"\(/completePost?.post?.shareTime)")
        if postText.isTruncated{
            self.readMore.isHidden = true
        }else{
            self.readMore.isHidden = false
        }
    }
    
    func setProfieImage(completePost:CompletePost){
        completePost.getProfileImage { (statusCode) in
            if statusCode == HttpResponseCodes.success.rawValue{
                self.profileImage.moa.url = /completePost.profileImage?.hresId
            }else{
                self.profileImage.image = UIImage(named:"default_avt_square")
            }
        }
    }
    
    func setImageForText(url:String){
        self.mainPostImage.isHidden = false
        self.playButton.isHidden = false
        self.mainPostImage.moa.url = url
        viewWithImageAndButtonHeight.constant = self.viewWithImageAndButton.frame.width
    }
    
    func getFirstUrl()-> NSTextCheckingResult?{
        do{
            let dataDetector = try NSDataDetector.init(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let firstMatch = dataDetector.firstMatch(in: /completePost?.post?.content?.descriptionField, options: [], range: NSRange(location: 0, length: /completePost?.post?.content!.descriptionField?.utf16.count))
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
                    self.images[Int(/rating.rating)].image = UIImage(named: "selected_halfRate")
                }
                if rate > RATING_ROUNDUP_MAX_VALUE{
                    self.images[Int(/rating.rating)].image = UIImage(named: "selected_rate")
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
            self.delegate?.userReportedAPostWith(post: (self.completePost?.post)!, type: "InAppropriateContent")
        }
        let spam = UIAlertAction(title: "Spam", style: .destructive) { (action) in
            self.delegate?.userReportedAPostWith(post: (self.completePost?.post)!, type: "Spam")
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(inappropriateContent)
        alertController.addAction(spam)
        alertController.addAction(cancel)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    @IBAction func didTapOnImage(_ sender: UIButton) {
        if self.completePost?.post?.content?.mediaType == "IMAGE"{
            let imageViewer = Storyboard.home.instanceOf(viewController: ImageViewerVC.self)!
            imageViewer.url = URL(string: completePost?.post?.content?.hresId ?? "")
            imageViewer.modalPresentationStyle = .fullScreen
            UIApplication.shared.keyWindow?.rootViewController?.present(imageViewer, animated: true, completion: nil)

        }else if self.completePost?.post?.content?.mediaType == "TEXT" {
            let imageViewer = Storyboard.home.instanceOf(viewController: ImageViewerVC.self)!
            if let _ = self.completePost?.post?.content?.hresId {
                imageViewer.url = URL(string: completePost?.post?.content?.hresId ?? "")
            }
            imageViewer.modalPresentationStyle = .fullScreen
            UIApplication.shared.keyWindow?.rootViewController?.present(imageViewer, animated: true, completion: nil)
        }else if self.completePost?.post?.content?.mediaType == "VIDEO"{
            let videoURL = URL(string: completePost?.post?.content?.hresId ?? "")
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
            if completePost?.post?.liked ?? false{
                self.clickedLikeWhenAlreadyLiked()
                notificationFeedbackGenerator.notificationOccurred(.success)
                delegate?.userUnLiked(postId: /self.completePost?.post?.postId){ (done) in
                    if done{
                    }else{
                        self.notificationFeedbackGenerator.notificationOccurred(.error)
                        self.clickedLikeWhenAleadyDisliked()
                    }
                }
            }else{
                self.clickedLikeWhenAleadyDisliked()
                notificationFeedbackGenerator.notificationOccurred(.success)
                delegate?.userLiked(postId: /completePost?.post?.postId){ (done) in
                    if done{}else{
                        self.clickedLikeWhenAlreadyLiked()
                        self.notificationFeedbackGenerator.notificationOccurred(.error)
                    }
                }
                }

    }
    
    func clickedLikeWhenAlreadyLiked(){
        if (completePost?.post?.likeCount)! > 0{
            completePost?.post?.likeCount! -= 1
        }
        if let likeCount = completePost?.post?.likeCount{
            self.likeCount.text = (likeCount > 1) ? "\(likeCount) likes":"\(likeCount) like"
        }
        completePost?.post?.liked = false
        self.likeButton.setImage(UIImage(named: "like", in: Bundle.init(identifier: "com.craterzone.MentorzPostViewer"), compatibleWith: UITraitCollection(displayScale: 1.0)), for: .normal)
    }
    
    func clickedLikeWhenAleadyDisliked(){
        completePost?.post?.likeCount! += 1
        if let likeCount = completePost?.post?.likeCount{
           self.likeCount.text = (likeCount > 1) ? "\(likeCount) likes":"\(likeCount) like"
        }
        completePost?.post?.liked = true
           self.likeButton.setImage(UIImage(named: "selected_like", in: Bundle.init(identifier: "com.craterzone.MentorzPostViewer"), compatibleWith: UITraitCollection(displayScale: 1.0)), for: .normal)
    }
    
    @IBAction func commentButtonPressed(_ sender: Any) {
        let commentVC = Storyboard.home.instanceOf(viewController: CommentViewVC.self)!
        commentVC.modalPresentationStyle = .fullScreen
        UIApplication.shared.keyWindow?.rootViewController?.present(commentVC, animated: true, completion:{
            commentVC.getCommentList(userId: self.userId, postId: "\(/self.completePost?.post?.postId)",comments: self.completePost?.comments)
        })
    }
    
    @IBAction func profilePictureTapped(_ sender: Any) {
        
    }
    @IBAction func shareButtonPressed(_ sender: Any) {
        let url : NSURL?
        let caption:NSString = NSString(string: /self.completePost?.post?.content?.descriptionField)
        if self.completePost?.post?.content?.mediaType != "TEXT"{
            url = NSURL(string: /self.completePost?.post?.content?.hresId)!
        }else{
            url = self.url as NSURL?
        }
        let objectstoshare = [caption,url]
        let controller = UIActivityViewController(activityItems: objectstoshare, applicationActivities: nil)
        controller.setValue(caption, forKey: "Subject")
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }
    
    func sharePost(){
        let caption:NSString = "Himanshu Singh"
        let url = NSURL(string: "google.com")!
        let objectstoshare = [caption,url]
        let controller = UIActivityViewController(activityItems: objectstoshare, applicationActivities: nil)
        controller.setValue(caption, forKey: "Subject")
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }
}

extension PostTableViewCell:TTTAttributedLabelDelegate{
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
