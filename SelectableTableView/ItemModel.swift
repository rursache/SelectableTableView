//
//  ItemModel.swift
//  SelectableTableView
//
//  Created by Radu Ursache on 15/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import Foundation
import UIKit

class ItemModel: NSObject, NSCoding {
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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey:"name")
        aCoder.encode(id, forKey:"itemId")
        aCoder.encode(selected, forKey:"selected")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.id = aDecoder.decodeInteger(forKey: "itemId")
        self.selected = aDecoder.decodeBool(forKey: "selected")
    }
}
