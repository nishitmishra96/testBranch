//
//  MentorzPostViewer.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 10/01/20.
//  Copyright © 2020 Nishit Mishra. All rights reserved.
//

import UIKit
@objc public protocol MentorzPostViewerDatasource{
    func authToken()->String
}
@objc public  class MentorzPostViewer: NSObject {
    @objc public static var shared = MentorzPostViewer()
    @objc public var dataSource:MentorzPostViewerDatasource?
    private override init() {
        super.init()
    }
}
