//
//  CommentViewCell.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 04/12/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import UIKit
import TTTAttributedLabel
class CommentViewCell: UITableViewCell {
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var commentMessage: TTTAttributedLabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deleteComment(_ sender: Any) {
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(){
        
    }
    
}
