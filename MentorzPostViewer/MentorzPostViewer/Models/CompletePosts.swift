//
//  CompletePosts.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 04/12/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
class CompletePost:NSObject{
    var post:Post?
    var comments : [CompleteComment]? = []
    override init(){
        super.init()
    }
    public init(post:Post){
        super.init()
        self.post = post
    }

    func getRating(handler:@escaping ((Double?,Int?)->())){
        PostsRestManager.shared.getUserRating(userId: "\(/post?.userId)") { (rating, statusCode) in
            handler(rating?.rating,statusCode)
        }
    }
    func getProfileImage(handler:@escaping ((String?,Int?)->())){
        PostsRestManager.shared.getProfileImageWith(userId: "\(/post?.userId)") { (profileImage, statusCode) in
            handler(profileImage?.hresId,statusCode)
        }
    }
}
