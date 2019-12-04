//
//  InterestTableView.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 28/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
import UIKit
class InterestTableView:PostViewer{
    
    override public func getPostsFor(userId: String) {
        self.dataSourceTableView = InterestTableViewDataSource()
        dataSourceTableView?.delegate = self
        pagingDelegate = dataSourceTableView
        self.dataSource = dataSourceTableView
        self.delegate = dataSourceTableView
    }
}
