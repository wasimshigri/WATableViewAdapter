//
//  TableCellTableViewCell.swift
//  multiLevelTable
//
//  Created by Waseem Ahmed on 4/30/18.
//  Copyright © 2018 Waseem Ahmed. All rights reserved.
//

import UIKit
import SwipeCellKit

public class WATableViewCell: SwipeTableViewCell {

    @IBOutlet weak public var  title:UILabel!
    @IBOutlet weak public var  subTitle:UILabel!
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
