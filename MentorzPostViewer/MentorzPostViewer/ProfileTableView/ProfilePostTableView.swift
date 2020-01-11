//
//  ProfilePostViewer.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 28/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
import UIKit
public class ProfilePostTableView:BoardPostTableView{
    override public func getPostsFor(userId: String) {
        self.dataSourceTableView = ProfilePostViewerDataSource(userId: userId)
        dataSourceTableView?.delegate = self
        pagingDelegate = dataSourceTableView
        self.dataSource = dataSourceTableView
        self.delegate = dataSourceTableView
    }
}

