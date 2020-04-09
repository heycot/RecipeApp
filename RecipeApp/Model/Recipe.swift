//
//  Recipe.swift
//  RecipeApp
//
//  Created by Callie on 4/8/20.
//  Copyright © 2020 Tu (Callie) T. NGUYEN. All rights reserved.
//

import Foundation
import RealmSwift

class Recipe : Object , XMLParserDelegate{
    @objc dynamic var id = ""
    @objc dynamic var name: String?
    @objc dynamic var desc: String?
    @objc dynamic var thumbnail: String?
    @objc dynamic var typeId = ""
    
    let ingredients = List<Ingredient>()
    let steps = List<Step>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
