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
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.allowsSelection = false
    }
    
    @objc func didPullToRefresh(){
        self.refreshControl?.beginRefreshing()
    }
}
