//
//  CommentViewVC.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 04/12/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import UIKit

class CommentViewVC: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    var dataSource : CommentTableViewDataSource?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib.init(nibName: "CommentViewCell", bundle: Bundle.init(identifier: "com.craterzone.MentorzPostViewer")), forCellReuseIdentifier: "CommentViewCell")
    }

}
