//
//  TableViewCell.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 07/01/20.
//  Copyright © 2020 Nishit Mishra. All rights reserved.
//

import UIKit

class UploadProgressCell: UITableViewCell {
    
    @IBOutlet weak var percentageCompleted: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var currentProgress: UIProgressView!
    var delegate = MulticastDelegate<PostUploadCancelled>()
    @IBAction func close(_ sender: Any) {
        delegate.invoke { (delegate) in
            delegate.uploadCancelled()
        }
    }

    override public func layoutSubviews() {
        self.setShadow(color: UIColor.black, opacity: 0.6, radius: 4, offset: CGSize(width: 2, height: 2))
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.percentageCompleted.text = "0 %"
        self.currentProgress.progress = 0.0
    }

    
    func setShadow(color : UIColor ,opacity:Float ,radius : CGFloat ,offset:CGSize){
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.masksToBounds = false // must be false
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offset
    }
}

extension UploadProgressCell:UploadPostProgressDelegate{
    func progressChangedwith(value: Float) {
        self.currentProgress.progress = value
        self.percentageCompleted.text = "\(String(Substring(("\(value*100)".prefix(5))))) %"
    }
}
