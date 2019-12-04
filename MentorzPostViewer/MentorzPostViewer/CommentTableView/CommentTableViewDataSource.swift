//
//  CommentTableViewDataSource.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 04/12/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
import UIKit
class CommentTableViewDataSource:BaseTableViewDataSource{
    
    override func getCommentForPost() {
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentViewCell") as! CommentViewCell
        
        return cell
    }
    
}
