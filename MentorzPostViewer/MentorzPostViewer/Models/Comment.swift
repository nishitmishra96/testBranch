//
//  Comment.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 04/12/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
import ObjectMapper


class Comment : NSObject, Mappable{

    var comment : String?
    var commentId : Int?
    var commentTime : Int?
    var hresId : String?
    var lastName : String?
    var lresId : String?
    var name : String?
    var userId : Int?
    var userName : String?


    override init() {
        super.init()
    }
    
    required public init?(map: Map) {
        
    }

    func mapping(map: Map)
    {
        comment <- map["comment"]
        commentId <- map["comment_id"]
        commentTime <- map["comment_time"]
        hresId <- map["hres_id"]
        lastName <- map["last_name"]
        lresId <- map["lres_id"]
        name <- map["name"]
        userId <- map["user_id"]
        userName <- map["user_name"]
        
    }
}
