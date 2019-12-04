//
//  CommentList.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 04/12/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.

import Foundation
import ObjectMapper


class CommentList : NSObject, Mappable{

    var commentList : [Comment]?
    
    override init(){
        super.init()
    }
    
    required public init?(map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        commentList <- map["comment_list"]
        
    }
}
