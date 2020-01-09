//
//  CommentViewVC.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 04/12/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManager
class CommentViewVC: UIViewController {
   
    @IBOutlet weak var tableView: CommentTableView!
    @IBOutlet weak var CommentTextField: UITextField!
    @IBOutlet weak var messegeLabel: UILabel!
    
    var dataSource : CommentTableViewDataSource?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib.init(nibName: "CommentViewCell", bundle: Bundle.init(identifier: "com.craterzone.MentorzPostViewer")), forCellReuseIdentifier: "CommentViewCell")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public func getCommentList(userId:String?,postId:String?,comments:[CompleteComment]?){
        self.tableView.getCommentList(userId: /userId, postId: /postId,comments:comments)
        
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func postButtonPressed(_ sender: Any) {
        SVProgressHUD.show()
        PostsRestManager.shared.userCommentedOnAPost(userId: /self.tableView.dataSourceTableView?.userId, postId: /self.tableView.dataSourceTableView?.postId, comment: /self.CommentTextField.text) { (statusCode) in
            SVProgressHUD.dismiss()
            if statusCode == HttpResponseCodes.success.rawValue{
                self.CommentTextField.text = ""
                self.tableView.dataSourceTableView?.getCommentForPost(tableView: self.tableView, to: self.tableView.currentPage)
            }
        }
        
    }
}
