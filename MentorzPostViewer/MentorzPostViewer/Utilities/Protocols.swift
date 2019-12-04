//
//  Protocols.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 26/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation

protocol DataForBoard {
    func reloadTableView()
    func newPostsAppended(oldList:[CompletePost],newList:[CompletePost])
}


protocol UserActivities{
    func userLiked(postId:Int,handler:@escaping ((Int)->()))
    func userUnLiked(postId:Int,handler:@escaping ((Int)->()))
    func userCommented(postId:Int)
    func userReportedAPostWith(post: Post,type:String)
}
