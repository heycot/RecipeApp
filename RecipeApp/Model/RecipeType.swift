//
//  RecipeType.swift
//  RecipeApp
//
//  Created by Callie on 4/8/20.
//  Copyright © 2020 Tu (Callie) T. NGUYEN. All rights reserved.
//

import Foundation
import RealmSwift

class RecipeType : Object {
    @objc dynamic var id = ""
    @objc dynamic var name: String?
    @objc dynamic var desc: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
