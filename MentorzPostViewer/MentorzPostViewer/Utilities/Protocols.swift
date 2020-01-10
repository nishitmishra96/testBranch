//
//  Protocols.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 26/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
import UIKit
protocol DataForBoard {
    func reloadTableView()
    func newPostsAppended(oldList:[CompletePost],newList:[CompletePost])
    func newCommentAppended(oldList:[CompleteComment],newList:[CompleteComment])
}


protocol UserActivities{
    func userLiked(postId:Int,handler:@escaping ((Bool)->()))
    func userUnLiked(postId:Int,handler:@escaping ((Bool)->()))
    func userCommented(postId:Int)
    func userDeletedComment(completeComment:CompleteComment)
    func userReportedAPostWith(post: Post,type:String)
    func userPressedReadMore(post:CompletePost?)
    func userPressedReadLess(post:CompletePost?)
    func reloadTableView(forPost:CompletePost?)
}


public protocol AddPost{
    func addPostbuttonClicked()
}

protocol UploadPostDelegate {
    func imageSelected(info: [UIImagePickerController.InfoKey : Any])
    func videoSelected(info: [UIImagePickerController.InfoKey : Any])
    func openGallery(isVideo:Bool)
//    func uploadContent()
    func donePressed(info: [UIImagePickerController.InfoKey : Any])
    func imagePickerDissmissed()
}

protocol UploadPostProgressDelegate{
    func progressChangedwith(value:Float)
}

protocol PostUploadCancelled{
    func uploadCancelled()
}
