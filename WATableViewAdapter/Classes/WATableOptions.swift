//
//  WASwipwTableOptions.swift
//  multiLevelTable
//
//  Created by Waseem Ahmed on 5/31/18.
//  Copyright © 2018 Waseem Ahmed. All rights reserved.
//

import UIKit

class WATableOptions {

}

/// Describes which side of the cell that the action buttons will be displayed.
@objc public enum WASwipeActionsOrientation: Int {
    /// The left side of the cell.
    case left = -1
    
    /// The right side of the cell.
    case right = 1
    
    var scale: Int {
        return rawValue
    }
    
   
}
