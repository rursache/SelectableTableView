//
//  ItemModel.swift
//  SelectableTableView
//
//  Created by Radu Ursache on 15/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import Foundation
import UIKit

class ItemModel: NSObject {
    
    var name: String = "Empty Name"
    var id: Int = 0
    var selected: Bool = false
    
    override init() {
        super.init()
    }
    
    convenience init(name: String?, id: Int = 0, selected: Bool = false) {
        self.init()
        
        if let name = name {
            self.name = name
        }
        
        self.id = id
        self.selected = selected
    }
}
