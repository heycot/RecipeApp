//
//  Step.swift
//  RecipeApp
//
//  Created by Callie on 4/8/20.
//  Copyright © 2020 Tu (Callie) T. NGUYEN. All rights reserved.
//

import Foundation
import RealmSwift


class Step : Object {
    @objc dynamic var id = ""
    @objc dynamic var order = 0
    @objc dynamic var desc: String?
    @objc dynamic var recipeId  = ""
        
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
