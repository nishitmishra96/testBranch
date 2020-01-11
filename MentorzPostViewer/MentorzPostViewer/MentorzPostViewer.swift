//
//  MentorzPostViewer.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 10/01/20.
//  Copyright © 2020 Nishit Mishra. All rights reserved.
//

import UIKit
@objc public protocol MentorzPostViewerDelegates{
    func handleUnsportedStatusCode(statusCode:Int)
    func showSucessMessage(message:String)
    func handleErrorMessage(error:String)
    func handleProgressHUD(shouldShow:Bool)
}
@objc public protocol MentorzPostViewerDatasource{
    func authToken()->String
    func getUserId()->String
}
@objc public  class MentorzPostViewer: NSObject {
    @objc public static var shared = MentorzPostViewer()
    /// Always use it with single instance with higest level of abstarction like: Appdelegate or Any manager which actually have direct access to the Data
    @objc public var dataSource:MentorzPostViewerDatasource?
    
    /// Always use it with single instance with higest level of abstarction like: Appdelegate or Any manager which actually have direct access to handle Error display and showing Progress Hud which are blocking by its nature unless activity is finished
    @objc public var delegate:MentorzPostViewerDelegates?
    private override init() {
        super.init()
    }
    public func setEnvironment(isStaging:Bool){
        URLGenerator.shared.isStaging = isStaging
    }
}
