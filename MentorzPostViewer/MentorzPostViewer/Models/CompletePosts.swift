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
    var profileImage:ProfileImage?
    var rating:Rating?
    public init(post:Post){
        super.init()
        self.post = post
    }
    
    func getRating(handler:@escaping ((Int?)->())){
        PostsRestManager.shared.getUserRating(userId: "\(/post?.userId)") { (ratings, statusCode) in
            if statusCode == HttpResponseCodes.success.rawValue{
                self.rating = ratings
            }else{
            }
            handler(statusCode)
        }
    }
    func getProfileImage(handler:@escaping ((Int?)->())){
        PostsRestManager.shared.getProfileImageWith(userId: "\(/post?.userId)") { (profileImage, statusCode) in
            if statusCode == HttpResponseCodes.success.rawValue{
                self.profileImage = profileImage
            }else{
            }
            handler(statusCode)

        }
    }
}
