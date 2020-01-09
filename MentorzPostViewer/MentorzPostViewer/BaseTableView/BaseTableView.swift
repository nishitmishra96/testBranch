//
//  BaseTableView.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 28/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import UIKit
import PagingTableView

open class BaseTableView: PagingTableView {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }

    open override func awakeFromNib() {
        setUp()
    }
    
    func setUp(){
        self.register(UINib.init(nibName: "PostTableViewCell", bundle: Bundle.init(identifier: "com.craterzone.MentorzPostViewer")), forCellReuseIdentifier: "PostTableViewCell")
        self.register(UINib.init(nibName: "UploadProgressCell", bundle: Bundle.init(identifier: "com.craterzone.MentorzPostViewer")), forCellReuseIdentifier: "UploadProgressCell")
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.allowsSelection = false
        self.estimatedRowHeight = UITableView.automaticDimension
        self.rowHeight = UITableView.automaticDimension
    }
    
    @objc func didPullToRefresh(){
        self.refreshControl?.beginRefreshing()
    }
    

}
extension BaseTableView: UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    }
}
